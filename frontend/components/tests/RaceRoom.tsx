"use client";

import { useEffect, useState } from "react";

import { RaceScreen } from "@/components/tests/RaceScreen";
import { RaceStudent } from "@/components/tests/RaceStudent";
import { useProfileName, useQuizPlayerId } from "@/components/tests/use-quiz-player";
import type { PublicRace } from "@/lib/quiz/race";

export function RaceRoom({ code, screen }: { code: string; screen: boolean }) {
  const playerId = useQuizPlayerId();
  const profileName = useProfileName();
  const [room, setRoom] = useState<PublicRace | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!playerId) return;
    let stop = false;
    async function load() {
      const response = await fetch(`/api/quiz/race/${code}?playerId=${playerId}`, { cache: "no-store" });
      const body = (await response.json()) as PublicRace & { error?: string };
      if (stop) return;
      if (!response.ok) {
        setError(body.error ?? "Musobaqa topilmadi");
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

  async function act(action: "join" | "start" | "answer" | "open" | "next", extra?: { name?: string; choiceId?: string }) {
    if (!playerId) return;
    const response = await fetch(`/api/quiz/race/${code}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action, playerId, ...extra }),
    });
    const body = (await response.json()) as PublicRace & { error?: string };
    if (!response.ok) {
      setError(body.error ?? "Amal bajarilmadi");
      return;
    }
    setRoom(body);
    setError("");
  }

  if (!room) return <p className="text-sm text-ink/70">{error || "Musobaqa yuklanmoqda..."}</p>;

  return (
    <div className="flex flex-col gap-3">
      {error ? <p className="text-sm text-red-800">{error}</p> : null}
      {screen ? (
        <RaceScreen
          room={room}
          onStart={() => void act("start")}
          onOpen={() => void act("open")}
          onNext={() => void act("next")}
        />
      ) : (
        <RaceStudent
          room={room}
          profileName={profileName}
          onJoin={(name) => void act("join", { name })}
          onAnswer={(choiceId) => void act("answer", { choiceId })}
        />
      )}
    </div>
  );
}
