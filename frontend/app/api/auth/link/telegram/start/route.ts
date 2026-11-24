import { NextRequest, NextResponse } from "next/server";

import {
  backendAuthFetch,
  cookieOptions,
  setSessionCookies,
  TELEGRAM_COOKIE,
} from "@/lib/auth/server";

type StartTelegramPayload = {
  attempt_id: string;
  secret: string;
  deep_link: string;
  bot_username: string;
  expires_at: string;
};

export async function POST(req: NextRequest) {
  const { status, data, rotated } = await backendAuthFetch<StartTelegramPayload>(
    req,
    "/api/v1/auth/me/telegram/link/start",
    { method: "POST", body: {} },
  );
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Telegram ulashni boshlab bo'lmadi" }, { status });
  }

  const res = NextResponse.json({
    deep_link: data.payload.deep_link,
    bot_username: data.payload.bot_username,
    expires_at: data.payload.expires_at,
  });
  if (rotated) setSessionCookies(req, res, rotated);
  res.cookies.set(
    TELEGRAM_COOKIE,
    JSON.stringify({ attempt_id: data.payload.attempt_id, secret: data.payload.secret }),
    cookieOptions(req, 60 * 5),
  );
  return res;
}
