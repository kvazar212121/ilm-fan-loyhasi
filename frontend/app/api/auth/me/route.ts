import { NextRequest, NextResponse } from "next/server";

import {
  ACCESS_COOKIE,
  backendFetch,
  REFRESH_COOKIE,
  setSessionCookies,
  type BackendTokens,
} from "@/lib/auth/server";

export async function GET(req: NextRequest) {
  let access = req.cookies.get(ACCESS_COOKIE)?.value || "";
  const refresh = req.cookies.get(REFRESH_COOKIE)?.value || "";
  let refreshedTokens: BackendTokens | null = null;

  if (access) {
    const me = await backendFetch(req, "/api/v1/auth/me", { bearer: access });
    if (me.data.success && me.data.payload) {
      return NextResponse.json(me.data.payload);
    }
  }

  if (refresh) {
    const rotated = await backendFetch<BackendTokens>(req, "/api/v1/auth/refresh", {
      method: "POST",
      body: { refresh_token: refresh },
    });
    if (rotated.data.success && rotated.data.payload) {
      refreshedTokens = rotated.data.payload;
      access = refreshedTokens.access_token;
      const me = await backendFetch(req, "/api/v1/auth/me", { bearer: access });
      if (me.data.success && me.data.payload) {
        const res = NextResponse.json(me.data.payload);
        setSessionCookies(req, res, refreshedTokens);
        return res;
      }
    }
  }

  return NextResponse.json({ message: "Kirilmagan" }, { status: 401 });
}
