"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { useQuizPlayerId } from "@/components/tests/use-quiz-player";

type Draft = { prompt: string; choices: string[]; correctIndex: number };

const emptyChoices = ["", "", "", ""];

export function RaceBuilder() {
  const router = useRouter();
  const playerId = useQuizPlayerId();
  const [title, setTitle] = useState("");
  const [prompt, setPrompt] = useState("");
  const [choices, setChoices] = useState(emptyChoices);
  const [correctIndex, setCorrectIndex] = useState(0);
  const [questions, setQuestions] = useState<Draft[]>([]);
  const [error, setError] = useState("");

  function addQuestion() {
    const nextChoices = choices.map((choice) => choice.trim());
    if (prompt.trim().length < 2 || nextChoices.some((choice) => !choice)) {
      setError("Savol va to‘rtta variantni to‘ldiring");
      return;
    }
    setQuestions((current) => [...current, { prompt: prompt.trim(), choices: nextChoices, correctIndex }]);
    setPrompt("");
    setChoices(emptyChoices);
    setCorrectIndex(0);
    setError("");
  }

  async function publish() {
    if (!playerId) return;
    setError("");
    const response = await fetch("/api/quiz/race", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ playerId, title, questions }),
    });
    const body = (await response.json()) as { code?: string; error?: string };
    if (!response.ok || !body.code) {
      setError(body.error ?? "Link ochilmadi");
      return;
    }
    router.push(`/tests/race/${body.code}?view=screen`);
  }

  return (
    <div className="flex flex-col gap-4">
      <input
        value={title}
        onChange={(event) => setTitle(event.target.value)}
        placeholder="Test nomi"
        className="rounded-2xl border border-line bg-white px-4 py-3 text-sm outline-none focus:border-accent"
      />
      <form
        className="flex flex-col gap-2 rounded-2xl border border-line bg-white p-5"
        onSubmit={(event) => {
          event.preventDefault();
          addQuestion();
        }}
      >
        <input
          value={prompt}
          onChange={(event) => setPrompt(event.target.value)}
          placeholder="Savol"
          className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
        />
        {choices.map((choice, index) => (
          <label key={index} className="flex items-center gap-2">
            <input
              type="radio"
              name="correct"
              checked={correctIndex === index}
              onChange={() => setCorrectIndex(index)}
            />
            <input
              value={choice}
              onChange={(event) =>
                setChoices((current) => current.map((item, itemIndex) => (itemIndex === index ? event.target.value : item)))
              }
              placeholder={`${String.fromCharCode(65 + index)} variant`}
              className="w-full rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
            />
          </label>
        ))}
        <button type="submit" className="w-fit rounded-full border border-line px-4 py-2 text-sm font-medium">
          Savol qo‘shish
        </button>
      </form>
      <ol className="flex flex-col gap-2 text-sm">
        {questions.map((question, index) => (
          <li key={`${question.prompt}-${index}`} className="rounded-xl border border-line bg-white px-4 py-3">
            {index + 1}. {question.prompt}
          </li>
        ))}
      </ol>
      {error ? <p className="text-sm text-red-800">{error}</p> : null}
      <button
        type="button"
        onClick={() => void publish()}
        className="w-fit rounded-full bg-accent px-5 py-3 text-sm font-medium text-white"
      >
        Ekran linkini olish
      </button>
    </div>
  );
}
