import { NextRequest, NextResponse } from "next/server";

import {
  backendFetch,
  cookieOptions,
  QR_COOKIE,
  REG_COOKIE,
  setSessionCookies,
  type BackendTokens,
} from "@/lib/auth/server";

type PollQRPayload = {
  status: "pending" | "authenticated" | "registration_required";
  scanned?: boolean;
  tokens?: BackendTokens;
  user?: unknown;
  registration?: { token: string };
};

export async function POST(req: NextRequest) {
  const raw = req.cookies.get(QR_COOKIE)?.value;
  if (!raw) {
    return NextResponse.json({ message: "QR sessiyasi topilmadi" }, { status: 400 });
  }
  let attempt: { attempt_id?: string; secret?: string } = {};
  try {
    attempt = JSON.parse(raw);
  } catch {
    return NextResponse.json({ message: "QR sessiyasi yaroqsiz" }, { status: 400 });
  }

  const { status, data } = await backendFetch<PollQRPayload>(req, "/api/v1/auth/qr/poll", {
    method: "POST",
    body: { attempt_id: attempt.attempt_id, secret: attempt.secret },
  });
  if (!data.success || !data.payload) {
    const errRes = NextResponse.json({ message: data.message || "QR kirishda xatolik" }, { status });
    if (status === 400 || status === 403 || status === 404 || status === 409) {
      errRes.cookies.set(QR_COOKIE, "", cookieOptions(req, 0));
    }
    return errRes;
  }

  if (data.payload.status === "pending") {
    return NextResponse.json({ status: "pending", scanned: Boolean(data.payload.scanned) });
  }

  if (data.payload.status === "authenticated" && data.payload.tokens) {
    const res = NextResponse.json({ status: "authenticated", user: data.payload.user });
    res.cookies.set(QR_COOKIE, "", cookieOptions(req, 0));
    setSessionCookies(req, res, data.payload.tokens);
    return res;
  }

  if (data.payload.status === "registration_required" && data.payload.registration?.token) {
    const res = NextResponse.json({ status: "registration_required" });
    res.cookies.set(QR_COOKIE, "", cookieOptions(req, 0));
    res.cookies.set(REG_COOKIE, data.payload.registration.token, cookieOptions(req, 60 * 30));
    return res;
  }

  return NextResponse.json({ message: "Kutilmagan javob" }, { status: 500 });
}
