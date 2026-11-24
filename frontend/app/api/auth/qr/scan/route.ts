import { NextRequest, NextResponse } from "next/server";

import { backendFetch } from "@/lib/auth/server";

type ScanPayload = {
  status: string;
  desktop_device: string;
  desktop_ip?: string;
  expires_at: string;
};

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const qrToken = typeof body.qr_token === "string" ? body.qr_token : "";
  const { status, data } = await backendFetch<ScanPayload>(req, "/api/v1/auth/qr/scan", {
    method: "POST",
    body: { qr_token: qrToken },
  });
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "QR kod yaroqsiz" }, { status });
  }
  return NextResponse.json(data.payload);
}
