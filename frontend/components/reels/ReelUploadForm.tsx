"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

import { ReelPipeline } from "@/components/reels/ReelPipeline";
import { readVideoDuration } from "@/components/reels/readVideoDuration";
import {
  reelMaxDurationSec,
  reelsStorageKey,
  type StoredReel,
} from "@/lib/reel-config";
import { notifyReelsUpdated } from "@/lib/reel-store";

type PipelineStep = "idle" | "check" | "format" | "compress" | "done" | "error";

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export function ReelUploadForm() {
  const router = useRouter();
  const [title, setTitle] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [step, setStep] = useState<PipelineStep>("idle");
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    if (!file) {
      setStep("error");
      setError("Avval video tanlang.");
      return;
    }

    try {
      setStep("check");
      const durationSec = await readVideoDuration(file);
      if (durationSec > reelMaxDurationSec) {
        setStep("error");
        setError(`Video ${Math.ceil(durationSec)} s. Maksimum ${reelMaxDurationSec} s (2 daqiqa).`);
        return;
      }

      setStep("format");
      await sleep(500);
      setStep("compress");
      await sleep(700);

      const raw = sessionStorage.getItem(reelsStorageKey);
      const list: StoredReel[] = raw ? (JSON.parse(raw) as StoredReel[]) : [];
      const entry: StoredReel = {
        id: crypto.randomUUID(),
        title: title.trim() || file.name,
        fileName: file.name,
        durationSec: Math.round(durationSec),
        createdAt: new Date().toISOString(),
      };
      sessionStorage.setItem(reelsStorageKey, JSON.stringify([entry, ...list]));
      notifyReelsUpdated();

      setStep("done");
      router.push("/profile");
    } catch (cause) {
      setStep("error");
      setError(cause instanceof Error ? cause.message : "Xatolik yuz berdi.");
    }
  }

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-4">
      <input
        value={title}
        onChange={(event) => setTitle(event.target.value)}
        placeholder="Reel sarlavhasi (ixtiyoriy)"
        className="rounded-2xl border border-line bg-white px-4 py-3 text-sm outline-none focus:border-accent"
      />
      <label className="flex cursor-pointer flex-col gap-2 rounded-2xl border border-dashed border-line bg-white p-5">
        <span className="text-sm font-medium">Video tanlash</span>
        <span className="text-xs text-ink/55">2 daqiqagacha. Keyin format va siqish ishlaydi.</span>
        <input
          type="file"
          accept="video/*"
          className="text-sm"
          onChange={(event) => setFile(event.target.files?.[0] ?? null)}
        />
        {file ? <span className="text-xs text-ink/60">{file.name}</span> : null}
      </label>
      <ReelPipeline step={step} message={error} />
      <button
        type="submit"
        disabled={step === "check" || step === "format" || step === "compress"}
        className="w-fit rounded-full bg-accent px-5 py-3 text-sm font-medium text-white disabled:opacity-50"
      >
        Joylash
      </button>
    </form>
  );
}