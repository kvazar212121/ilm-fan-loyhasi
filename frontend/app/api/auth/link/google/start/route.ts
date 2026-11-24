import { NextRequest, NextResponse } from "next/server";

import { backendFetch, cookieOptions, GOOGLE_COOKIE } from "@/lib/auth/server";

type GoogleStartPayload = {
  authorization_url: string;
  state: string;
  code_verifier: string;
};

export async function POST(req: NextRequest) {
  const { status, data } = await backendFetch<GoogleStartPayload>(req, "/api/v1/auth/google/start", {
    method: "POST",
    body: {},
  });
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Google ulashni boshlab bo'lmadi" }, { status });
  }

  const res = NextResponse.json({ authorization_url: data.payload.authorization_url });
  res.cookies.set(
    GOOGLE_COOKIE,
    JSON.stringify({
      state: data.payload.state,
      code_verifier: data.payload.code_verifier,
      mode: "link",
    }),
    cookieOptions(req, 60 * 10),
  );
  return res;
}
