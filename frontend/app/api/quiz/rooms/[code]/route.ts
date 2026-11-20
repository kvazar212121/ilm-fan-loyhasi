import { connection } from "next/server";

import { answerRoom, joinRoom, nextRoom, readRoom, startRoom } from "@/lib/quiz/rooms";

type ActionBody = {
  action?: "join" | "start" | "answer" | "next";
  playerId?: string;
  name?: string;
  choiceId?: string;
};

export async function GET(
  request: Request,
  context: { params: Promise<{ code: string }> },
) {
  await connection();
  const { code } = await context.params;
  const playerId = new URL(request.url).searchParams.get("playerId") ?? "";
  const room = readRoom(code.toUpperCase(), playerId);
  if (!room) return Response.json({ error: "Xona topilmadi" }, { status: 404 });
  return Response.json(room);
}

export async function POST(
  request: Request,
  context: { params: Promise<{ code: string }> },
) {
  await connection();
  const { code } = await context.params;
  const body = (await request.json()) as ActionBody;
  const roomCode = code.toUpperCase();
  const playerId = body.playerId?.trim() ?? "";
  if (!playerId) return Response.json({ error: "O‘yinchi aniqlanmadi" }, { status: 400 });
  if (body.action === "join" && (body.name?.trim().length ?? 0) < 2) {
    return Response.json({ error: "Ismingizni yozing" }, { status: 400 });
  }

  const error =
    body.action === "join"
      ? joinRoom(roomCode, playerId, body.name?.trim() ?? "")
      : body.action === "start"
        ? startRoom(roomCode, playerId)
        : body.action === "answer"
          ? answerRoom(roomCode, playerId, body.choiceId ?? "")
          : body.action === "next"
            ? nextRoom(roomCode, playerId)
            : "Noma’lum amal";

  if (error) return Response.json({ error }, { status: 400 });
  return Response.json(readRoom(roomCode, playerId));
}
