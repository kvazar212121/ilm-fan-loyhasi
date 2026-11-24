"use client";

import { useEffect, useState } from "react";

import type { BackendUser } from "@/lib/auth/client";

type RegistrationPhoneFieldProps = {
  phone: string;
  verified: boolean;
  onPhoneChange: (next: string) => void;
  onVerified: (verifiedPhone: string) => void;
  onAuthenticated: (user: BackendUser) => void;
};

const fieldClass =
  "w-full rounded-xl border border-line bg-paper px-3.5 py-2.5 text-sm text-ink tabular-nums outline-none transition-colors focus:border-accent focus:bg-surface";

export function RegistrationPhoneField({
  phone,
  verified,
  onPhoneChange,
  onVerified,
  onAuthenticated,
}: RegistrationPhoneFieldProps) {
  const [code, setCode] = useState("");
  const [sentTo, setSentTo] = useState<string | null>(null);
  const [cooldown, setCooldown] = useState(0);
  const [busy, setBusy] = useState(false);
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
    setBusy(true);
    try {
      const res = await fetch("/api/auth/otp/sms", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: phone.trim() }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        if (typeof data.retry_after_seconds === "number") setCooldown(data.retry_after_seconds);
        setError(data.message || "SMS yuborib bo‘lmadi");
        return;
      }
      setSentTo(data.phone_masked || phone.trim());
      setCooldown(typeof data.resend_after_seconds === "number" ? data.resend_after_seconds : 60);
      setCode("");
      if (isResend) setNotice("Yangi tasdiqlash kodi yuborildi.");
    } finally {
      setBusy(false);
    }
  }

  async function verifyCode() {
    setError(null);
    setNotice(null);
    setBusy(true);
    try {
      const res = await fetch("/api/auth/registration/verify-phone", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: phone.trim(), code: code.trim() }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(data.message || "Kod noto‘g‘ri");
        return;
      }
      if (data.status === "authenticated" && data.user) {
        onAuthenticated(data.user);
        return;
      }
      setSentTo(null);
      setCode("");
      onVerified(phone.trim());
    } finally {
      setBusy(false);
    }
  }

  if (verified) {
    return (
      <div className="flex flex-col gap-1 sm:col-span-2">
        <span className="text-xs font-medium text-ink-muted">Telefon raqam</span>
        <div className="relative">
          <input value={phone} disabled className={`${fieldClass} disabled:bg-surface-muted disabled:text-ink-muted`} />
          <span className="absolute top-1/2 right-3 -translate-y-1/2 rounded-full bg-accent-soft px-2.5 py-0.5 text-xs font-medium text-accent">
            Tasdiqlangan
          </span>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-2 sm:col-span-2">
      <span className="text-xs font-medium text-ink-muted">Telefon raqam (SMS tasdiqlash shart)</span>
      <div className="flex flex-wrap gap-2">
        <input
          value={phone}
          onChange={(e) => onPhoneChange(e.target.value)}
          disabled={Boolean(sentTo)}
          placeholder="+998 90 123 45 67"
          inputMode="tel"
          className={`${fieldClass} min-w-48 flex-1 disabled:bg-surface-muted`}
        />
        {!sentTo ? (
          <button
            type="button"
            disabled={busy}
            onClick={() => requestCode(false)}
            className="shrink-0 rounded-xl bg-accent px-4 py-2.5 text-xs font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-60"
          >
            {busy ? "Yuborilmoqda..." : "SMS kod olish"}
          </button>
        ) : null}
      </div>

      {sentTo ? (
        <div className="flex flex-col gap-2.5 rounded-xl border border-line bg-paper p-3.5">
          <p className="text-xs text-ink-muted tabular-nums">
            {sentTo} raqamiga yuborilgan 5 xonali kodni kiriting:
          </p>
          <div className="flex flex-wrap gap-2">
            <input
              value={code}
              onChange={(e) => setCode(e.target.value)}
              placeholder="00000"
              inputMode="numeric"
              maxLength={6}
              autoComplete="one-time-code"
              className="w-36 rounded-xl border border-line bg-surface px-3 py-2 text-center text-sm tracking-[0.25em] text-ink tabular-nums outline-none focus:border-accent"
            />
            <button
              type="button"
              disabled={busy || code.trim().length < 4}
              onClick={verifyCode}
              className="rounded-full bg-accent px-4 py-2 text-xs font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-60"
            >
              {busy ? "Tekshirilmoqda..." : "Tasdiqlash"}
            </button>
            <button
              type="button"
              onClick={() => {
                setSentTo(null);
                setCode("");
                setError(null);
              }}
              className="rounded-full border border-line bg-surface px-3 py-2 text-xs text-ink-muted hover:text-ink"
            >
              O‘zgartirish
            </button>
          </div>
          <button
            type="button"
            disabled={cooldown > 0 || busy}
            onClick={() => requestCode(true)}
            className="w-fit text-xs font-medium text-accent disabled:text-ink-muted tabular-nums"
          >
            {cooldown > 0 ? `Qayta yuborish (${cooldown}s)` : "Kodni qayta yuborish"}
          </button>
        </div>
      ) : null}

      {notice ? <p className="text-xs font-medium text-accent">{notice}</p> : null}
      {error ? <p className="text-xs text-red-700">{error}</p> : null}
    </div>
  );
}
