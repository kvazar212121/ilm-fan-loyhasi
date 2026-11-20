import { connection } from "next/server";

import { createRoom } from "@/lib/quiz/rooms";

export async function POST(request: Request) {
  await connection();
  const body = (await request.json()) as {
    playerId?: string;
    name?: string;
    seconds?: number;
  };
  const name = body.name?.trim() ?? "";
  const playerId = body.playerId?.trim() ?? "";
  const seconds = Number(body.seconds);
  if (!playerId || name.length < 2) {
    return Response.json({ error: "Ismingizni yozing" }, { status: 400 });
  }
  if (!Number.isFinite(seconds) || seconds < 5 || seconds > 60) {
    return Response.json({ error: "Vaqt 5 dan 60 soniyagacha bo‘lsin" }, { status: 400 });
  }
  const code = createRoom(playerId, name, Math.round(seconds));
  return Response.json({ code });
}
