import { NextRequest, NextResponse } from "next/server";

import { backendFetch, cookieOptions, getPublicOrigin, QR_COOKIE } from "@/lib/auth/server";

type StartQRPayload = {
  attempt_id: string;
  secret: string;
  qr_token: string;
  expires_at: string;
  expires_in_seconds: number;
};

export async function POST(req: NextRequest) {
  const { status, data } = await backendFetch<StartQRPayload>(req, "/api/v1/auth/qr/start", {
    method: "POST",
    body: {},
  });
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "QR kod yaratib bo‘lmadi" }, { status });
  }

  const origin = getPublicOrigin(req);
  const qrUrl = `${origin}/login/qr/${encodeURIComponent(data.payload.qr_token)}`;
  const res = NextResponse.json({
    qr_url: qrUrl,
    expires_at: data.payload.expires_at,
    expires_in_seconds: data.payload.expires_in_seconds,
  });
  res.cookies.set(
    QR_COOKIE,
    JSON.stringify({ attempt_id: data.payload.attempt_id, secret: data.payload.secret }),
    cookieOptions(req, data.payload.expires_in_seconds || 180),
  );
  return res;
}
