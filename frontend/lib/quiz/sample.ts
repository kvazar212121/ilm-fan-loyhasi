import type { QuizQuestion } from "@/lib/quiz/types";

export const sampleQuiz = {
  id: "fan-mashq",
  title: "Fan bo‘yicha qisqa mashq",
  questions: [
    {
      id: "q1",
      prompt: "Suvning kimyoviy formulasi qaysi?",
      correctId: "b",
      choices: [
        { id: "a", text: "CO2" },
        { id: "b", text: "H2O" },
        { id: "c", text: "NaCl" },
        { id: "d", text: "O2" },
      ],
    },
    {
      id: "q2",
      prompt: "Odam organizmida nechta o‘pka bor?",
      correctId: "b",
      choices: [
        { id: "a", text: "1" },
        { id: "b", text: "2" },
        { id: "c", text: "3" },
        { id: "d", text: "4" },
      ],
    },
    {
      id: "q3",
      prompt: "Yer Quyosh atrofini taxminan qancha vaqtda aylanib chiqadi?",
      correctId: "c",
      choices: [
        { id: "a", text: "1 kun" },
        { id: "b", text: "1 oy" },
        { id: "c", text: "1 yil" },
        { id: "d", text: "10 yil" },
      ],
    },
    {
      id: "q4",
      prompt: "O‘simliklarda fotosintez qayerda boradi?",
      correctId: "d",
      choices: [
        { id: "a", text: "Yadroda" },
        { id: "b", text: "Mitoxondriyada" },
        { id: "c", text: "Vakuolada" },
        { id: "d", text: "Xloroplastda" },
      ],
    },
  ] satisfies QuizQuestion[],
};
