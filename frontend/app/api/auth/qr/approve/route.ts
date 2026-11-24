import { NextRequest, NextResponse } from "next/server";

import {
  backendAuthFetch,
  backendFetch,
  cookieOptions,
  REG_COOKIE,
  setSessionCookies,
} from "@/lib/auth/server";

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const qrToken = typeof body.qr_token === "string" ? body.qr_token : "";
  const mode = body.mode === "registration" ? "registration" : "session";

  if (mode === "registration") {
    const regToken = req.cookies.get(REG_COOKIE)?.value || "";
    if (!regToken) {
      return NextResponse.json({ message: "Ro‘yxatdan o‘tish tokeni topilmadi" }, { status: 400 });
    }
    const { status, data } = await backendFetch(req, "/api/v1/auth/qr/approve-registration", {
      method: "POST",
      body: { qr_token: qrToken, registration_token: regToken },
    });
    if (!data.success) {
      return NextResponse.json({ message: data.message || "Tasdiqlab bo‘lmadi" }, { status });
    }
    const res = NextResponse.json({ ok: true, registration_handoff: true });
    res.cookies.set(REG_COOKIE, "", cookieOptions(req, 0));
    return res;
  }

  const { status, data, rotated } = await backendAuthFetch(req, "/api/v1/auth/qr/approve-session", {
    method: "POST",
    body: { qr_token: qrToken },
  });
  if (!data.success) {
    return NextResponse.json({ message: data.message || "Tasdiqlab bo‘lmadi" }, { status });
  }
  const res = NextResponse.json({ ok: true });
  if (rotated) setSessionCookies(req, res, rotated);
  return res;
}
