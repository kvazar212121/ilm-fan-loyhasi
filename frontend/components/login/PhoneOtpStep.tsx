"use client";

import { useEffect, useState, type FormEvent } from "react";

import type { BackendUser } from "@/lib/auth/client";

type PhoneOtpStepProps = {
  onBack: () => void;
  onAuthenticated: (user: BackendUser) => void;
  onRegistrationRequired: () => void;
};

export function PhoneOtpStep({
  onBack,
  onAuthenticated,
  onRegistrationRequired,
}: PhoneOtpStepProps) {
  const [phone, setPhone] = useState("+998");
  const [code, setCode] = useState("");
  const [sentPhone, setSentPhone] = useState<string | null>(null);
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
        setError(data.message || "SMS yuborib bo‘lmadi");
        return;
      }
      setSentPhone(data.phone_masked || phone.trim());
      setCooldown(typeof data.resend_after_seconds === "number" ? data.resend_after_seconds : 60);
      setCode("");
      if (isResend) setNotice("Yangi tasdiqlash kodi yuborildi.");
    } finally {
      setLoading(false);
      setResending(false);
    }
  }

  async function onSendCode(e: FormEvent) {
    e.preventDefault();
    await requestCode(false);
  }

  async function onVerify(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setNotice(null);
    setLoading(true);
    try {
      const res = await fetch("/api/auth/otp/verify", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: phone.trim(), code: code.trim() }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(data.message || "Kod noto‘g‘ri");
        return;
      }
      if (data.status === "authenticated" && data.user) onAuthenticated(data.user);
      else if (data.status === "registration_required") onRegistrationRequired();
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={sentPhone ? onVerify : onSendCode} className="flex flex-col gap-6">
      <div className="space-y-2">
        <button
          type="button"
          onClick={
            sentPhone
              ? () => {
                  setSentPhone(null);
                  setCode("");
                  setError(null);
                  setNotice(null);
                }
              : onBack
          }
          className="w-fit text-sm text-ink-muted transition-colors hover:text-ink"
        >
          {sentPhone ? "← Raqamni o‘zgartirish" : "← Kirish usullari"}
        </button>
        <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
          {sentPhone ? "SMS kodni kiriting" : "Telefon raqam bilan kirish"}
        </h1>
        <p className="text-sm leading-6 text-ink-muted">
          {sentPhone
            ? `${sentPhone} raqamiga yuborilgan 5 xonali tasdiqlash kodini kiriting.`
            : "Tasdiqlash kodi olish uchun telefon raqamingizni kiriting."}
        </p>
      </div>

      {!sentPhone ? (
        <label className="flex flex-col gap-1.5">
          <span className="text-xs font-medium text-ink-muted">Telefon raqam</span>
          <input
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="+998 90 123 45 67"
            inputMode="tel"
            autoComplete="tel"
            className="rounded-xl border border-line bg-paper px-4 py-3 text-base text-ink tabular-nums outline-none transition-colors focus:border-accent focus:bg-surface"
          />
        </label>
      ) : (
        <div className="flex flex-col gap-3">
          <label className="flex flex-col gap-1.5">
            <span className="text-xs font-medium text-ink-muted">5 xonali kod</span>
            <input
              value={code}
              onChange={(e) => setCode(e.target.value)}
              placeholder="• • • • •"
              inputMode="numeric"
              maxLength={6}
              autoComplete="one-time-code"
              className="rounded-xl border border-line bg-paper px-4 py-3.5 text-center text-2xl font-semibold tracking-[0.35em] text-ink tabular-nums outline-none transition-colors focus:border-accent focus:bg-surface"
            />
          </label>
          <button
            type="button"
            disabled={cooldown > 0 || resending}
            onClick={() => requestCode(true)}
            className="w-fit text-sm font-medium text-accent transition-opacity hover:opacity-80 disabled:cursor-not-allowed disabled:text-ink-muted"
          >
            {resending
              ? "Yuborilmoqda..."
              : cooldown > 0
                ? `Kodni qayta yuborish (${cooldown}s)`
                : "Kodni qayta yuborish"}
          </button>
        </div>
      )}

      {notice ? <p className="rounded-xl bg-accent-soft px-3.5 py-2.5 text-sm text-accent">{notice}</p> : null}
      {error ? <p className="rounded-xl bg-red-50 px-3.5 py-2.5 text-sm text-red-700">{error}</p> : null}

      <button
        type="submit"
        disabled={loading}
        className="rounded-full bg-accent px-6 py-3.5 text-sm font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-60"
      >
        {loading ? "Kutilmoqda..." : sentPhone ? "Tasdiqlash" : "SMS kod yuborish"}
      </button>
    </form>
  );
}
