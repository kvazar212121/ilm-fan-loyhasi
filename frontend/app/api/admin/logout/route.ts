import { connection } from "next/server";

import { clearAdminCookie } from "@/lib/admin/auth";

export async function POST() {
  await connection();
  await clearAdminCookie();
  return Response.json({ ok: true });
}
