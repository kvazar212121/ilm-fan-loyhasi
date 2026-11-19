"use client";

import Link from "next/link";
import { useSyncExternalStore } from "react";

import { type StoredReel } from "@/lib/reel-config";
import { getReelsRaw, subscribeReels } from "@/lib/reel-store";

export function MyReels() {
  const raw = useSyncExternalStore(subscribeReels, getReelsRaw, () => null);
  const reels: StoredReel[] = raw ? (JSON.parse(raw) as StoredReel[]) : [];

  return (
    <section className="rounded-2xl border border-line bg-white p-5">
      <div className="flex items-start justify-between gap-3">
        <h2 className="text-lg font-semibold">Mening reelslarim</h2>
        <Link href="/profile/reels/create" className="text-sm font-medium text-accent">
          Joylash
        </Link>
      </div>
      {reels.length === 0 ? (
        <p className="mt-4 text-sm text-ink/60">Hozircha reelsingiz yo‘q.</p>
      ) : (
        <ul className="mt-4 flex flex-col gap-2">
          {reels.map((reel) => (
            <li key={reel.id} className="rounded-xl bg-paper px-4 py-3 text-sm">
              <span className="font-medium">{reel.title}</span>
              <span className="text-ink/55"> · {reel.durationSec}s</span>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}