import { NextRequest, NextResponse } from "next/server";

import { backendFetch, cookieOptions, TELEGRAM_COOKIE } from "@/lib/auth/server";

type StartTelegramPayload = {
  attempt_id: string;
  secret: string;
  deep_link: string;
  bot_username: string;
  expires_at: string;
};

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const qrToken = typeof body?.qr_token === "string" ? body.qr_token.trim() : "";

  const endpoint = qrToken ? "/api/v1/auth/qr/telegram/start" : "/api/v1/auth/telegram/start";
  const payload = qrToken ? { qr_token: qrToken } : {};

  const { status, data } = await backendFetch<StartTelegramPayload>(req, endpoint, {
    method: "POST",
    body: payload,
  });
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Telegram kirish boshlanmadi" }, { status });
  }

  const res = NextResponse.json({
    deep_link: data.payload.deep_link,
    bot_username: data.payload.bot_username,
    expires_at: data.payload.expires_at,
  });
  res.cookies.set(
    TELEGRAM_COOKIE,
    JSON.stringify({ attempt_id: data.payload.attempt_id, secret: data.payload.secret }),
    cookieOptions(req, 60 * 5),
  );
  return res;
}
