"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { readStoredProfileRaw, subscribeProfileStore } from "@/components/profile/profile-data";
import type { FeedReel } from "@/lib/reels/feed";

const actionsKey = "ilm-fan-reel-actions";

type ReelMark = { like?: boolean; save?: boolean; note?: string };

function readMarks(): Record<string, ReelMark> {
  try {
    return JSON.parse(localStorage.getItem(actionsKey) || "{}") as Record<string, ReelMark>;
  } catch {
    return {};
  }
}

export function ReelStage({ reel }: { reel: FeedReel }) {
  const [playing, setPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [member, setMember] = useState(false);
  const [mark, setMark] = useState<ReelMark>({});
  const [notice, setNotice] = useState("");
  const [note, setNote] = useState("");

  useEffect(() => {
    const sync = () => setMember(Boolean(readStoredProfileRaw()));
    sync();
    return subscribeProfileStore(sync);
  }, []);

  useEffect(() => {
    const saved = readMarks()[reel.id] ?? {};
    setMark(saved);
    setNote(saved.note ?? "");
  }, [reel.id]);

  useEffect(() => {
    if (!playing) return;
    const step = 20 / reel.seconds;
    const timer = window.setInterval(() => {
      setProgress((value) => {
        const next = Math.min(100, value + step);
        if (next >= 100) setPlaying(false);
        return next;
      });
    }, 200);
    return () => window.clearInterval(timer);
  }, [playing, reel.seconds]);

  function save(next: ReelMark) {
    const all = readMarks();
    all[reel.id] = next;
    localStorage.setItem(actionsKey, JSON.stringify(all));
    setMark(next);
  }

  function requireLogin(label: string) {
    if (member) return false;
    setNotice(`${label} uchun avval kirish kerak.`);
    return true;
  }

  return (
    <article className="w-full overflow-hidden rounded-[28px] border border-line bg-white">
      <button
        type="button"
        onClick={() => {
          if (progress >= 100) setProgress(0);
          setPlaying((value) => !value);
        }}
        className="relative block aspect-[9/16] w-full bg-[#1c1915] text-left text-white"
      >
        <span className="absolute top-4 left-4 text-xs tracking-[0.14em] text-white/70 uppercase">
          {reel.fan}
        </span>
        <span className="absolute top-10 right-4 left-4 text-lg font-semibold">{reel.title}</span>
        <span className="absolute right-4 bottom-16 left-4 text-sm leading-6 text-white/90">
          {playing || progress > 0 ? reel.text : "Tomosha qilish uchun bosing"}
        </span>
        <span className="absolute bottom-6 left-1/2 flex h-14 w-14 -translate-x-1/2 items-center justify-center rounded-full bg-accent text-lg">
          {playing ? "❚❚" : "▶"}
        </span>
        <span className="absolute bottom-0 left-0 h-1 bg-accent" style={{ width: `${progress}%` }} />
      </button>
      <div className="flex flex-wrap gap-2 p-3">
        <button type="button" onClick={() => { if (requireLogin("Layk")) return; save({ ...mark, like: !mark.like }); setNotice(""); }} className="rounded-full border border-line px-3 py-1.5 text-sm">
          {mark.like ? "Layklandi" : "Layk"} · {reel.likes + (mark.like ? 1 : 0)}
        </button>
        <button type="button" onClick={() => { if (requireLogin("Saqlash")) return; save({ ...mark, save: !mark.save }); setNotice(""); }} className="rounded-full border border-line px-3 py-1.5 text-sm">
          {mark.save ? "Saqlangan" : "Saqlash"}
        </button>
        <button type="button" onClick={() => { if (requireLogin("Izoh")) return; setNotice("izoh"); }} className="rounded-full border border-line px-3 py-1.5 text-sm">
          Izoh
        </button>
      </div>
      {notice === "izoh" && member ? (
        <form
          className="flex gap-2 px-3 pb-3"
          onSubmit={(event) => {
            event.preventDefault();
            save({ ...mark, note: note.trim() });
            setNotice("");
          }}
        >
          <input value={note} onChange={(event) => setNote(event.target.value)} placeholder="Izoh" className="flex-1 rounded-2xl border border-line px-3 py-2 text-sm outline-none focus:border-accent" />
          <button type="submit" className="rounded-full bg-accent px-3 py-2 text-sm text-white">Yozish</button>
        </form>
      ) : null}
      {notice && notice !== "izoh" ? (
        <p className="px-3 pb-3 text-sm text-ink/70">
          {notice}{" "}
          <Link href="/login" className="font-medium text-accent">Kirishni boshlash</Link>
        </p>
      ) : null}
    </article>
  );
}
