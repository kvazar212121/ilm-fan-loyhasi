import { NextRequest, NextResponse } from "next/server";

import {
  backendFetch,
  cookieOptions,
  REG_COOKIE,
  setSessionCookies,
  type BackendTokens,
} from "@/lib/auth/server";

type RegisterPayload = {
  status: string;
  tokens?: BackendTokens;
  user?: unknown;
};

export async function POST(req: NextRequest) {
  const token = req.cookies.get(REG_COOKIE)?.value;
  if (!token) {
    return NextResponse.json({ message: "Ro'yxatdan o'tish tokeni eskirgan, qayta kiring" }, { status: 401 });
  }
  const body = await req.json().catch(() => ({}));
  const { status, data } = await backendFetch<RegisterPayload>(req, "/api/v1/auth/register", {
    method: "POST",
    body: {
      registration_token: token,
      role: body.role,
      fan_ids: Array.isArray(body.fan_ids) ? body.fan_ids : [],
      first_name: body.first_name,
      last_name: body.last_name || "",
      phone: body.phone || "",
      birth_date: body.birth_date || "",
      region: body.region || "",
      gender: body.gender || "",
      avatar_url: body.avatar_url || "",
    },
  });
  if (!data.success || !data.payload?.tokens) {
    return NextResponse.json({ message: data.message || "Ro'yxatdan o'tishda xatolik" }, { status });
  }

  const res = NextResponse.json({ status: "authenticated", user: data.payload.user }, { status: 201 });
  res.cookies.set(REG_COOKIE, "", cookieOptions(req, 0));
  setSessionCookies(req, res, data.payload.tokens);
  return res;
}
