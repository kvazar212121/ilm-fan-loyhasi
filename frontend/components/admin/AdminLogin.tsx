"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

export function AdminLogin() {
  const router = useRouter();
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    const response = await fetch("/api/admin/login", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ password }),
    });
    if (!response.ok) {
      setError("Parol noto‘g‘ri");
      return;
    }
    router.refresh();
  }

  return (
    <main className="mx-auto flex min-h-full w-full max-w-md flex-1 flex-col justify-center px-6 py-16">
      <form onSubmit={onSubmit} className="flex flex-col gap-6">
        <div className="flex flex-col gap-2">
          <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Boshqaruv</p>
          <h1 className="text-3xl font-semibold tracking-tight">Admin panel</h1>
          <p className="text-sm leading-6 text-ink/60">
            Odamlar, fan materiallari, darslik, kurs va reels shu yerdan ochiladi.
          </p>
        </div>
        <input
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Parol"
          autoComplete="current-password"
          className="rounded-2xl border border-line bg-white px-4 py-3 text-base outline-none focus:border-accent"
        />
        {error ? <p className="text-sm text-ink/70">{error}</p> : null}
        <button type="submit" className="rounded-full bg-accent px-5 py-3 text-sm font-medium text-white">
          Kirish
        </button>
      </form>
    </main>
  );
}
