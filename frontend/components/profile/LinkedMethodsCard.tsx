"use client";

import { useCallback, useEffect, useState } from "react";

import { MethodIcon } from "@/components/login/MethodIcon";
import { PhoneLinkInline, type LinkedIdentity } from "@/components/profile/PhoneLinkInline";
import { TelegramLinkInline } from "@/components/profile/TelegramLinkInline";
import type { StudentProfileData } from "@/components/profile/profile-data";
import { saveBackendUserToProfile, type BackendUser } from "@/lib/auth/client";

type LinkedMethodsCardProps = {
  profile: StudentProfileData | null;
};

const providers = [
  { id: "google", label: "Google", actionLabel: "Ulash" },
  { id: "telegram", label: "Telegram", actionLabel: "Ulash" },
  { id: "phone", label: "Telefon raqam", actionLabel: "Tasdiqlash" },
] as const;

export function LinkedMethodsCard({ profile }: LinkedMethodsCardProps) {
  const [methods, setMethods] = useState<LinkedIdentity[]>([]);
  const [activeLink, setActiveLink] = useState<"telegram" | "phone" | null>(null);
  const [busyProvider, setBusyProvider] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get("linked") === "google") {
      setNotice(
        params.get("merged") === "1"
          ? "Eski akkauntingiz topildi va Google bilan bitta profilga birlashtirildi."
          : "Google akkauntingiz muvaffaqiyatli ulandi.",
      );
      window.history.replaceState({}, "", "/profile");
    } else if (params.get("link_error")) {
      setError(params.get("link_error"));
      window.history.replaceState({}, "", "/profile");
    }

    fetch("/api/auth/me")
      .then((r) => (r.ok ? r.json() : null))
      .then((data) => {
        if (data?.user) saveBackendUserToProfile(data.user);
        if (Array.isArray(data?.methods)) setMethods(data.methods);
      })
      .catch(() => {});
  }, []);

  const onLinkedSuccess = useCallback((user: BackendUser, nextMethods: LinkedIdentity[], msg: string) => {
    saveBackendUserToProfile(user);
    setMethods(nextMethods);
    setActiveLink(null);
    setError(null);
    setNotice(msg);
  }, []);

  async function onLinkGoogle() {
    setError(null);
    setNotice(null);
    setBusyProvider("google");
    try {
      const res = await fetch("/api/auth/link/google/start", { method: "POST" });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.authorization_url) {
        setError(data.message || "Google ulashni boshlab bo‘lmadi");
        return;
      }
      window.location.href = data.authorization_url;
    } finally {
      setBusyProvider(null);
    }
  }

  async function onUnlink(provider: "google" | "telegram" | "phone") {
    setError(null);
    setNotice(null);
    setBusyProvider(provider);
    try {
      const res = await fetch(`/api/auth/link/${provider}`, { method: "DELETE" });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(data.message || "Usulni uzib bo‘lmadi");
        return;
      }
      if (data.user) saveBackendUserToProfile(data.user);
      if (Array.isArray(data.methods)) setMethods(data.methods);
      setNotice("Kirish usuli uzildi.");
    } finally {
      setBusyProvider(null);
    }
  }

  const byProvider = new Map(methods.map((m) => [m.provider, m]));

  return (
    <section className="rounded-2xl border border-line bg-surface p-6">
      <div className="border-b border-line pb-4">
        <h2 className="font-display text-xl font-medium tracking-[-0.015em] text-ink">
          Kirish usullari
        </h2>
        <p className="mt-0.5 text-xs text-ink-muted">
          Google, Telegram va telefon raqamni bitta profilga ulab qo‘yishingiz mumkin (ixtiyoriy).
        </p>
      </div>

      {notice ? <p className="mt-4 rounded-xl bg-accent-soft px-3.5 py-2.5 text-xs font-medium text-accent">{notice}</p> : null}
      {error ? <p className="mt-4 rounded-xl bg-red-50 px-3.5 py-2.5 text-xs text-red-700">{error}</p> : null}

      <ul className="mt-2 flex flex-col divide-y divide-line">
        {providers.map((item) => {
          const linked = byProvider.get(item.id);
          return (
            <li key={item.id} className="py-4 last:pb-0">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-3.5">
                  <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-line bg-paper">
                    <MethodIcon id={item.id} />
                  </span>
                  <div>
                    <p className="text-sm font-medium text-ink">{item.label}</p>
                    <p className="text-xs text-ink-muted tabular-nums">
                      {linked ? linked.display_name || "Ulangan" : "Ulanmagan"}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  {linked ? (
                    <>
                      <span className="rounded-full bg-accent-soft px-3 py-1 text-xs font-medium text-accent">
                        {item.id === "phone" ? "Tasdiqlangan" : "Ulangan"}
                      </span>
                      {methods.length > 1 ? (
                        <button
                          type="button"
                          disabled={busyProvider === item.id}
                          onClick={() => onUnlink(item.id)}
                          className="rounded-full border border-line bg-paper px-3 py-1 text-xs font-medium text-ink-muted transition-colors hover:border-red-300 hover:bg-red-50 hover:text-red-700"
                        >
                          Uzish
                        </button>
                      ) : null}
                    </>
                  ) : (
                    <button
                      type="button"
                      disabled={busyProvider === item.id}
                      onClick={() => (item.id === "google" ? onLinkGoogle() : setActiveLink(item.id))}
                      className="rounded-full border border-line bg-paper px-4 py-1.5 text-xs font-medium text-ink transition-colors hover:border-accent hover:text-accent disabled:opacity-60"
                    >
                      {busyProvider === item.id ? "Kutilmoqda..." : item.actionLabel}
                    </button>
                  )}
                </div>
              </div>

              {item.id === "telegram" && activeLink === "telegram" ? (
                <TelegramLinkInline
                  onCancel={() => setActiveLink(null)}
                  onLinked={(u, m, merged) =>
                    onLinkedSuccess(
                      u,
                      m,
                      merged
                        ? "Eski akkauntingiz topildi va Telegram bilan bitta profilga birlashtirildi."
                        : "Telegram muvaffaqiyatli ulandi.",
                    )
                  }
                />
              ) : null}
              {item.id === "phone" && activeLink === "phone" ? (
                <PhoneLinkInline
                  initialPhone={profile?.phone}
                  onCancel={() => setActiveLink(null)}
                  onLinked={(u, m, merged) =>
                    onLinkedSuccess(
                      u,
                      m,
                      merged
                        ? "Eski akkauntingiz topildi va telefon raqami bilan bitta profilga birlashtirildi."
                        : "Telefon raqamingiz tasdiqlandi.",
                    )
                  }
                />
              ) : null}
            </li>
          );
        })}
      </ul>
    </section>
  );
}
