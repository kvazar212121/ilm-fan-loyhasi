import { NextRequest, NextResponse } from "next/server";

import { backendFetch } from "@/lib/auth/server";

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const { status, data } = await backendFetch<{
    error?: string;
    details?: { retry_after_seconds?: number };
  }>(req, "/api/v1/auth/otp/sms", {
    method: "POST",
    body: { phone: body.phone },
  });
  if (!data.success) {
    return NextResponse.json(
      {
        message: data.message || "SMS yuborishda xatolik",
        retry_after_seconds: data.payload?.details?.retry_after_seconds,
      },
      { status },
    );
  }
  return NextResponse.json(data.payload);
}
