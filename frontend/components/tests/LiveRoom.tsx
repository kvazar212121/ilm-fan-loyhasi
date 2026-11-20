"use client";

import { useEffect, useState } from "react";

import { LiveLobby } from "@/components/tests/LiveLobby";
import { LivePlay } from "@/components/tests/LivePlay";
import { useProfileName, useQuizPlayerId } from "@/components/tests/use-quiz-player";
import type { PublicRoom } from "@/lib/quiz/types";

export function LiveRoom({ code }: { code: string }) {
  const playerId = useQuizPlayerId();
  const profileName = useProfileName();
  const [room, setRoom] = useState<PublicRoom | null>(null);
  const [name, setName] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    if (!playerId) return;
    let stop = false;
    async function load() {
      const response = await fetch(`/api/quiz/rooms/${code}?playerId=${playerId}`, { cache: "no-store" });
      const body = (await response.json()) as PublicRoom & { error?: string };
      if (stop) return;
      if (!response.ok) {
        setError(body.error ?? "Xona topilmadi");
        return;
      }
      setRoom(body);
      setError("");
    }
    void load();
    const timer = window.setInterval(() => void load(), 700);
    return () => {
      stop = true;
      window.clearInterval(timer);
    };
  }, [code, playerId]);

  async function act(action: "start" | "answer" | "next" | "join", extra?: { choiceId?: string; name?: string }) {
    if (!playerId) return;
    const response = await fetch(`/api/quiz/rooms/${code}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action, playerId, ...extra }),
    });
    const body = (await response.json()) as PublicRoom & { error?: string };
    if (!response.ok) {
      setError(body.error ?? "Amal bajarilmadi");
      return;
    }
    setRoom(body);
    setError("");
  }

  if (!room) {
    return <p className="text-sm text-ink/70">{error || "Xona yuklanmoqda..."}</p>;
  }

  if (room.needJoin) {
    return (
      <form
        className="flex max-w-md flex-col gap-3 rounded-2xl border border-line bg-white p-6"
        onSubmit={(event) => {
          event.preventDefault();
          void act("join", { name: name || profileName });
        }}
      >
        <h2 className="text-lg font-semibold">Xona {room.code}</h2>
        <p className="text-sm text-ink/70">
          {room.closed ? "Test boshlangan. Yangi ishtirokchi kira olmaydi." : "Ismingizni yozib kiring."}
        </p>
        {room.closed ? null : (
          <>
            <input
              value={name || profileName}
              onChange={(event) => setName(event.target.value)}
              placeholder="Ismingiz"
              className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
            />
            <button type="submit" className="w-fit rounded-full bg-accent px-4 py-2 text-sm font-medium text-white">
              Kirish
            </button>
          </>
        )}
        {error ? <p className="text-sm text-red-800">{error}</p> : null}
      </form>
    );
  }

  return (
    <div className="flex flex-col gap-3">
      {error ? <p className="text-sm text-red-800">{error}</p> : null}
      {room.phase === "lobby" ? (
        <LiveLobby room={room} onStart={() => void act("start")} />
      ) : (
        <LivePlay
          room={room}
          onAnswer={(choiceId) => void act("answer", { choiceId })}
          onNext={() => void act("next")}
        />
      )}
    </div>
  );
}
