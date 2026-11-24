"use client";

import { useCallback, useEffect, useState } from "react";

import { PhoneOtpStep } from "@/components/login/PhoneOtpStep";
import { QrApprovePanel } from "@/components/login/QrApprovePanel";
import { TelegramStep } from "@/components/login/TelegramStep";
import type { BackendUser } from "@/lib/auth/client";

type QrApproveFlowProps = {
  token: string;
  initialView: "ready" | "done" | "invalid";
  initialDevice: string;
  initialNewHandoff: boolean;
  initialError: string | null;
};

type ViewMode = "ready" | "telegram" | "phone" | "done" | "rejected" | "invalid";

export function QrApproveFlow({
  token,
  initialView,
  initialDevice,
  initialNewHandoff,
  initialError,
}: QrApproveFlowProps) {
  const [view, setView] = useState<ViewMode>(initialView);
  const [isNewHandoff, setIsNewHandoff] = useState(initialNewHandoff);
  const [me, setMe] = useState<BackendUser | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(initialError);

  useEffect(() => {
    if (initialView !== "ready") return;
    let active = true;
    fetch("/api/auth/me")
      .then((r) => (r.ok ? r.json() : null))
      .then((data) => {
        if (active && data?.user) setMe(data.user);
      })
      .catch(() => { });
    return () => {
      active = false;
    };
  }, [initialView]);

  const approveQr = useCallback(
    async (mode: "session" | "registration") => {
      setBusy(true);
      setError(null);
      try {
        const res = await fetch("/api/auth/qr/approve", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ qr_token: token, mode }),
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) {
          setError(data.message || "Tasdiqlashda xatolik");
          setView("ready");
          return;
        }
        setIsNewHandoff(mode === "registration");
        setView("done");
      } finally {
        setBusy(false);
      }
    },
    [token],
  );

  async function onGoogleVerify() {
    setBusy(true);
    setError(null);
    try {
      const res = await fetch("/api/auth/google/start", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ qr_token: token }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.authorization_url) {
        setError(data.message || "Google tasdiqlashni boshlab bo‘lmadi");
        return;
      }
      window.location.href = data.authorization_url;
    } finally {
      setBusy(false);
    }
  }

  async function onReject() {
    setBusy(true);
    try {
      await fetch("/api/auth/qr/reject", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ qr_token: token }),
      });
      setView("rejected");
    } finally {
      setBusy(false);
    }
  }

  const meName = me ? `${me.first_name || ""} ${me.last_name || ""}`.trim() || me.email || me.phone || "" : "";

  return (
    <main className="mx-auto flex min-h-dvh w-full max-w-md flex-col justify-center px-5 py-8">
      <div className="mb-5 flex items-center gap-2.5">
        <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-accent text-paper">
          <svg viewBox="0 0 20 20" className="h-4 w-4" fill="none" aria-hidden>
            <path
              d="M4 5.5C6.2 4.7 8.4 5 10 6.2C11.6 5 13.8 4.7 16 5.5V15C13.8 14.2 11.6 14.5 10 15.7C8.4 14.5 6.2 14.2 4 15V5.5Z"
              stroke="currentColor"
              strokeWidth="1.5"
              strokeLinejoin="round"
            />
            <path d="M10 6.2V15.5" stroke="currentColor" strokeWidth="1.4" />
          </svg>
        </span>
        <span className="font-display text-lg font-medium tracking-[-0.015em] text-ink">
          Ilm Fan
        </span>
      </div>

      <section className="rounded-2xl border border-line bg-surface p-6">
        {view === "done" ? (
          <div className="space-y-3 py-2">
            <span className="inline-flex rounded-full bg-accent-soft px-3.5 py-1 text-xs font-medium text-accent">
              Tasdiqlandi
            </span>
            <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
              Kompyuterda kirish tasdiqlandi
            </h1>
            <p className="text-sm leading-6 text-ink-muted">
              {isNewHandoff
                ? "Kompyuter ekraniga qayting va ro‘yxatdan o‘tishni yakunlang."
                : "Kompyuter ekraniga qaytishingiz mumkin — profilingiz avtomatik ochildi."}
            </p>
          </div>
        ) : view === "rejected" || view === "invalid" ? (
          <div className="space-y-3 py-2">
            <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
              {view === "rejected" ? "So‘rov rad etildi" : "QR kod yaroqsiz"}
            </h1>
            <p className="text-sm leading-6 text-ink-muted">
              {view === "rejected"
                ? "Kompyuterdan kirish so‘rovi bekor qilindi."
                : error || "Ushbu QR kod eskirgan yoki ishlatilgan. Kompyuterda yangisini oling."}
            </p>
          </div>
        ) : view === "phone" ? (
          <PhoneOtpStep
            onBack={() => setView("ready")}
            onAuthenticated={() => approveQr("session")}
            onRegistrationRequired={() => approveQr("registration")}
          />
        ) : view === "telegram" ? (
          <TelegramStep
            qrToken={token}
            onBack={() => setView("ready")}
            onAuthenticated={() => approveQr("session")}
            onRegistrationRequired={() => approveQr("registration")}
            onCompletedElsewhere={() => setView("done")}
          />
        ) : (
          <QrApprovePanel
            device={initialDevice}
            meName={meName}
            busy={busy}
            error={error}
            onApproveSession={() => approveQr("session")}
            onSelectMethod={(id) => (id === "google" ? onGoogleVerify() : setView(id))}
            onReject={onReject}
          />
        )}
      </section>
    </main>
  );
}
