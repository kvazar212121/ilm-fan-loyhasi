import { NextRequest, NextResponse } from "next/server";

import { backendFetch } from "@/lib/auth/server";

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const qrToken = typeof body.qr_token === "string" ? body.qr_token : "";
  const { status, data } = await backendFetch(req, "/api/v1/auth/qr/reject", {
    method: "POST",
    body: { qr_token: qrToken },
  });
  if (!data.success) {
    return NextResponse.json({ message: data.message || "Rad etib bo‘lmadi" }, { status });
  }
  return NextResponse.json({ ok: true });
}
