"use client";

import Link from "next/link";
import { useSyncExternalStore } from "react";

import { studentProfileKey, type SavedProfile } from "@/components/profile/profile-data";

function readProfileRaw() {
  return sessionStorage.getItem(studentProfileKey);
}

export function TayyorlovAudienceNote() {
  const raw = useSyncExternalStore(emptySubscribe, readProfileRaw, emptySnapshot);
  const profile = raw ? (JSON.parse(raw) as SavedProfile) : null;

  if (profile?.role === "teacher") {
    return (
      <p className="rounded-2xl border border-accent/25 bg-accent/5 px-5 py-4 text-sm text-ink/75">
        Siz o‘qituvchi sifatida kirgansiz. Fan tanlab, shu fan bo‘yicha video va testlarni
        oching.
      </p>
    );
  }

  if (profile?.role === "pupil" || profile?.role === "student") {
    return (
      <p className="rounded-2xl border border-line bg-white px-5 py-4 text-sm text-ink/75">
        Tayyorlovlar faqat sertifikat imtihoniga tayyorlanuvchi{" "}
        <strong className="font-medium text-ink">o‘qituvchilar</strong> uchun. Darsliklar va
        shaxsiy materiallar boshqa bo‘limlarda.
      </p>
    );
  }

  return (
    <p className="rounded-2xl border border-line bg-white px-5 py-4 text-sm text-ink/75">
      Bu bo‘lim o‘qituvchilar uchun.{" "}
      <Link href="/login" className="font-medium text-accent hover:underline">
        Kirish
      </Link>{" "}
      qilib, rolni <strong className="font-medium text-ink">O‘qituvchi</strong> tanlang.
    </p>
  );
}

function emptySubscribe() {
  return () => {};
}

function emptySnapshot() {
  return null;
}