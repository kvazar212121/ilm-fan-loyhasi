"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { useProfileName, useQuizPlayerId } from "@/components/tests/use-quiz-player";

export function LiveSetup() {
  const router = useRouter();
  const playerId = useQuizPlayerId();
  const profileName = useProfileName();
  const [hostName, setHostName] = useState("");
  const [guestName, setGuestName] = useState("");
  const [seconds, setSeconds] = useState(10);
  const [code, setCode] = useState("");
  const [error, setError] = useState("");

  const nameForHost = hostName || profileName;
  const nameForGuest = guestName || profileName;

  async function createRoom() {
    if (!playerId) return;
    setError("");
    const response = await fetch("/api/quiz/rooms", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ playerId, name: nameForHost, seconds }),
    });
    const body = (await response.json()) as { code?: string; error?: string };
    if (!response.ok || !body.code) {
      setError(body.error ?? "Xona ochilmadi");
      return;
    }
    router.push(`/tests/live/${body.code}`);
  }

  async function joinRoom() {
    if (!playerId) return;
    setError("");
    const roomCode = code.trim().toUpperCase();
    const response = await fetch(`/api/quiz/rooms/${roomCode}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: "join", playerId, name: nameForGuest }),
    });
    const body = (await response.json()) as { error?: string };
    if (!response.ok) {
      setError(body.error ?? "Xonaga kirilmadi");
      return;
    }
    router.push(`/tests/live/${roomCode}`);
  }

  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <form
        className="flex flex-col gap-3 rounded-2xl border border-line bg-white p-5"
        onSubmit={(event) => {
          event.preventDefault();
          void createRoom();
        }}
      >
        <h2 className="text-lg font-semibold">Xona ochish</h2>
        <input
          value={nameForHost}
          onChange={(event) => setHostName(event.target.value)}
          placeholder="Ismingiz"
          className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
        />
        <label className="flex items-center justify-between gap-3 text-sm">
          Har savol, soniya
          <input
            type="number"
            min={5}
            max={60}
            value={seconds}
            onChange={(event) => setSeconds(Number(event.target.value))}
            className="w-20 rounded-2xl border border-line px-3 py-2 text-sm outline-none focus:border-accent"
          />
        </label>
        <button type="submit" className="w-fit rounded-full bg-accent px-4 py-2 text-sm font-medium text-white">
          Boshlash
        </button>
      </form>
      <form
        className="flex flex-col gap-3 rounded-2xl border border-line bg-white p-5"
        onSubmit={(event) => {
          event.preventDefault();
          void joinRoom();
        }}
      >
        <h2 className="text-lg font-semibold">Xonaga kirish</h2>
        <input
          value={nameForGuest}
          onChange={(event) => setGuestName(event.target.value)}
          placeholder="Ismingiz"
          className="rounded-2xl border border-line px-4 py-3 text-sm outline-none focus:border-accent"
        />
        <input
          value={code}
          onChange={(event) => setCode(event.target.value.toUpperCase())}
          placeholder="Xona kodi"
          className="rounded-2xl border border-line px-4 py-3 text-sm uppercase outline-none focus:border-accent"
        />
        <button type="submit" className="w-fit rounded-full bg-accent px-4 py-2 text-sm font-medium text-white">
          Kirish
        </button>
      </form>
      {error ? <p className="text-sm text-red-800 sm:col-span-2">{error}</p> : null}
    </div>
  );
}
