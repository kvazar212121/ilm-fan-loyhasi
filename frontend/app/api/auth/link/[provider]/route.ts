import { NextRequest, NextResponse } from "next/server";

import { backendAuthFetch, setSessionCookies } from "@/lib/auth/server";

type Params = { params: Promise<{ provider: string }> };

export async function DELETE(req: NextRequest, { params }: Params) {
  const { provider } = await params;
  const { status, data, rotated } = await backendAuthFetch(
    req,
    `/api/v1/auth/me/methods/${encodeURIComponent(provider)}`,
    { method: "DELETE" },
  );
  if (!data.success || !data.payload) {
    return NextResponse.json({ message: data.message || "Usulni uzishda xatolik" }, { status });
  }
  const res = NextResponse.json(data.payload);
  if (rotated) setSessionCookies(req, res, rotated);
  return res;
}
