import { NextRequest, NextResponse } from "next/server";

import { backendAuthFetch, setSessionCookies, type BackendTokens } from "@/lib/auth/server";

type VerifyPhonePayload = {
  merged?: boolean;
  user?: unknown;
  methods?: unknown[];
  tokens?: BackendTokens;
};

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const { status, data, rotated } = await backendAuthFetch<VerifyPhonePayload>(
    req,
    "/api/v1/auth/me/phone/verify",
    { method: "POST", body: { phone: body.phone, code: body.code } },
  );
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Telefonni tasdiqlashda xatolik" }, { status });
  }
  const { tokens, ...publicPayload } = data.payload;
  const res = NextResponse.json(publicPayload);
  if (tokens) setSessionCookies(req, res, tokens);
  else if (rotated) setSessionCookies(req, res, rotated);
  return res;
}
