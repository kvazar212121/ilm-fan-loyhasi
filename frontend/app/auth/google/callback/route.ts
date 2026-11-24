import { NextRequest, NextResponse } from "next/server";

import {
  backendAuthFetch,
  backendFetch,
  cookieOptions,
  getPublicOrigin,
  GOOGLE_COOKIE,
  REG_COOKIE,
  setSessionCookies,
  type BackendTokens,
} from "@/lib/auth/server";

type GoogleCallbackPayload = {
  status: "authenticated" | "registration_required";
  tokens?: BackendTokens;
  registration?: { token: string; expires_at: string };
};

type SavedGoogleCookie = {
  state?: string;
  code_verifier?: string;
  mode?: "login" | "link" | "qr";
  qr_token?: string;
};

function redirectWithClear(req: NextRequest, path: string, query: string) {
  const origin = getPublicOrigin(req);
  const res = NextResponse.redirect(`${origin}${path}?${query}`);
  res.cookies.set(GOOGLE_COOKIE, "", cookieOptions(req, 0));
  return res;
}

export async function GET(req: NextRequest) {
  const rawCookie = req.cookies.get(GOOGLE_COOKIE)?.value;
  let saved: SavedGoogleCookie = {};
  try {
    if (rawCookie) saved = JSON.parse(rawCookie);
  } catch {
    saved = {};
  }
  const isLink = saved.mode === "link";
  const isQR = saved.mode === "qr" && Boolean(saved.qr_token);
  const qrPath = isQR ? `/login/qr/${encodeURIComponent(saved.qr_token || "")}` : "";
  const targetPath = isLink ? "/profile" : isQR ? qrPath : "/login";
  const errKey = isLink ? "link_error" : "error";

  if (req.nextUrl.searchParams.get("error")) {
    return redirectWithClear(req, targetPath, `${errKey}=${encodeURIComponent("Google tasdiqlash bekor qilindi")}`);
  }

  const code = req.nextUrl.searchParams.get("code") || "";
  const state = req.nextUrl.searchParams.get("state") || "";
  if (!code || !state || !saved.state || saved.state !== state || !saved.code_verifier) {
    return redirectWithClear(req, targetPath, `${errKey}=${encodeURIComponent("Google sessiyasi eskirgan, qayta urining")}`);
  }

  if (isLink) {
    const linked = await backendAuthFetch<{ merged?: boolean; tokens?: BackendTokens }>(
      req,
      "/api/v1/auth/me/google/link",
      { method: "POST", body: { code, code_verifier: saved.code_verifier } },
    );
    if (!linked.data.success) {
      return redirectWithClear(req, "/profile", `link_error=${encodeURIComponent(linked.data.message || "Google ulashda xatolik")}`);
    }
    const query = linked.data.payload?.merged ? "linked=google&merged=1" : "linked=google";
    const res = redirectWithClear(req, "/profile", query);
    if (linked.data.payload?.tokens) setSessionCookies(req, res, linked.data.payload.tokens);
    else if (linked.rotated) setSessionCookies(req, res, linked.rotated);
    return res;
  }

  const { data } = await backendFetch<GoogleCallbackPayload>(req, "/api/v1/auth/google/callback", {
    method: "POST",
    body: { code, code_verifier: saved.code_verifier },
  });
  if (!data.success || !data.payload) {
    return redirectWithClear(req, targetPath, `error=${encodeURIComponent(data.message || "Google kirishda xatolik")}`);
  }

  const origin = getPublicOrigin(req);
  if (isQR && saved.qr_token) {
    if (data.payload.status === "authenticated" && data.payload.tokens) {
      const app = await backendFetch(req, "/api/v1/auth/qr/approve-session", {
        method: "POST",
        bearer: data.payload.tokens.access_token,
        body: { qr_token: saved.qr_token },
      });
      if (!app.data.success) {
        return redirectWithClear(req, qrPath, `error=${encodeURIComponent(app.data.message || "QR tasdiqlanmadi")}`);
      }
      const res = redirectWithClear(req, qrPath, "done=1");
      setSessionCookies(req, res, data.payload.tokens);
      return res;
    }
    if (data.payload.status === "registration_required" && data.payload.registration?.token) {
      const app = await backendFetch(req, "/api/v1/auth/qr/approve-registration", {
        method: "POST",
        body: { qr_token: saved.qr_token, registration_token: data.payload.registration.token },
      });
      if (!app.data.success) {
        return redirectWithClear(req, qrPath, `error=${encodeURIComponent(app.data.message || "QR tasdiqlanmadi")}`);
      }
      return redirectWithClear(req, qrPath, "done=1&new=1");
    }
    return redirectWithClear(req, qrPath, `error=${encodeURIComponent("Kutilmagan javob qaytdi")}`);
  }

  if (data.payload.status === "authenticated" && data.payload.tokens) {
    const res = NextResponse.redirect(`${origin}/login?auth=done`);
    res.cookies.set(GOOGLE_COOKIE, "", cookieOptions(req, 0));
    setSessionCookies(req, res, data.payload.tokens);
    return res;
  }
  if (data.payload.status === "registration_required" && data.payload.registration?.token) {
    const res = NextResponse.redirect(`${origin}/login?step=register&method=google`);
    res.cookies.set(GOOGLE_COOKIE, "", cookieOptions(req, 0));
    res.cookies.set(REG_COOKIE, data.payload.registration.token, cookieOptions(req, 60 * 30));
    return res;
  }
  return redirectWithClear(req, "/login", `error=${encodeURIComponent("Kutilmagan javob qaytdi")}`);
}
