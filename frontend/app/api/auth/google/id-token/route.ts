import { NextRequest, NextResponse } from "next/server";

import {
  backendFetch,
  cookieOptions,
  REG_COOKIE,
  setSessionCookies,
  type BackendTokens,
} from "@/lib/auth/server";

type GoogleIDTokenPayload = {
  status: "authenticated" | "registration_required";
  tokens?: BackendTokens;
  user?: unknown;
  registration?: { token: string };
};

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const idToken = typeof body?.id_token === "string" ? body.id_token.trim() : "";
  if (!idToken) {
    return NextResponse.json({ message: "Google ID token kerak" }, { status: 400 });
  }

  const { status, data } = await backendFetch<GoogleIDTokenPayload>(
    req,
    "/api/v1/auth/google/id-token",
    {
      method: "POST",
      body: { id_token: idToken },
    },
  );
  if (!data.success || !data.payload) {
    return NextResponse.json(
      { message: data.message || "Google token tasdiqlanmadi" },
      { status },
    );
  }

  if (data.payload.status === "authenticated" && data.payload.tokens) {
    const res = NextResponse.json({ status: "authenticated", user: data.payload.user });
    setSessionCookies(req, res, data.payload.tokens);
    return res;
  }

  if (data.payload.status === "registration_required" && data.payload.registration?.token) {
    const res = NextResponse.json({ status: "registration_required" });
    res.cookies.set(REG_COOKIE, data.payload.registration.token, cookieOptions(req, 60 * 30));
    return res;
  }

  return NextResponse.json({ message: "Kutilmagan javob" }, { status: 500 });
}
