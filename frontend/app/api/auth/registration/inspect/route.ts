import { NextRequest, NextResponse } from "next/server";

import { backendFetch, REG_COOKIE } from "@/lib/auth/server";

export async function GET(req: NextRequest) {
  const token = req.cookies.get(REG_COOKIE)?.value;
  if (!token) {
    return NextResponse.json({ message: "Ro'yxatdan o'tish sessiyasi topilmadi" }, { status: 401 });
  }
  const { status, data } = await backendFetch(req, "/api/v1/auth/registration/inspect", {
    method: "POST",
    body: { registration_token: token },
  });
  if (!data.success) {
    return NextResponse.json({ message: data.message || "Token eskirgan" }, { status });
  }
  return NextResponse.json(data.payload);
}
