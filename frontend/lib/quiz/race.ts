export type RacePhase = "lobby" | "question" | "won" | "done";

export type RaceDraft = {
  prompt: string;
  choices: string[];
  correctIndex: number;
};

type Choice = { id: string; text: string };
type Question = { id: string; prompt: string; choices: Choice[]; correctId: string };
type Player = { id: string; name: string; score: number };
type Answer = { choiceId: string; correct: boolean };

type RaceRoom = {
  code: string;
  hostId: string;
  title: string;
  questions: Question[];
  phase: RacePhase;
  index: number;
  players: Player[];
  answers: Record<string, Answer>;
  winnerId: string | null;
};

export type PublicRace = {
  code: string;
  title: string;
  phase: RacePhase;
  index: number;
  total: number;
  prompt: string | null;
  choices: Choice[];
  correctId: string | null;
  winnerName: string | null;
  youAreHost: boolean;
  needJoin: boolean;
  you: { name: string; choiceId: string | null; correct: boolean | null; score: number } | null;
  players: Player[];
};

const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const letters = ["a", "b", "c", "d"];

const store = globalThis as typeof globalThis & { __ilmRaceRooms?: Map<string, RaceRoom> };

function rooms() {
  store.__ilmRaceRooms ??= new Map();
  return store.__ilmRaceRooms;
}

function makeCode() {
  let code = "";
  for (let i = 0; i < 4; i += 1) code += alphabet[Math.floor(Math.random() * alphabet.length)];
  return rooms().has(code) ? makeCode() : code;
}

function current(room: RaceRoom) {
  return room.questions[room.index] ?? null;
}

export function createRace(hostId: string, title: string, drafts: RaceDraft[]) {
  const questions: Question[] = drafts.map((draft, index) => ({
    id: `q${index + 1}`,
    prompt: draft.prompt.trim(),
    choices: draft.choices.map((text, choiceIndex) => ({
      id: letters[choiceIndex] ?? String(choiceIndex),
      text: text.trim(),
    })),
    correctId: letters[draft.correctIndex] ?? "a",
  }));
  const code = makeCode();
  rooms().set(code, {
    code,
    hostId,
    title: title.trim(),
    questions,
    phase: "lobby",
    index: 0,
    players: [],
    answers: {},
    winnerId: null,
  });
  return code;
}

export function joinRace(code: string, playerId: string, name: string) {
  const room = rooms().get(code);
  if (!room) return "Musobaqa topilmadi";
  if (room.phase === "done") return "Musobaqa tugagan";
  const existing = room.players.find((player) => player.id === playerId);
  if (existing) existing.name = name;
  else room.players.push({ id: playerId, name, score: 0 });
  return null;
}

export function startRace(code: string, playerId: string) {
  const room = rooms().get(code);
  if (!room) return "Musobaqa topilmadi";
  if (room.hostId !== playerId) return "Faqat o‘qituvchi boshlaydi";
  if (room.phase !== "lobby") return "Musobaqa allaqachon boshlangan";
  room.phase = "question";
  room.index = 0;
  room.answers = {};
  room.winnerId = null;
  return null;
}

export function answerRace(code: string, playerId: string, choiceId: string) {
  const room = rooms().get(code);
  if (!room) return "Musobaqa topilmadi";
  if (room.phase !== "question") return "Bu savol yopilgan";
  const player = room.players.find((item) => item.id === playerId);
  if (!player) return "Avval ismingizni yozing";
  if (room.answers[playerId]) return "Javob allaqachon qabul qilingan";
  const question = current(room);
  if (!question?.choices.some((choice) => choice.id === choiceId)) return "Variant topilmadi";
  const correct = choiceId === question.correctId;
  room.answers[playerId] = { choiceId, correct };
  if (correct && !room.winnerId) {
    room.winnerId = playerId;
    player.score += 1;
    room.phase = "won";
  }
  return null;
}

export function openRace(code: string, playerId: string) {
  const room = rooms().get(code);
  if (!room) return "Musobaqa topilmadi";
  if (room.hostId !== playerId) return "Faqat o‘qituvchi ochadi";
  if (room.phase !== "question") return "Savol allaqachon ochilgan";
  room.phase = "won";
  return null;
}

export function nextRace(code: string, playerId: string) {
  const room = rooms().get(code);
  if (!room) return "Musobaqa topilmadi";
  if (room.hostId !== playerId) return "Faqat o‘qituvchi keyingisiga o‘tadi";
  if (room.phase !== "won" && room.phase !== "question") return "Hali keyingi savol yo‘q";
  if (room.index >= room.questions.length - 1) {
    room.phase = "done";
    return null;
  }
  room.index += 1;
  room.phase = "question";
  room.answers = {};
  room.winnerId = null;
  return null;
}

export function readRace(code: string, playerId: string): PublicRace | null {
  const room = rooms().get(code);
  if (!room) return null;
  const question = room.phase === "lobby" || room.phase === "done" ? null : current(room);
  const revealed = room.phase === "won" || room.phase === "done";
  const you = room.players.find((player) => player.id === playerId) ?? null;
  const winner = room.players.find((player) => player.id === room.winnerId) ?? null;
  return {
    code: room.code,
    title: room.title,
    phase: room.phase,
    index: room.index,
    total: room.questions.length,
    prompt: question?.prompt ?? null,
    choices: question?.choices ?? [],
    correctId: revealed && question ? question.correctId : null,
    winnerName: winner?.name ?? null,
    youAreHost: room.hostId === playerId,
    needJoin: room.hostId !== playerId && !you,
    you: you
      ? {
          name: you.name,
          choiceId: room.answers[you.id]?.choiceId ?? null,
          correct: room.answers[you.id]?.correct ?? null,
          score: you.score,
        }
      : null,
    players: [...room.players].sort((a, b) => b.score - a.score),
  };
}
