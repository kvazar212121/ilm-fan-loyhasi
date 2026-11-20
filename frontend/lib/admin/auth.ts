import { createHash, timingSafeEqual } from "node:crypto";
import { readFileSync } from "node:fs";
import path from "node:path";

import { cookies } from "next/headers";

const cookieName = "ilm-admin";

function adminPassword() {
  if (process.env.ADMIN_PASSWORD) return process.env.ADMIN_PASSWORD;
  try {
    const raw = readFileSync(path.join(process.cwd(), ".env.local"), "utf8");
    const line = raw.split("\n").find((item) => item.startsWith("ADMIN_PASSWORD="));
    return line?.slice("ADMIN_PASSWORD=".length).trim() ?? "";
  } catch {
    return "";
  }
}

function digest(value: string) {
  return createHash("sha256").update(value).digest();
}

export function passwordOk(input: string) {
  const expected = adminPassword();
  if (!expected || !input) return false;
  return timingSafeEqual(digest(input), digest(expected));
}

function token() {
  const secret = adminPassword();
  return createHash("sha256").update(`ilm-admin:${secret}`).digest("hex");
}

export async function setAdminCookie() {
  const jar = await cookies();
  jar.set(cookieName, token(), {
    httpOnly: true,
    sameSite: "lax",
    path: "/",
    secure: process.env.NODE_ENV === "production",
    maxAge: 60 * 60 * 24 * 14,
  });
}

export async function clearAdminCookie() {
  const jar = await cookies();
  jar.delete(cookieName);
}

export async function isAdmin() {
  const jar = await cookies();
  const value = jar.get(cookieName)?.value ?? "";
  const expected = token();
  if (!adminPassword() || value.length !== expected.length) return false;
  return timingSafeEqual(Buffer.from(value), Buffer.from(expected));
}
