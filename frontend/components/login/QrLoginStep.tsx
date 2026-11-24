"use client";

import { useEffect, useState } from "react";
import QRCode from "qrcode";

import type { BackendUser } from "@/lib/auth/client";

type QrLoginStepProps = {
  onAuthenticated: (user: BackendUser) => void;
  onRegistrationRequired: () => void;
};

function formatTime(sec: number) {
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

export function QrLoginStep({
  onAuthenticated,
  onRegistrationRequired,
}: QrLoginStepProps) {
  const [attemptNo, setAttemptNo] = useState(0);
  const [qrDataUrl, setQrDataUrl] = useState<string | null>(null);
  const [secondsLeft, setSecondsLeft] = useState(0);
  const [scanned, setScanned] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (secondsLeft <= 0) return;
    const t = setInterval(() => setSecondsLeft((s) => (s > 1 ? s - 1 : 0)), 1000);
    return () => clearInterval(t);
  }, [secondsLeft]);

  useEffect(() => {
    let active = true;
    let pollTimer: ReturnType<typeof setInterval> | null = null;

    async function start() {
      setError(null);
      setQrDataUrl(null);
      setScanned(false);
      setSecondsLeft(0);

      const res = await fetch("/api/auth/qr/start", { method: "POST" });
      const data = await res.json().catch(() => ({}));
      if (!active) return;
      if (!res.ok || !data.qr_url) {
        setError(data.message || "QR kod yaratib bo‘lmadi");
        return;
      }

      const img = await QRCode.toDataURL(data.qr_url, {
        width: 260,
        margin: 2,
        errorCorrectionLevel: "M",
        color: { dark: "#171512", light: "#fbf9f4" },
      });
      if (!active) return;
      setQrDataUrl(img);
      setSecondsLeft(typeof data.expires_in_seconds === "number" ? data.expires_in_seconds : 180);

      pollTimer = setInterval(async () => {
        const pollRes = await fetch("/api/auth/qr/poll", { method: "POST" });
        const poll = await pollRes.json().catch(() => ({}));
        if (!active) return;
        if (!pollRes.ok) {
          if (pollTimer) clearInterval(pollTimer);
          setSecondsLeft(0);
          setError(poll.message || "QR kod muddati tugagan");
          return;
        }
        if (poll.status === "pending") {
          setScanned(Boolean(poll.scanned));
          return;
        }
        if (pollTimer) clearInterval(pollTimer);
        if (poll.status === "authenticated" && poll.user) onAuthenticated(poll.user);
        else if (poll.status === "registration_required") onRegistrationRequired();
      }, 2000);
    }

    start();
    return () => {
      active = false;
      if (pollTimer) clearInterval(pollTimer);
    };
  }, [attemptNo, onAuthenticated, onRegistrationRequired]);

  return (
    <div className="flex flex-col items-center gap-5 rounded-2xl border border-line bg-paper p-5 sm:flex-row sm:items-center">
      <div className="flex h-52 w-52 shrink-0 items-center justify-center overflow-hidden rounded-xl border border-line bg-surface p-2">
        {qrDataUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={qrDataUrl}
            alt="Hisobga kirish QR kodi"
            className={`h-full w-full transition-opacity ${error ? "opacity-25" : "opacity-100"}`}
          />
        ) : !error ? (
          <span className="text-xs text-ink-muted">QR tayyorlanmoqda...</span>
        ) : null}
      </div>

      <div className="flex flex-1 flex-col items-center gap-3 text-center sm:items-start sm:text-left">
        <div className="space-y-1">
          <h2 className="font-display text-xl font-medium tracking-[-0.015em] text-ink">
            QR kod orqali kirish
          </h2>
          <p className="text-xs leading-5 text-ink-muted">
            Telefon kamerasi bilan skanerlang va brauzerda Google, Telegram yoki SMS orqali
            tasdiqlang — kompyuter avtomatik kiradi.
          </p>
        </div>

        {scanned && !error ? (
          <p className="rounded-full bg-accent-soft px-3.5 py-1.5 text-xs font-medium text-accent">
            Telefon ulandi — tasdiqlash kutilmoqda...
          </p>
        ) : !error && qrDataUrl ? (
          <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-ink-muted tabular-nums">
            <span>
              Muddati: <strong className="font-semibold text-ink">{formatTime(secondsLeft)}</strong>
            </span>
            <button
              type="button"
              onClick={() => setAttemptNo((n) => n + 1)}
              className="font-medium text-accent underline-offset-4 hover:underline"
            >
              Yangilash
            </button>
          </div>
        ) : null}

        {error ? (
          <div className="flex flex-col items-center gap-2 sm:items-start">
            <p className="text-xs font-medium text-red-700">{error}</p>
            <button
              type="button"
              onClick={() => setAttemptNo((n) => n + 1)}
              className="rounded-full bg-accent px-4 py-1.5 text-xs font-medium text-paper transition-colors hover:bg-accent-hover"
            >
              Yangi QR kod
            </button>
          </div>
        ) : null}
      </div>
    </div>
  );
}
