"use client";

import { useEffect, useState } from "react";

import { getRole } from "@/components/login/roles";
import {
  readStoredProfileRaw,
  subscribeProfileStore,
  type SavedProfile,
} from "@/components/profile/profile-data";
import { getTayyorlovFan, titlesForFans } from "@/components/tayyorlov/tayyorlov-fans";

export function FanScope() {
  const [profile, setProfile] = useState<SavedProfile | null>(null);

  useEffect(() => {
    const sync = () => {
      const raw = readStoredProfileRaw();
      setProfile(raw ? (JSON.parse(raw) as SavedProfile) : null);
    };
    sync();
    return subscribeProfileStore(sync);
  }, []);

  const role = getRole(profile?.role);
  if (!role) return null;

  if (role.id === "pupil") {
    return (
      <p className="rounded-2xl border border-accent/25 bg-accent/5 px-5 py-4 text-sm text-ink/75">
        O‘quvchi. Fan tanlanmaydi — ustoz bergan vazifalar ochiladi.
      </p>
    );
  }

  const fanLabel =
    role.id === "applicant"
      ? titlesForFans(profile?.fanIds ?? [])
      : (getTayyorlovFan(profile?.fanId ?? "")?.title ?? "");
  if (!fanLabel) return null;

  return (
    <p className="rounded-2xl border border-accent/25 bg-accent/5 px-5 py-4 text-sm text-ink/75">
      {role.title} · {fanLabel}.{" "}
      {role.id === "applicant"
        ? "Shu fanlardagi testlar ochiladi."
        : "Shu fandagi testlar va vazifalar ochiladi."}
    </p>
  );
}
