export type QuizChoice = {
  id: string;
  text: string;
};

export type QuizQuestion = {
  id: string;
  prompt: string;
  choices: QuizChoice[];
  correctId: string;
};

export type LivePhase = "lobby" | "question" | "reveal" | "done";

export type PublicChoice = QuizChoice & {
  count: number;
};

export type PublicPlayer = {
  id: string;
  name: string;
  score: number;
};

export type PublicRoom = {
  code: string;
  title: string;
  phase: LivePhase;
  seconds: number;
  index: number;
  total: number;
  remainingMs: number;
  youAreHost: boolean;
  needJoin: boolean;
  closed: boolean;
  prompt: string | null;
  choices: PublicChoice[];
  correctId: string | null;
  correctCount: number;
  wrongCount: number;
  pendingCount: number;
  players: PublicPlayer[];
  you: {
    name: string;
    choiceId: string | null;
    correct: boolean | null;
    score: number;
  } | null;
};

export type PublicQuiz = {
  id: string;
  title: string;
  questions: Array<{
    id: string;
    prompt: string;
    choices: QuizChoice[];
  }>;
};
