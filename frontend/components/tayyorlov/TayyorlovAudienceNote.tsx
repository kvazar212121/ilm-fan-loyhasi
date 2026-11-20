"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import {
  readStoredProfileRaw,
  subscribeProfileStore,
  type SavedProfile,
} from "@/components/profile/profile-data";
import { getTayyorlovFan, titlesForFans } from "@/components/tayyorlov/tayyorlov-fans";
import type { TrackId } from "@/components/tayyorlov/tracks";

const box = "rounded-2xl border border-line bg-white px-5 py-4 text-sm text-ink/75";

export function TayyorlovAudienceNote({ track }: { track: TrackId }) {
  const [profile, setProfile] = useState<SavedProfile | null>(null);

  useEffect(() => {
    const sync = () => {
      const raw = readStoredProfileRaw();
      setProfile(raw ? (JSON.parse(raw) as SavedProfile) : null);
    };
    sync();
    return subscribeProfileStore(sync);
  }, []);

  if (!profile?.role) return null;
  const fanTitle =
    profile.role === "applicant"
      ? titlesForFans(profile.fanIds ?? [])
      : (getTayyorlovFan(profile.fanId ?? "")?.title ?? "");

  if (track === "sertifikat" && profile.role === "cert-teacher") {
    return (
      <p className="rounded-2xl border border-accent/25 bg-accent/5 px-5 py-4 text-sm text-ink/75">
        Sertifikatga tayyorlov{fanTitle ? `: ${fanTitle}` : ""}. Shu fan bo‘yicha video va testlarni oching.
      </p>
    );
  }

  if (track === "abituriyent" && profile.role === "applicant") {
    return (
      <p className="rounded-2xl border border-accent/25 bg-accent/5 px-5 py-4 text-sm text-ink/75">
        Abituriyent tayyorlovi{fanTitle ? `: ${fanTitle}` : ""}. Shu fanlardagi darslar va testlar ochiladi.
      </p>
    );
  }

  if (profile.role === "pupil" || profile.role === "student") {
    return (
      <p className={box}>
        Bu yo‘l imtihonga tayyorlanayotganlar uchun. Sizga ustoz bergan vazifalar testlar bo‘limida.
      </p>
    );
  }

  const other = track === "sertifikat" ? "/tayyorlov/abituriyent" : "/tayyorlov/sertifikat";
  const otherLabel = track === "sertifikat" ? "Abituriyent tayyorlovi" : "Sertifikatga tayyorlov";

  return (
    <p className={box}>
      {track === "sertifikat"
        ? "Bu yo‘l o‘qituvchining sertifikat imtihoni uchun."
        : "Bu yo‘l abituriyentning kirish imtihonlari uchun."}{" "}
      <Link href={other} className="font-medium text-accent hover:underline">
        {otherLabel}
      </Link>
    </p>
  );
}
