"use client";

import { useState } from "react";

import { tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";

type FanPickerProps = {
  mode: "one" | "many";
  submitting?: boolean;
  onBack: () => void;
  onSelect: (fanIds: string[]) => void;
};

export function FanPicker({ mode, submitting = false, onBack, onSelect }: FanPickerProps) {
  const [picked, setPicked] = useState<string[]>([]);

  function toggle(id: string) {
    if (submitting) return;
    if (mode === "one") {
      onSelect([id]);
      return;
    }
    setPicked((current) =>
      current.includes(id) ? current.filter((item) => item !== id) : [...current, id],
    );
  }

  return (
    <div className={`flex flex-col gap-6 ${submitting ? "pointer-events-none opacity-60" : ""}`}>
      <div className="space-y-1.5">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink-muted transition-colors hover:text-ink"
        >
          ← Rolni o‘zgartirish
        </button>
        <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
          {mode === "many" ? "Tayyorlanadigan fanlar" : "Asosiy faningizni tanlang"}
        </h1>
        <p className="text-sm leading-6 text-ink-muted">
          {mode === "many"
            ? "Abituriyent bir nechta fan tanlashi mumkin. Keraklilarini belgilang."
            : "Testlar va o‘quv materiallari tanlangan fan bo‘yicha ochiladi."}
        </p>
      </div>

      <ul className="grid gap-2.5 sm:grid-cols-2">
        {tayyorlovFans.map((fan) => {
          const on = picked.includes(fan.id);
          return (
            <li key={fan.id}>
              <button
                type="button"
                onClick={() => toggle(fan.id)}
                className={`flex w-full items-center justify-between rounded-xl border px-4 py-3 text-left text-sm font-medium transition-colors ${
                  on
                    ? "border-accent bg-accent text-paper"
                    : "border-line bg-paper/70 text-ink hover:border-accent hover:bg-accent-soft/50"
                }`}
              >
                <span>{fan.title}</span>
                {on ? <span aria-hidden>✓</span> : null}
              </button>
            </li>
          );
        })}
      </ul>

      {mode === "many" ? (
        <button
          type="button"
          disabled={picked.length === 0 || submitting}
          onClick={() => onSelect(picked)}
          className="w-fit rounded-full bg-accent px-6 py-3.5 text-sm font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-40"
        >
          {submitting ? "Saqlanmoqda..." : "Ro‘yxatdan o‘tishni yakunlash"}
        </button>
      ) : null}
    </div>
  );
}
