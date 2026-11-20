"use client";

import { useEffect, useState } from "react";

import type { PublicRace } from "@/lib/quiz/race";

type RaceScreenProps = {
  room: PublicRace;
  onStart: () => void;
  onOpen: () => void;
  onNext: () => void;
};

export function RaceScreen({ room, onStart, onOpen, onNext }: RaceScreenProps) {
  const [link, setLink] = useState("");

  useEffect(() => {
    setLink(`${window.location.origin}/tests/race/${room.code}`);
  }, [room.code]);

  return (
    <section className="flex flex-col gap-6 rounded-2xl border border-line bg-white p-6 sm:p-8">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">{room.title}</p>
          <p className="mt-2 text-5xl font-semibold tracking-[0.18em]">{room.code}</p>
        </div>
        {link ? <p className="max-w-xs text-sm text-ink/70">{link}</p> : null}
      </div>
      {room.phase === "lobby" ? (
        <p className="text-lg">O‘quvchilar shu linkni ochib ismini yozadi. Keyin savol ekranga chiqadi.</p>
      ) : room.phase === "done" ? (
        <h2 className="text-3xl font-semibold">Musobaqa yakunlandi</h2>
      ) : (
        <div className="flex flex-col gap-4">
          <p className="text-sm font-medium text-accent">
            Savol {room.index + 1} / {room.total}
          </p>
          <h2 className="text-3xl font-semibold">{room.prompt}</h2>
          <div className="grid gap-2 sm:grid-cols-2">
            {room.choices.map((choice, index) => {
              const correct = room.correctId === choice.id;
              return (
                <p
                  key={choice.id}
                  className={`rounded-2xl border px-4 py-4 text-lg ${correct ? "border-accent bg-accent text-white" : "border-line"}`}
                >
                  {String.fromCharCode(65 + index)}. {choice.text}
                </p>
              );
            })}
          </div>
        </div>
      )}
      {room.winnerName ? <p className="text-xl font-semibold">Birinchi topdi: {room.winnerName}</p> : null}
      {room.phase === "question" ? <p className="text-sm text-ink/70">Birinchi to‘g‘ri javob ball oladi.</p> : null}
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
      {room.youAreHost && room.phase === "lobby" ? (
        <button type="button" onClick={onStart} className="w-fit rounded-full bg-accent px-5 py-3 text-sm font-medium text-white">
          Savolni chiqarish
        </button>
      ) : null}
      {room.youAreHost && room.phase === "question" ? (
        <button type="button" onClick={onOpen} className="w-fit rounded-full border border-line px-4 py-2 text-sm font-medium">
          Hech kim topmadi, javobni ochish
        </button>
      ) : null}
      {room.youAreHost && room.phase === "won" ? (
        <button type="button" onClick={onNext} className="w-fit rounded-full bg-accent px-5 py-3 text-sm font-medium text-white">
          {room.index + 1 === room.total ? "Natija" : "Keyingi savol"}
        </button>
      ) : null}
    </section>
  );
}
