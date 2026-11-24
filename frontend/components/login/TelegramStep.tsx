"use client";

import { useEffect, useState } from "react";

import type { BackendUser } from "@/lib/auth/client";

type TelegramStepProps = {
  qrToken?: string;
  onBack: () => void;
  onAuthenticated: (user: BackendUser) => void;
  onRegistrationRequired: () => void;
  onCompletedElsewhere?: () => void;
};

export function TelegramStep({
  qrToken,
  onBack,
  onAuthenticated,
  onRegistrationRequired,
  onCompletedElsewhere,
}: TelegramStepProps) {
  const [attemptNo, setAttemptNo] = useState(0);
  const [deepLink, setDeepLink] = useState<string | null>(null);
  const [botUsername, setBotUsername] = useState<string>("");
  const [botOpened, setBotOpened] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    let timer: ReturnType<typeof setInterval> | null = null;

    async function start() {
      setError(null);
      setDeepLink(null);
      setBotOpened(false);
      const res = await fetch("/api/auth/telegram/start", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(qrToken ? { qr_token: qrToken } : {}),
      });
      const data = await res.json().catch(() => ({}));
      if (!active) return;
      if (!res.ok || !data.deep_link) {
        setError(data.message || "Telegram kirishni boshlab bo‘lmadi");
        return;
      }
      setDeepLink(data.deep_link);
      setBotUsername(data.bot_username || "");

      timer = setInterval(async () => {
        const pollRes = await fetch("/api/auth/telegram/poll", { method: "POST" });
        const poll = await pollRes.json().catch(() => ({}));
        if (!active) return;
        if (!pollRes.ok) {
          if (timer) clearInterval(timer);
          if (qrToken && pollRes.status === 409 && onCompletedElsewhere) {
            onCompletedElsewhere();
            return;
          }
          setError(poll.message || "Telegram tasdiqlash bekor qilindi");
          return;
        }
        if (poll.status === "pending") {
          setBotOpened(Boolean(poll.bot_opened));
          return;
        }
        if (timer) clearInterval(timer);
        if (poll.status === "authenticated" && poll.user) onAuthenticated(poll.user);
        else if (poll.status === "registration_required") onRegistrationRequired();
      }, 2000);
    }

    start();
    return () => {
      active = false;
      if (timer) clearInterval(timer);
    };
  }, [attemptNo, qrToken, onAuthenticated, onRegistrationRequired, onCompletedElsewhere]);

  return (
    <div className="flex flex-col gap-6">
      <div className="space-y-2">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink-muted transition-colors hover:text-ink"
        >
          ← Kirish usullari
        </button>
        <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
          Telegram orqali kirish
        </h1>
        <p className="text-sm leading-6 text-ink-muted">
          {qrToken
            ? "Botni oching va «Tasdiqlash» tugmasini bosing — kompyuter avtomatik kiradi."
            : "Botni oching, kontaktingizni ulashing va «Tasdiqlash» tugmasini bosing."}
        </p>
      </div>

      {deepLink ? (
        <div className="space-y-4 rounded-xl border border-line bg-paper p-5">
          <a
            href={deepLink}
            target="_blank"
            rel="noopener noreferrer"
            className="flex w-full items-center justify-center gap-2 rounded-full bg-accent px-5 py-3.5 text-sm font-medium text-paper transition-colors hover:bg-accent-hover"
          >
            Telegram botni ochish {botUsername ? `(@${botUsername})` : ""}
            <span aria-hidden>↗</span>
          </a>
          <div className="flex flex-wrap items-center justify-between gap-2 text-xs text-ink-muted">
            <span>
              {botOpened
                ? "Bot ochildi — Telegram’da «Tasdiqlash» tugmasini bosing..."
                : "Tasdiqlash kutilmoqda..."}
            </span>
            <button
              type="button"
              onClick={() => setAttemptNo((n) => n + 1)}
              className="font-medium text-accent underline-offset-4 hover:underline"
            >
              Yangi havola olish
            </button>
          </div>
        </div>
      ) : !error ? (
        <p className="rounded-xl border border-line bg-paper px-4 py-3 text-sm text-ink-muted">
          Telegram havolasi tayyorlanmoqda...
        </p>
      ) : null}

      {error ? (
        <div className="space-y-3 rounded-xl bg-red-50 p-4">
          <p className="text-sm text-red-700">{error}</p>
          <button
            type="button"
            onClick={() => setAttemptNo((n) => n + 1)}
            className="rounded-full border border-red-200 bg-surface px-4 py-2 text-xs font-medium text-ink transition-colors hover:border-accent"
          >
            Qayta urinish
          </button>
        </div>
      ) : null}
    </div>
  );
}
