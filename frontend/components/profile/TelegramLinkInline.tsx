"use client";

import { useEffect, useState } from "react";

import type { LinkedIdentity } from "@/components/profile/PhoneLinkInline";
import type { BackendUser } from "@/lib/auth/client";

type TelegramLinkInlineProps = {
  onCancel: () => void;
  onLinked: (user: BackendUser, methods: LinkedIdentity[], merged: boolean) => void;
};

export function TelegramLinkInline({ onCancel, onLinked }: TelegramLinkInlineProps) {
  const [attemptNo, setAttemptNo] = useState(0);
  const [deepLink, setDeepLink] = useState<string | null>(null);
  const [botUsername, setBotUsername] = useState("");
  const [botOpened, setBotOpened] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    let timer: ReturnType<typeof setInterval> | null = null;

    async function start() {
      setError(null);
      setDeepLink(null);
      setBotOpened(false);
      const res = await fetch("/api/auth/link/telegram/start", { method: "POST" });
      const data = await res.json().catch(() => ({}));
      if (!active) return;
      if (!res.ok || !data.deep_link) {
        setError(data.message || "Telegram ulashni boshlab bo‘lmadi");
        return;
      }
      setDeepLink(data.deep_link);
      setBotUsername(data.bot_username || "");

      timer = setInterval(async () => {
        const pollRes = await fetch("/api/auth/link/telegram/poll", { method: "POST" });
        const poll = await pollRes.json().catch(() => ({}));
        if (!active) return;
        if (!pollRes.ok) {
          if (timer) clearInterval(timer);
          setError(poll.message || "Telegram ulashda xatolik");
          return;
        }
        if (poll.status === "pending") {
          setBotOpened(Boolean(poll.bot_opened));
          return;
        }
        if (timer) clearInterval(timer);
        if (poll.status === "linked" && poll.user) {
          onLinked(poll.user, poll.methods || [], Boolean(poll.merged));
        }
      }, 2000);
    }

    start();
    return () => {
      active = false;
      if (timer) clearInterval(timer);
    };
  }, [attemptNo, onLinked]);

  return (
    <div className="mt-3.5 flex flex-col gap-3 rounded-xl border border-line bg-paper p-4">
      <p className="text-xs leading-5 text-ink-muted">
        Telegram botni oching, kontaktingizni ulashing va{" "}
        <strong className="font-medium text-ink">Tasdiqlash</strong> tugmasini bosing.
      </p>
      <div className="flex flex-wrap items-center gap-2">
        {deepLink ? (
          <a
            href={deepLink}
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-full bg-accent px-4 py-2 text-xs font-medium text-paper transition-colors hover:bg-accent-hover"
          >
            Telegram botni ochish {botUsername ? `(@${botUsername})` : ""}
          </a>
        ) : !error ? (
          <span className="text-xs text-ink-muted">Havola tayyorlanmoqda...</span>
        ) : null}
        <button
          type="button"
          onClick={() => setAttemptNo((n) => n + 1)}
          className="rounded-full border border-line bg-surface px-3.5 py-2 text-xs font-medium text-ink transition-colors hover:border-line-strong"
        >
          Yangi havola
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="rounded-full border border-line bg-surface px-3.5 py-2 text-xs font-medium text-ink-muted transition-colors hover:border-line-strong hover:text-ink"
        >
          Bekor qilish
        </button>
      </div>
      {deepLink && !error ? (
        <p className="text-xs text-ink-muted">
          {botOpened ? "Bot ochildi — Telegram’da tasdiqlang..." : "Tasdiqlash kutilmoqda..."}
        </p>
      ) : null}
      {error ? <p className="text-xs text-red-700">{error}</p> : null}
    </div>
  );
}
