"use client";

import { useEffect, useState, type FormEvent } from "react";

import type { BackendUser } from "@/lib/auth/client";

export type LinkedIdentity = {
  id: number;
  provider: "google" | "telegram" | "phone";
  display_name?: string;
};

type PhoneLinkInlineProps = {
  initialPhone?: string | null;
  onCancel: () => void;
  onLinked: (user: BackendUser, methods: LinkedIdentity[], merged: boolean) => void;
};

export function PhoneLinkInline({ initialPhone, onCancel, onLinked }: PhoneLinkInlineProps) {
  const [phone, setPhone] = useState(initialPhone || "+998");
  const [code, setCode] = useState("");
  const [sentTo, setSentTo] = useState<string | null>(null);
  const [cooldown, setCooldown] = useState(0);
  const [loading, setLoading] = useState(false);
  const [resending, setResending] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (cooldown <= 0) return;
    const t = setInterval(() => setCooldown((s) => (s > 1 ? s - 1 : 0)), 1000);
    return () => clearInterval(t);
  }, [cooldown]);

  async function requestCode(isResend: boolean) {
    setError(null);
    setNotice(null);
    if (isResend) setResending(true);
    else setLoading(true);
    try {
      const res = await fetch("/api/auth/otp/sms", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: phone.trim() }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        if (typeof data.retry_after_seconds === "number") setCooldown(data.retry_after_seconds);
        return setError(data.message || "SMS yuborib bo‘lmadi");
      }
      setSentTo(data.phone_masked || phone.trim());
      setCooldown(typeof data.resend_after_seconds === "number" ? data.resend_after_seconds : 60);
      setCode("");
      if (isResend) setNotice("Yangi kod yuborildi.");
    } finally {
      setLoading(false);
      setResending(false);
    }
  }

  async function onSend(e: FormEvent) {
    e.preventDefault();
    await requestCode(false);
  }

  async function onVerify(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setNotice(null);
    setLoading(true);
    try {
      const res = await fetch("/api/auth/link/phone/verify", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: phone.trim(), code: code.trim() }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.user) return setError(data.message || "Kod noto‘g‘ri");
      onLinked(data.user, data.methods || [], Boolean(data.merged));
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={sentTo ? onVerify : onSend} className="mt-3.5 flex flex-col gap-3 rounded-xl border border-line bg-paper p-4">
      <p className="text-xs leading-5 text-ink-muted tabular-nums">
        {sentTo
          ? `${sentTo} raqamiga yuborilgan 5 xonali kodni kiriting:`
          : "Tasdiqlash kodi olish uchun telefon raqamingizni kiriting:"}
      </p>
      <div className="flex flex-wrap gap-2">
        {!sentTo ? (
          <input
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="+998 90 123 45 67"
            inputMode="tel"
            className="min-w-48 flex-1 rounded-xl border border-line bg-surface px-3.5 py-2 text-sm text-ink tabular-nums outline-none transition-colors focus:border-accent"
          />
        ) : (
          <input
            value={code}
            onChange={(e) => setCode(e.target.value)}
            placeholder="00000"
            inputMode="numeric"
            maxLength={6}
            className="w-36 rounded-xl border border-line bg-surface px-3.5 py-2 text-center text-sm tracking-[0.25em] text-ink tabular-nums outline-none transition-colors focus:border-accent"
          />
        )}
        <button
          type="submit"
          disabled={loading}
          className="rounded-full bg-accent px-4 py-2 text-xs font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-60"
        >
          {loading ? "Kutilmoqda..." : sentTo ? "Tasdiqlash" : "Kod yuborish"}
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="rounded-full border border-line bg-surface px-3.5 py-2 text-xs font-medium text-ink-muted transition-colors hover:border-line-strong hover:text-ink"
        >
          Bekor qilish
        </button>
      </div>
      {sentTo ? (
        <div className="flex flex-wrap items-center gap-4 pt-0.5 tabular-nums">
          <button
            type="button"
            disabled={cooldown > 0 || resending}
            onClick={() => requestCode(true)}
            className="text-xs font-medium text-accent transition-colors hover:text-accent-hover disabled:text-ink-muted"
          >
            {resending
              ? "Yuborilmoqda..."
              : cooldown > 0
                ? `Qayta yuborish (${cooldown}s)`
                : "Kodni qayta yuborish"}
          </button>
          <button
            type="button"
            onClick={() => {
              setSentTo(null);
              setCode("");
              setError(null);
            }}
            className="text-xs text-ink-muted transition-colors hover:text-ink"
          >
            Raqamni o‘zgartirish
          </button>
        </div>
      ) : null}
      {notice ? <p className="text-xs font-medium text-accent">{notice}</p> : null}
      {error ? <p className="text-xs text-red-700">{error}</p> : null}
    </form>
  );
}
