import { NextRequest, NextResponse } from "next/server";

import {
  backendFetch,
  cookieOptions,
  REG_COOKIE,
  setSessionCookies,
  TELEGRAM_COOKIE,
  type BackendTokens,
} from "@/lib/auth/server";

type PollPayload = {
  status: "pending" | "authenticated" | "registration_required";
  bot_opened?: boolean;
  tokens?: BackendTokens;
  user?: unknown;
  registration?: { token: string };
};

export async function POST(req: NextRequest) {
  const raw = req.cookies.get(TELEGRAM_COOKIE)?.value;
  if (!raw) {
    return NextResponse.json({ message: "Telegram urinishi topilmadi" }, { status: 400 });
  }
  let attempt: { attempt_id?: string; secret?: string } = {};
  try {
    attempt = JSON.parse(raw);
  } catch {
    return NextResponse.json({ message: "Telegram urinishi yaroqsiz" }, { status: 400 });
  }

  const { status, data } = await backendFetch<PollPayload>(req, "/api/v1/auth/telegram/poll", {
    method: "POST",
    body: { attempt_id: attempt.attempt_id, secret: attempt.secret },
  });
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Telegram kirishda xatolik" }, { status });
  }

  if (data.payload.status === "pending") {
    return NextResponse.json({ status: "pending", bot_opened: Boolean(data.payload.bot_opened) });
  }

  if (data.payload.status === "authenticated" && data.payload.tokens) {
    const res = NextResponse.json({ status: "authenticated", user: data.payload.user });
    res.cookies.set(TELEGRAM_COOKIE, "", cookieOptions(req, 0));
    setSessionCookies(req, res, data.payload.tokens);
    return res;
  }

  if (data.payload.status === "registration_required" && data.payload.registration?.token) {
    const res = NextResponse.json({ status: "registration_required" });
    res.cookies.set(TELEGRAM_COOKIE, "", cookieOptions(req, 0));
    res.cookies.set(REG_COOKIE, data.payload.registration.token, cookieOptions(req, 60 * 30));
    return res;
  }

  return NextResponse.json({ message: "Kutilmagan javob" }, { status: 500 });
}
