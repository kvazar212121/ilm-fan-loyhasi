import { NextRequest, NextResponse } from "next/server";

import {
  backendFetch,
  cookieOptions,
  REG_COOKIE,
  setSessionCookies,
  type BackendTokens,
} from "@/lib/auth/server";

type VerifyRegPhonePayload = {
  status: "authenticated" | "registration_required";
  tokens?: BackendTokens;
  user?: unknown;
  registration?: { token: string };
};

export async function POST(req: NextRequest) {
  const regToken = req.cookies.get(REG_COOKIE)?.value;
  if (!regToken) {
    return NextResponse.json({ message: "Ro‘yxatdan o‘tish sessiyasi eskirgan" }, { status: 401 });
  }
  const body = await req.json().catch(() => ({}));
  const { status, data } = await backendFetch<VerifyRegPhonePayload>(
    req,
    "/api/v1/auth/registration/verify-phone",
    {
      method: "POST",
      body: {
        registration_token: regToken,
        phone: body.phone,
        code: body.code,
      },
    },
  );
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Tasdiqlash kodi noto‘g‘ri" }, { status });
  }

  if (data.payload.status === "authenticated" && data.payload.tokens) {
    const res = NextResponse.json({ status: "authenticated", user: data.payload.user });
    res.cookies.set(REG_COOKIE, "", cookieOptions(req, 0));
    setSessionCookies(req, res, data.payload.tokens);
    return res;
  }

  if (data.payload.status === "registration_required" && data.payload.registration?.token) {
    const res = NextResponse.json({ status: "verified", phone: body.phone });
    res.cookies.set(REG_COOKIE, data.payload.registration.token, cookieOptions(req, 60 * 30));
    return res;
  }

  return NextResponse.json({ message: "Kutilmagan javob" }, { status: 500 });
}
