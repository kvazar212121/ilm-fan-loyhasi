import type { Metadata } from "next";

import { IndividualQuiz } from "@/components/tests/IndividualQuiz";
import { sampleQuiz } from "@/lib/quiz/sample";
import type { PublicQuiz } from "@/lib/quiz/types";

export const metadata: Metadata = {
  title: "Individual test",
};

const quiz: PublicQuiz = {
  id: sampleQuiz.id,
  title: sampleQuiz.title,
  questions: sampleQuiz.questions.map(({ id, prompt, choices }) => ({
    id,
    prompt,
    choices,
  })),
};

export default function IndividualTestPage() {
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-16">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Individual</p>
        <h1 className="text-3xl font-semibold tracking-tight">{quiz.title}</h1>
        <p className="text-ink/70">Javobni belgilang. To‘g‘ri variant shu yerda yashil bo‘lib ochiladi.</p>
      </div>
      <IndividualQuiz quiz={quiz} />
    </section>
  );
}
