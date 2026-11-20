import { connection } from "next/server";

import { sampleQuiz } from "@/lib/quiz/sample";
import type { PublicQuiz } from "@/lib/quiz/types";

export function GET() {
  const quiz: PublicQuiz = {
    id: sampleQuiz.id,
    title: sampleQuiz.title,
    questions: sampleQuiz.questions.map(({ id, prompt, choices }) => ({
      id,
      prompt,
      choices,
    })),
  };
  return Response.json(quiz);
}

export async function POST(request: Request) {
  await connection();
  const body = (await request.json()) as { questionId?: string; choiceId?: string };
  const question = sampleQuiz.questions.find((item) => item.id === body.questionId);
  if (!question || !body.choiceId) {
    return Response.json({ error: "Savol topilmadi" }, { status: 400 });
  }
  if (!question.choices.some((choice) => choice.id === body.choiceId)) {
    return Response.json({ error: "Variant topilmadi" }, { status: 400 });
  }
  return Response.json({
    correct: body.choiceId === question.correctId,
    correctId: question.correctId,
  });
}
