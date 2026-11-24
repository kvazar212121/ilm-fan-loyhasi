import { NextRequest, NextResponse } from "next/server";

import {
  ACCESS_COOKIE,
  backendFetch,
  clearSessionCookies,
  REFRESH_COOKIE,
} from "@/lib/auth/server";

export async function POST(req: NextRequest) {
  const access = req.cookies.get(ACCESS_COOKIE)?.value;
  const refresh = req.cookies.get(REFRESH_COOKIE)?.value;
  if (access) {
    await backendFetch(req, "/api/v1/auth/logout", {
      method: "POST",
      bearer: access,
      body: { refresh_token: refresh || "" },
    }).catch(() => {});
  }
  const res = NextResponse.json({ ok: true });
  clearSessionCookies(req, res);
  return res;
}
