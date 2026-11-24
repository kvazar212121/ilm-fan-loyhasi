import { NextRequest, NextResponse } from "next/server";

export const ACCESS_COOKIE = "ilm_access";
export const REFRESH_COOKIE = "ilm_refresh";
export const REG_COOKIE = "ilm_reg_token";
export const GOOGLE_COOKIE = "ilm_google_oauth";
export const TELEGRAM_COOKIE = "ilm_tg_attempt";
export const QR_COOKIE = "ilm_qr_attempt";

const BACKEND_URL = (process.env.BACKEND_API_URL || "http://127.0.0.1:8080").replace(/\/$/, "");

export type BackendEnvelope<T = unknown> = {
  code: string;
  success: boolean;
  payload?: T;
  message?: string;
};

export type BackendTokens = {
  access_token: string;
  refresh_token: string;
  expires_at: string;
};

export function isHttpsRequest(req: NextRequest): boolean {
  const proto = req.headers.get("x-forwarded-proto");
  if (proto) return proto.split(",")[0].trim() === "https";
  return req.nextUrl.protocol === "https:";
}

export function getPublicOrigin(req: NextRequest): string {
  const proto = req.headers.get("x-forwarded-proto")?.split(",")[0].trim() || req.nextUrl.protocol.replace(":", "");
  const host = req.headers.get("x-forwarded-host")?.split(",")[0].trim() || req.headers.get("host") || req.nextUrl.host;
  return `${proto}://${host}`;
}

export function cookieOptions(req: NextRequest, maxAge: number) {
  return {
    httpOnly: true,
    sameSite: "lax" as const,
    secure: isHttpsRequest(req),
    path: "/",
    maxAge,
  };
}

export function setSessionCookies(req: NextRequest, res: NextResponse, tokens: BackendTokens) {
  res.cookies.set(ACCESS_COOKIE, tokens.access_token, cookieOptions(req, 60 * 60 * 10));
  res.cookies.set(REFRESH_COOKIE, tokens.refresh_token, cookieOptions(req, 60 * 60 * 24 * 7));
}

export function clearSessionCookies(req: NextRequest, res: NextResponse) {
  for (const name of [ACCESS_COOKIE, REFRESH_COOKIE, REG_COOKIE, GOOGLE_COOKIE, TELEGRAM_COOKIE, QR_COOKIE]) {
    res.cookies.set(name, "", cookieOptions(req, 0));
  }
}

export async function backendFetch<T = unknown>(
  req: NextRequest,
  path: string,
  init: { method?: string; body?: unknown; bearer?: string } = {},
): Promise<{ status: number; data: BackendEnvelope<T> }> {
  const headers: Record<string, string> = { Accept: "application/json" };
  if (init.body !== undefined) headers["Content-Type"] = "application/json";
  if (init.bearer) headers["Authorization"] = `Bearer ${init.bearer}`;

  const fwd = req.headers.get("x-forwarded-for");
  if (fwd) headers["X-Forwarded-For"] = fwd;
  const ua = req.headers.get("user-agent");
  if (ua) headers["User-Agent"] = ua;

  const upstream = await fetch(`${BACKEND_URL}${path}`, {
    method: init.method || "GET",
    headers,
    body: init.body !== undefined ? JSON.stringify(init.body) : undefined,
    cache: "no-store",
  });
  const data = (await upstream.json().catch(() => ({
    code: "BAD_GATEWAY",
    success: false,
    message: "Backend javobi o'qilmadi",
  }))) as BackendEnvelope<T>;
  return { status: upstream.status, data };
}

export async function backendAuthFetch<T = unknown>(
  req: NextRequest,
  path: string,
  init: { method?: string; body?: unknown } = {},
): Promise<{ status: number; data: BackendEnvelope<T>; rotated?: BackendTokens }> {
  let access = req.cookies.get(ACCESS_COOKIE)?.value || "";
  const refresh = req.cookies.get(REFRESH_COOKIE)?.value || "";

  if (access) {
    const res = await backendFetch<T>(req, path, { ...init, bearer: access });
    if (res.status !== 401) return res;
  }

  if (refresh) {
    const rot = await backendFetch<BackendTokens>(req, "/api/v1/auth/refresh", {
      method: "POST",
      body: { refresh_token: refresh },
    });
    if (rot.data.success && rot.data.payload) {
      access = rot.data.payload.access_token;
      const retry = await backendFetch<T>(req, path, { ...init, bearer: access });
      return { ...retry, rotated: rot.data.payload };
    }
  }

  return {
    status: 401,
    data: { code: "UNAUTHORIZED", success: false, message: "Sessiya tugagan, qayta kiring" },
  };
}
