"use client";

import Link from "next/link";
import { useSyncExternalStore } from "react";

import { type StoredReel } from "@/lib/reel-config";
import { getReelsRaw, subscribeReels } from "@/lib/reel-store";

export function MyReels() {
  const raw = useSyncExternalStore(subscribeReels, getReelsRaw, () => null);
  const reels: StoredReel[] = raw ? (JSON.parse(raw) as StoredReel[]) : [];

  return (
    <section className="rounded-2xl border border-line bg-surface p-6">
      <div className="flex items-center justify-between gap-3 border-b border-line pb-4">
        <h2 className="font-display text-xl font-medium tracking-[-0.015em] text-ink">
          Mening reelslarim
        </h2>
        <Link
          href="/profile/reels/create"
          className="rounded-full bg-accent-soft px-3.5 py-1.5 text-xs font-medium text-accent transition-colors hover:bg-accent hover:text-paper"
        >
          Joylash
        </Link>
      </div>
      {reels.length === 0 ? (
        <p className="mt-4 text-sm leading-6 text-ink-muted">
          Hozircha reelsingiz yo‘q. 2 daqiqalik qisqa dars videosini yuklab boshlang.
        </p>
      ) : (
        <ul className="mt-2 flex flex-col divide-y divide-line">
          {reels.map((reel) => (
            <li key={reel.id} className="flex items-center justify-between gap-3 py-3 text-sm last:pb-0">
              <span className="font-medium text-ink">{reel.title}</span>
              <span className="shrink-0 text-xs text-ink-muted tabular-nums">{reel.durationSec}s</span>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
