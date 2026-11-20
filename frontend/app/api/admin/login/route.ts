import { connection } from "next/server";

import { passwordOk, setAdminCookie } from "@/lib/admin/auth";

export async function POST(request: Request) {
  await connection();
  const body = (await request.json()) as { password?: string };
  if (!passwordOk(body.password?.trim() ?? "")) {
    return Response.json({ error: "Parol noto‘g‘ri" }, { status: 401 });
  }
  await setAdminCookie();
  return Response.json({ ok: true });
}
