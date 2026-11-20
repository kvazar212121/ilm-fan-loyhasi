"use client";

import type { PublicRoom } from "@/lib/quiz/types";

type LiveLobbyProps = {
  room: PublicRoom;
  onStart: () => void;
};

export function LiveLobby({ room, onStart }: LiveLobbyProps) {
  return (
    <section className="flex flex-col gap-4 rounded-2xl border border-line bg-white p-6">
      <p className="text-sm text-ink/70">
        Kodni ulashing. Har bir savol <span className="font-medium text-ink">{room.seconds}</span> soniya
        ochiq turadi.
      </p>
      <p className="text-4xl font-semibold tracking-[0.2em]">{room.code}</p>
      <ul className="flex flex-col gap-2 text-sm">
        {room.players.map((player) => (
          <li key={player.id} className="rounded-xl border border-line px-4 py-2">
            {player.name}
          </li>
        ))}
      </ul>
      {room.youAreHost ? (
        <button
          type="button"
          onClick={onStart}
          className="w-fit rounded-full bg-accent px-4 py-2 text-sm font-medium text-white"
        >
          Testni boshlash
        </button>
      ) : (
        <p className="text-sm text-ink/70">Boshlovchi testni ochishini kuting.</p>
      )}
    </section>
  );
}
