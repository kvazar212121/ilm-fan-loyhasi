"use client";

import { useEffect, useState } from "react";

import { ChoiceButtons } from "@/components/tests/ChoiceButtons";
import type { PublicRoom } from "@/lib/quiz/types";

type LivePlayProps = {
  room: PublicRoom;
  onAnswer: (choiceId: string) => void;
  onNext: () => void;
};

export function LivePlay({ room, onAnswer, onNext }: LivePlayProps) {
  const [left, setLeft] = useState(room.remainingMs);

  useEffect(() => {
    setLeft(room.remainingMs);
    if (room.phase !== "question") return;
    const timer = window.setInterval(() => {
      setLeft((current) => Math.max(0, current - 200));
    }, 200);
    return () => window.clearInterval(timer);
  }, [room.phase, room.index, room.remainingMs]);

  if (room.phase === "done") {
    return (
      <section className="flex flex-col gap-3 rounded-2xl border border-line bg-white p-6">
        <h2 className="text-2xl font-semibold">Natija</h2>
        <ol className="flex flex-col gap-2">
          {room.players.map((player, index) => (
            <li key={player.id} className="flex justify-between rounded-xl border border-line px-4 py-2 text-sm">
              <span>
                {index + 1}. {player.name}
              </span>
              <span>{player.score} ball</span>
            </li>
          ))}
        </ol>
      </section>
    );
  }

  const revealed = room.phase === "reveal";
  const verdict =
    room.you?.correct === true
      ? "To‘g‘ri topdingiz."
      : room.you?.correct === false
        ? "Xato qildingiz."
        : room.you?.choiceId
          ? null
          : "Javob bermadingiz.";

  return (
    <section className="flex flex-col gap-4 rounded-2xl border border-line bg-white p-6">
      <div className="flex items-center justify-between gap-3 text-sm">
        <p className="font-medium text-accent">
          Savol {room.index + 1} / {room.total}
        </p>
        <p className="text-2xl font-semibold tabular-nums">{revealed ? "—" : Math.ceil(left / 1000)}</p>
      </div>
      <h2 className="text-xl font-semibold">{room.prompt}</h2>
      <ChoiceButtons
        choices={room.choices}
        pickedId={room.you?.choiceId ?? null}
        correctId={room.correctId}
        revealed={revealed}
        disabled={revealed || Boolean(room.you?.choiceId)}
        showCounts={revealed}
        onPick={onAnswer}
      />
      {room.you?.choiceId && !revealed ? (
        <p className="text-sm text-ink/70">Javob qabul qilindi. Vaqt tugashini kuting.</p>
      ) : null}
      {revealed ? (
        <div className="flex flex-col gap-3">
          <p className="text-sm font-medium">{verdict}</p>
          <p className="text-sm text-ink/70">
            {room.correctCount} kishi to‘g‘ri · {room.wrongCount} kishi xato
            {room.pendingCount > 0 ? ` · ${room.pendingCount} kishi javobsiz` : ""}
          </p>
          {room.youAreHost ? (
            <button
              type="button"
              onClick={onNext}
              className="w-fit rounded-full bg-accent px-4 py-2 text-sm font-medium text-white"
            >
              {room.index + 1 === room.total ? "Natija" : "Keyingi savol"}
            </button>
          ) : (
            <p className="text-sm text-ink/70">Keyingi savolni boshlovchi ochadi.</p>
          )}
        </div>
      ) : null}
    </section>
  );
}
