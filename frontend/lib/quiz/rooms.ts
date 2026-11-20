import { sampleQuiz } from "@/lib/quiz/sample";
import type { PublicRoom } from "@/lib/quiz/types";

type Answer = { choiceId: string; correct: boolean };
type Player = { id: string; name: string; score: number };
type Phase = PublicRoom["phase"];

type Room = {
  code: string;
  hostId: string;
  seconds: number;
  phase: Phase;
  index: number;
  startedAt: number;
  scored: boolean;
  players: Player[];
  answers: Record<string, Answer>;
};

const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

const store = globalThis as typeof globalThis & {
  __ilmQuizRooms?: Map<string, Room>;
};

function rooms() {
  store.__ilmQuizRooms ??= new Map();
  return store.__ilmQuizRooms;
}

function makeCode() {
  let code = "";
  for (let i = 0; i < 4; i += 1) {
    code += alphabet[Math.floor(Math.random() * alphabet.length)];
  }
  return rooms().has(code) ? makeCode() : code;
}

function question(room: Room) {
  return sampleQuiz.questions[room.index];
}

function closeQuestion(room: Room) {
  if (room.phase !== "question" || room.scored) return;
  const current = question(room);
  room.phase = "reveal";
  room.scored = true;
  for (const player of room.players) {
    const answer = room.answers[player.id];
    if (!answer) continue;
    answer.correct = answer.choiceId === current.correctId;
    if (answer.correct) player.score += 1;
  }
}

function tick(room: Room) {
  if (room.phase !== "question") return;
  if (Date.now() - room.startedAt >= room.seconds * 1000) closeQuestion(room);
}

export function createRoom(hostId: string, name: string, seconds: number) {
  const code = makeCode();
  const room: Room = {
    code,
    hostId,
    seconds,
    phase: "lobby",
    index: 0,
    startedAt: 0,
    scored: false,
    players: [{ id: hostId, name, score: 0 }],
    answers: {},
  };
  rooms().set(code, room);
  return code;
}

export function joinRoom(code: string, playerId: string, name: string) {
  const room = rooms().get(code);
  if (!room) return "Xona topilmadi";
  if (room.phase !== "lobby" && !room.players.some((item) => item.id === playerId)) {
    return "Test allaqachon boshlangan";
  }
  const existing = room.players.find((item) => item.id === playerId);
  if (existing) existing.name = name;
  else room.players.push({ id: playerId, name, score: 0 });
  return null;
}

export function startRoom(code: string, playerId: string) {
  const room = rooms().get(code);
  if (!room) return "Xona topilmadi";
  if (room.hostId !== playerId) return "Faqat boshlovchi testni ochadi";
  if (room.phase !== "lobby") return "Test allaqachon boshlangan";
  room.phase = "question";
  room.index = 0;
  room.startedAt = Date.now();
  room.scored = false;
  room.answers = {};
  return null;
}

export function answerRoom(code: string, playerId: string, choiceId: string) {
  const room = rooms().get(code);
  if (!room) return "Xona topilmadi";
  tick(room);
  if (room.phase !== "question") return "Javob vaqti tugagan";
  if (!room.players.some((item) => item.id === playerId)) return "Avval xonaga kiring";
  if (room.answers[playerId]) return "Javob allaqachon qabul qilingan";
  const current = question(room);
  if (!current.choices.some((choice) => choice.id === choiceId)) return "Variant topilmadi";
  room.answers[playerId] = { choiceId, correct: false };
  return null;
}

export function nextRoom(code: string, playerId: string) {
  const room = rooms().get(code);
  if (!room) return "Xona topilmadi";
  tick(room);
  if (room.hostId !== playerId) return "Faqat boshlovchi keyingisiga o‘tadi";
  if (room.phase !== "reveal") return "Hali javob ochilmagan";
  if (room.index >= sampleQuiz.questions.length - 1) {
    room.phase = "done";
    return null;
  }
  room.index += 1;
  room.phase = "question";
  room.startedAt = Date.now();
  room.scored = false;
  room.answers = {};
  return null;
}

export function readRoom(code: string, playerId: string): PublicRoom | null {
  const room = rooms().get(code);
  if (!room) return null;
  tick(room);
  const you = room.players.find((item) => item.id === playerId) ?? null;
  const current = room.phase === "lobby" || room.phase === "done" ? null : question(room);
  const revealed = room.phase === "reveal" || room.phase === "done";
  const counts = new Map<string, number>();
  let correctCount = 0;
  let wrongCount = 0;
  let pendingCount = 0;
  if (room.phase === "reveal") {
    for (const player of room.players) {
      const answer = room.answers[player.id];
      if (!answer) {
        pendingCount += 1;
        continue;
      }
      counts.set(answer.choiceId, (counts.get(answer.choiceId) ?? 0) + 1);
      if (answer.correct) correctCount += 1;
      else wrongCount += 1;
    }
  }
  const remainingMs =
    room.phase === "question"
      ? Math.max(0, room.seconds * 1000 - (Date.now() - room.startedAt))
      : 0;
  return {
    code: room.code,
    title: sampleQuiz.title,
    phase: room.phase,
    seconds: room.seconds,
    index: room.index,
    total: sampleQuiz.questions.length,
    remainingMs,
    youAreHost: room.hostId === playerId,
    needJoin: !you,
    closed: room.phase !== "lobby",
    prompt: current?.prompt ?? null,
    choices:
      current?.choices.map((choice) => ({
        ...choice,
        count: counts.get(choice.id) ?? 0,
      })) ?? [],
    correctId: revealed && current ? current.correctId : null,
    correctCount,
    wrongCount,
    pendingCount,
    players: [...room.players].sort((a, b) => b.score - a.score),
    you: you
      ? {
          name: you.name,
          choiceId: room.answers[you.id]?.choiceId ?? null,
          correct: room.phase === "reveal" ? (room.answers[you.id]?.correct ?? null) : null,
          score: you.score,
        }
      : null,
  };
}
