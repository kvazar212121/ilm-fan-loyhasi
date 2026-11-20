import { connection } from "next/server";

import { createRace, type RaceDraft } from "@/lib/quiz/race";

export async function POST(request: Request) {
  await connection();
  const body = (await request.json()) as {
    playerId?: string;
    title?: string;
    questions?: RaceDraft[];
  };
  const playerId = body.playerId?.trim() ?? "";
  const title = body.title?.trim() ?? "";
  const questions = Array.isArray(body.questions) ? body.questions : [];
  if (!playerId) return Response.json({ error: "O‘qituvchi aniqlanmadi" }, { status: 400 });
  if (title.length < 2) return Response.json({ error: "Test nomini yozing" }, { status: 400 });
  if (questions.length < 1) return Response.json({ error: "Kamida bitta savol qo‘shing" }, { status: 400 });
  const drafts = questions.map((question) => ({
    prompt: question.prompt?.trim() ?? "",
    choices: (question.choices ?? []).map((choice) => choice.trim()),
    correctIndex: question.correctIndex,
  }));
  const invalid = drafts.some(
    (question) =>
      question.prompt.length < 2 ||
      question.choices.length < 2 ||
      question.choices.some((choice) => choice.length < 1) ||
      question.correctIndex < 0 ||
      question.correctIndex >= question.choices.length,
  );
  if (invalid) return Response.json({ error: "Har savolda matn, variant va to‘g‘ri javob bo‘lsin" }, { status: 400 });
  return Response.json({ code: createRace(playerId, title, drafts) });
}
