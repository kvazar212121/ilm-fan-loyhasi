import { NextRequest, NextResponse } from "next/server";

import {
  ACCESS_COOKIE,
  backendFetch,
  REFRESH_COOKIE,
  setSessionCookies,
  type BackendTokens,
} from "@/lib/auth/server";

export async function PUT(req: NextRequest) {
  let access = req.cookies.get(ACCESS_COOKIE)?.value || "";
  const refresh = req.cookies.get(REFRESH_COOKIE)?.value || "";
  const body = await req.json().catch(() => ({}));
  const payload = {
    first_name: body.first_name,
    last_name: body.last_name,
    phone: body.phone || "",
    birth_date: body.birth_date,
    region: body.region,
    gender: body.gender,
    avatar_url: body.avatar_url || "",
  };

  if (access) {
    const res = await backendFetch(req, "/api/v1/auth/me/profile", {
      method: "PUT",
      bearer: access,
      body: payload,
    });
    if (res.data.success && res.data.payload) {
      return NextResponse.json(res.data.payload);
    }
    if (res.status !== 401) {
      return NextResponse.json({ message: res.data.message || "Saqlashda xatolik" }, { status: res.status });
    }
  }

  if (refresh) {
    const rotated = await backendFetch<BackendTokens>(req, "/api/v1/auth/refresh", {
      method: "POST",
      body: { refresh_token: refresh },
    });
    if (rotated.data.success && rotated.data.payload) {
      access = rotated.data.payload.access_token;
      const retry = await backendFetch(req, "/api/v1/auth/me/profile", {
        method: "PUT",
        bearer: access,
        body: payload,
      });
      if (retry.data.success && retry.data.payload) {
        const out = NextResponse.json(retry.data.payload);
        setSessionCookies(req, out, rotated.data.payload);
        return out;
      }
      return NextResponse.json(
        { message: retry.data.message || "Saqlashda xatolik" },
        { status: retry.status },
      );
    }
  }

  return NextResponse.json({ message: "Sessiya tugagan, qayta kiring" }, { status: 401 });
}
