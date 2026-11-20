"use client";

import { useState } from "react";

import { ChoiceButtons } from "@/components/tests/ChoiceButtons";
import type { PublicQuiz } from "@/lib/quiz/types";

type Check = { correct: boolean; correctId: string };

export function IndividualQuiz({ quiz }: { quiz: PublicQuiz }) {
  const [index, setIndex] = useState(0);
  const [pickedId, setPickedId] = useState<string | null>(null);
  const [check, setCheck] = useState<Check | null>(null);
  const [score, setScore] = useState(0);
  const [error, setError] = useState("");
  const question = quiz.questions[index];
  const finished = index >= quiz.questions.length;

  async function pick(choiceId: string) {
    if (!question || pickedId) return;
    setPickedId(choiceId);
    setError("");
    const response = await fetch("/api/quiz/individual", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ questionId: question.id, choiceId }),
    });
    const body = (await response.json()) as Check & { error?: string };
    if (!response.ok || !body.correctId) {
      setError(body.error ?? "Javob tekshirilmadi");
      setPickedId(null);
      return;
    }
    setCheck(body);
    if (body.correct) setScore((current) => current + 1);
  }

  function next() {
    setIndex((current) => current + 1);
    setPickedId(null);
    setCheck(null);
  }

  if (finished) {
    return (
      <section className="flex flex-col gap-3 rounded-2xl border border-line bg-white p-6">
        <h2 className="text-2xl font-semibold">Yakunlandi</h2>
        <p className="text-ink/75">
          {score} / {quiz.questions.length} ta to‘g‘ri.
        </p>
      </section>
    );
  }

  return (
    <section className="flex flex-col gap-4 rounded-2xl border border-line bg-white p-6">
      <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
        Savol {index + 1} / {quiz.questions.length}
      </p>
      <h2 className="text-xl font-semibold">{question.prompt}</h2>
      <ChoiceButtons
        choices={question.choices.map((choice) => ({ ...choice, count: 0 }))}
        pickedId={pickedId}
        correctId={check?.correctId ?? null}
        revealed={Boolean(check)}
        disabled={Boolean(pickedId)}
        showCounts={false}
        onPick={pick}
      />
      {error ? <p className="text-sm text-red-800">{error}</p> : null}
      {check ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm font-medium">
            {check.correct ? "To‘g‘ri topdingiz." : "Xato qildingiz. Yashil variant to‘g‘ri javob."}
          </p>
          <button
            type="button"
            onClick={next}
            className="rounded-full bg-accent px-4 py-2 text-sm font-medium text-white"
          >
            {index + 1 === quiz.questions.length ? "Natija" : "Keyingi savol"}
          </button>
        </div>
      ) : null}
    </section>
  );
}
