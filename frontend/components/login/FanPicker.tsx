"use client";

import { useState } from "react";

import { tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";

type FanPickerProps = {
  mode: "one" | "many";
  onBack: () => void;
  onSelect: (fanIds: string[]) => void;
};

export function FanPicker({ mode, onBack, onSelect }: FanPickerProps) {
  const [picked, setPicked] = useState<string[]>([]);

  function toggle(id: string) {
    if (mode === "one") {
      onSelect([id]);
      return;
    }
    setPicked((current) =>
      current.includes(id) ? current.filter((item) => item !== id) : [...current, id],
    );
  }

  return (
    <div className="flex flex-col gap-8">
      <div className="flex flex-col gap-2">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink/55 transition-colors hover:text-ink"
        >
          ← Rolni o‘zgartirish
        </button>
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">3-qadam</p>
        <h1 className="text-3xl font-semibold tracking-tight">
          {mode === "many" ? "Qaysi fanlar?" : "Qaysi fan?"}
        </h1>
        <p className="text-sm leading-6 text-ink/60">
          {mode === "many"
            ? "Abituriyent bir nechta fan tanlashi mumkin. Keraklilarini belgilang."
            : "Bitta fan tanlanadi. Testlar va materiallar shu fan bo‘yicha ochiladi."}
        </p>
      </div>
      <ul className="grid gap-2 sm:grid-cols-2">
        {tayyorlovFans.map((fan) => {
          const on = picked.includes(fan.id);
          return (
            <li key={fan.id}>
              <button
                type="button"
                onClick={() => toggle(fan.id)}
                className={`w-full rounded-2xl border px-4 py-4 text-left text-base font-medium transition-colors ${on ? "border-accent bg-accent/10" : "border-line bg-white hover:border-accent"}`}
              >
                {fan.title}
              </button>
            </li>
          );
        })}
      </ul>
      {mode === "many" ? (
        <button
          type="button"
          disabled={picked.length === 0}
          onClick={() => onSelect(picked)}
          className="w-fit rounded-full bg-accent px-5 py-3 text-sm font-medium text-white disabled:opacity-40"
        >
          Davom etish
        </button>
      ) : null}
    </div>
  );
}
