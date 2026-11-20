"use client";

import { useState } from "react";

import { ChoiceButtons } from "@/components/tests/ChoiceButtons";
import type { PublicRace } from "@/lib/quiz/race";

type RaceStudentProps = {
  room: PublicRace;
  profileName: string;
  onJoin: (name: string) => void;
  onAnswer: (choiceId: string) => void;
};

export function RaceStudent({ room, profileName, onJoin, onAnswer }: RaceStudentProps) {
  const [name, setName] = useState("");
  const revealed = room.phase === "won";
  const waiting = room.phase === "lobby";

  if (room.needJoin) {
    return (
      <form
        className="flex max-w-md flex-col gap-3 rounded-2xl border border-line bg-white p-6"
        onSubmit={(event) => {
          event.preventDefault();
          onJoin(name || profileName);
        }}
      >
        <h2 className="text-lg font-semibold">Musobaqa {room.code}</h2>
        <p className="text-sm text-ink/70">Ismingizni yozing. Ballni birinchi to‘g‘ri javob oladi.</p>
        <input
          value={name || profileName}
          onChange={(event) => setName(event.target.value)}
          placeholder="Ismingiz"
          className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
        />
        <button type="submit" className="w-fit rounded-full bg-accent px-4 py-2 text-sm font-medium text-white">
          Kirish
        </button>
      </form>
    );
  }

  if (waiting || room.phase === "done") {
    return (
      <section className="flex flex-col gap-3 rounded-2xl border border-line bg-white p-6">
        <h2 className="text-xl font-semibold">{room.title}</h2>
        <p className="text-sm text-ink/70">
          {waiting ? "Savol ekranga chiqishini kuting." : "Musobaqa tugadi."}
        </p>
        <p className="text-sm font-medium">Sizning ballingiz: {room.you?.score ?? 0}</p>
      </section>
    );
  }

  const note = room.you?.correct
    ? "Birinchi topdingiz. +1 ball."
    : room.winnerName
      ? `Ballni ${room.winnerName} oldi.`
      : revealed
        ? "To‘g‘ri javob ochildi. Bu savolda ball yo‘q."
        : room.you?.correct === false
          ? "Xato. Bu savoldan ball yo‘q."
          : "Birinchi bo‘lib to‘g‘ri variantni bosing.";

  return (
    <section className="flex flex-col gap-4 rounded-2xl border border-line bg-white p-6">
      <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
        Savol {room.index + 1} / {room.total}
      </p>
      <h2 className="text-xl font-semibold">{room.prompt}</h2>
      <ChoiceButtons
        choices={room.choices.map((choice) => ({ ...choice, count: 0 }))}
        pickedId={room.you?.choiceId ?? null}
        correctId={room.correctId}
        revealed={revealed}
        disabled={revealed || Boolean(room.you?.choiceId)}
        showCounts={false}
        onPick={onAnswer}
      />
      <p className="text-sm font-medium">{note}</p>
    </section>
  );
}
