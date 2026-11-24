"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

import type { SavedProfile } from "@/components/profile/profile-data";
import { logoutFromProfile } from "@/lib/auth/client";

type ProfileBannerProps = {
  profile: SavedProfile | null;
  name: string;
  roleTitle: string;
  fanTitle?: string;
};

export function ProfileBanner({ profile, name, roleTitle, fanTitle }: ProfileBannerProps) {
  const router = useRouter();
  const [loggingOut, setLoggingOut] = useState(false);

  const initials =
    `${profile?.firstName?.slice(0, 1) ?? ""}${profile?.lastName?.slice(0, 1) ?? ""}`
      .trim()
      .toUpperCase() || name.slice(0, 1).toUpperCase();

  const meta = [profile?.region, profile?.phone, profile?.email].filter(
    (item): item is string => Boolean(item && item.trim()),
  );

  async function onLogout() {
    setLoggingOut(true);
    try {
      await logoutFromProfile();
      router.replace("/login");
    } finally {
      setLoggingOut(false);
    }
  }

  return (
    <header className="rounded-3xl border border-line bg-surface p-6 sm:p-8">
      <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-start gap-4 sm:items-center sm:gap-5">
          <div className="flex h-16 w-16 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-accent font-display text-2xl font-medium text-paper sm:h-20 sm:w-20 sm:text-3xl">
            {profile?.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={profile.avatarUrl} alt={name} className="h-full w-full object-cover" />
            ) : (
              initials
            )}
          </div>

          <div className="min-w-0">
            <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink sm:text-4xl">
              {name}
            </h1>

            <div className="mt-2.5 flex flex-wrap items-center gap-2">
              <span className="rounded-full bg-accent-soft px-3 py-1 text-xs font-medium text-accent">
                {roleTitle}
              </span>
              {fanTitle ? (
                <span className="rounded-full border border-line bg-paper px-3 py-1 text-xs font-medium text-ink-muted">
                  {fanTitle}
                </span>
              ) : null}
            </div>

            {meta.length > 0 ? (
              <p className="mt-3 flex flex-wrap items-center gap-x-2.5 gap-y-1 text-xs text-ink-muted tabular-nums">
                {meta.map((item, idx) => (
                  <span key={item} className="inline-flex items-center gap-2.5">
                    {idx > 0 ? (
                      <span aria-hidden className="text-line-strong">
                        ·
                      </span>
                    ) : null}
                    <span>{item}</span>
                  </span>
                ))}
              </p>
            ) : null}
          </div>
        </div>

        <button
          type="button"
          onClick={onLogout}
          disabled={loggingOut}
          className="w-fit shrink-0 self-start rounded-full border border-line bg-paper px-4 py-2 text-xs font-medium text-ink-muted transition-colors hover:border-red-300 hover:bg-red-50 hover:text-red-700 disabled:opacity-60 sm:self-center"
        >
          {loggingOut ? "Chiqilmoqda..." : "Profildan chiqish"}
        </button>
      </div>
    </header>
  );
}
