"use client";

import { useState, type FormEvent } from "react";

import { PaperSheet, type PaperQuestion } from "@/components/teacher/PaperSheet";

const emptyChoices = ["", "", "", ""];

export function PaperTest() {
  const [title, setTitle] = useState("");
  const [prompt, setPrompt] = useState("");
  const [choices, setChoices] = useState(emptyChoices);
  const [questions, setQuestions] = useState<PaperQuestion[]>([]);

  function addQuestion(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const nextPrompt = prompt.trim();
    if (!nextPrompt) {
      return;
    }
    setQuestions((current) => [
      ...current,
      { id: crypto.randomUUID(), prompt: nextPrompt, choices: [...choices] },
    ]);
    setPrompt("");
    setChoices(emptyChoices);
  }

  return (
    <section className="flex flex-col gap-4">
      <form onSubmit={addQuestion} className="no-print flex flex-col gap-2 rounded-2xl border border-line bg-white p-5">
        <input
          value={title}
          onChange={(event) => setTitle(event.target.value)}
          placeholder="Test nomi"
          className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
        />
        <input
          value={prompt}
          onChange={(event) => setPrompt(event.target.value)}
          placeholder="Savol"
          className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
        />
        <div className="grid gap-2 sm:grid-cols-2">
          {choices.map((choice, index) => (
            <input
              key={index}
              value={choice}
              onChange={(event) =>
                setChoices((current) =>
                  current.map((item, itemIndex) =>
                    itemIndex === index ? event.target.value : item,
                  ),
                )
              }
              placeholder={`${String.fromCharCode(65 + index)} variant`}
              className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
            />
          ))}
        </div>
        <div className="flex flex-wrap gap-2">
          <button
            type="submit"
            className="rounded-full bg-accent px-4 py-2 text-sm font-medium text-white"
          >
            Savol qo‘shish
          </button>
          <button
            type="button"
            onClick={() => window.print()}
            className="rounded-full border border-line px-4 py-2 text-sm font-medium"
          >
            Qog‘ozga chiqarish
          </button>
        </div>
      </form>
      <PaperSheet title={title} questions={questions} />
    </section>
  );
}
