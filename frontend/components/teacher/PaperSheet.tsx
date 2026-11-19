export type PaperQuestion = {
  id: string;
  prompt: string;
  choices: string[];
};

type PaperSheetProps = {
  title: string;
  questions: PaperQuestion[];
};

export function PaperSheet({ title, questions }: PaperSheetProps) {
  return (
    <article className="paper-sheet rounded-2xl border border-line bg-white p-6">
      <p className="text-xs tracking-[0.16em] text-ink/45 uppercase">Qog‘oz testi</p>
      <h3 className="mt-2 text-2xl font-semibold">{title.trim() || "Test nomi"}</h3>
      <p className="mt-4 text-sm">Ism: ____________________ &nbsp;&nbsp; Sinf: __________</p>
      {questions.length === 0 ? (
        <p className="mt-6 text-sm text-ink/55">Savol qo‘shilganda varaq shu yerda yig‘iladi.</p>
      ) : (
        <ol className="mt-6 flex flex-col gap-5">
          {questions.map((question, index) => (
            <li key={question.id}>
              <p className="font-medium">
                {index + 1}. {question.prompt}
              </p>
              <ul className="mt-2 grid gap-1 text-sm sm:grid-cols-2">
                {question.choices.map((choice, choiceIndex) => (
                  <li key={choiceIndex}>
                    {String.fromCharCode(65 + choiceIndex)}) {choice || "________"}
                  </li>
                ))}
              </ul>
            </li>
          ))}
        </ol>
      )}
    </article>
  );
}
