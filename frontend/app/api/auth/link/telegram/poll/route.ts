import { NextRequest, NextResponse } from "next/server";

import {
  backendAuthFetch,
  cookieOptions,
  setSessionCookies,
  TELEGRAM_COOKIE,
  type BackendTokens,
} from "@/lib/auth/server";

type PollLinkPayload = {
  status: "pending" | "linked";
  merged?: boolean;
  bot_opened?: boolean;
  user?: unknown;
  methods?: unknown[];
  tokens?: BackendTokens;
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

  const { status, data, rotated } = await backendAuthFetch<PollLinkPayload>(
    req,
    "/api/v1/auth/me/telegram/link/poll",
    { method: "POST", body: { attempt_id: attempt.attempt_id, secret: attempt.secret } },
  );
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Telegram ulashda xatolik" }, { status });
  }

  const { tokens, ...publicPayload } = data.payload;
  const res = NextResponse.json(publicPayload);
  if (tokens) setSessionCookies(req, res, tokens);
  else if (rotated) setSessionCookies(req, res, rotated);
  if (data.payload.status === "linked") {
    res.cookies.set(TELEGRAM_COOKIE, "", cookieOptions(req, 0));
  }
  return res;
}
