"use client";

import { useState, type FormEvent } from "react";

import {
  genderLabel,
  genderOptions,
  uzRegions,
  type GenderId,
} from "@/components/login/profile-options";
import type { StudentProfileData } from "@/components/profile/profile-data";
import { saveBackendUserToProfile } from "@/lib/auth/client";

type ProfileSettingsProps = {
  profile: StudentProfileData | null;
};

const fieldClass =
  "w-full rounded-xl border border-line bg-paper px-3.5 py-2.5 text-sm text-ink outline-none transition-colors focus:border-accent focus:bg-surface";

export function ProfileSettings({ profile }: ProfileSettingsProps) {
  const [editing, setEditing] = useState(false);
  const [firstName, setFirstName] = useState(profile?.firstName ?? "");
  const [lastName, setLastName] = useState(profile?.lastName ?? "");
  const [phone, setPhone] = useState(profile?.phone ?? "");
  const [birthDate, setBirthDate] = useState(profile?.birthDate ?? "");
  const [region, setRegion] = useState(profile?.region ?? "");
  const [gender, setGender] = useState<GenderId | "">(profile?.gender ?? "");
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  function startEdit() {
    setFirstName(profile?.firstName ?? "");
    setLastName(profile?.lastName ?? "");
    setPhone(profile?.phone ?? "");
    setBirthDate(profile?.birthDate ?? "");
    setRegion(profile?.region ?? "");
    setGender(profile?.gender ?? "");
    setNotice(null);
    setError(null);
    setEditing(true);
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!firstName.trim() || !lastName.trim() || !birthDate || !region || !gender) {
      setError("Barcha majburiy maydonlarni to‘ldiring.");
      return;
    }
    setSaving(true);
    setError(null);
    try {
      const res = await fetch("/api/auth/profile", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          first_name: firstName.trim(),
          last_name: lastName.trim(),
          phone: phone.trim(),
          birth_date: birthDate,
          region,
          gender,
          avatar_url: profile?.avatarUrl || "",
        }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.user) {
        setError(data.message || "Saqlashda xatolik");
        return;
      }
      saveBackendUserToProfile(data.user);
      setEditing(false);
      setNotice("Profil ma’lumotlari saqlandi.");
    } finally {
      setSaving(false);
    }
  }

  const rows = [
    { label: "Ism", value: profile?.firstName || "—", tabular: false },
    { label: "Familiya", value: profile?.lastName || "—", tabular: false },
    { label: "Telefon raqam", value: profile?.phone || "—", tabular: true },
    { label: "Email", value: profile?.email || "—", tabular: false },
    { label: "Tug‘ilgan sana", value: profile?.birthDate || "—", tabular: true },
    { label: "Viloyat", value: profile?.region || "—", tabular: false },
    { label: "Jinsi", value: genderLabel(profile?.gender), tabular: false },
  ];

  return (
    <section className="rounded-2xl border border-line bg-surface p-6">
      <div className="flex flex-wrap items-center justify-between gap-3 border-b border-line pb-4">
        <div>
          <h2 className="font-display text-xl font-medium tracking-[-0.015em] text-ink">
            Shaxsiy ma’lumotlar
          </h2>
          <p className="mt-0.5 text-xs text-ink-muted">
            Profilingizda ko‘rinadigan asosiy ma’lumotlar.
          </p>
        </div>
        {!editing ? (
          <button
            type="button"
            onClick={startEdit}
            className="rounded-full border border-line bg-paper px-4 py-1.5 text-xs font-medium text-ink transition-colors hover:border-accent hover:text-accent"
          >
            Tahrirlash
          </button>
        ) : null}
      </div>

      {notice && !editing ? (
        <p className="mt-4 rounded-xl bg-accent-soft px-3.5 py-2.5 text-xs font-medium text-accent">
          {notice}
        </p>
      ) : null}

      {!editing ? (
        <dl className="mt-5 grid grid-cols-1 gap-x-8 gap-y-4 sm:grid-cols-2">
          {rows.map((row) => (
            <div key={row.label} className="border-b border-line/70 pb-3 last:border-b-0 sm:border-b-0 sm:pb-0">
              <dt className="text-xs text-ink-muted">{row.label}</dt>
              <dd className={`mt-1 text-sm font-medium text-ink ${row.tabular ? "tabular-nums" : ""}`}>
                {row.value}
              </dd>
            </div>
          ))}
        </dl>
      ) : (
        <form onSubmit={onSubmit} className="mt-5 flex flex-col gap-4">
          <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2">
            <label className="flex flex-col gap-1">
              <span className="text-xs font-medium text-ink-muted">Ism</span>
              <input value={firstName} onChange={(e) => setFirstName(e.target.value)} placeholder="Ismingiz" className={fieldClass} />
            </label>
            <label className="flex flex-col gap-1">
              <span className="text-xs font-medium text-ink-muted">Familiya</span>
              <input value={lastName} onChange={(e) => setLastName(e.target.value)} placeholder="Familiyangiz" className={fieldClass} />
            </label>
            <label className="flex flex-col gap-1">
              <span className="text-xs font-medium text-ink-muted">Telefon raqam</span>
              <input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+998 90 123 45 67" inputMode="tel" className={`${fieldClass} tabular-nums`} />
            </label>
            <label className="flex flex-col gap-1">
              <span className="text-xs font-medium text-ink-muted">Tug‘ilgan sana</span>
              <input type="date" value={birthDate} onChange={(e) => setBirthDate(e.target.value)} max={new Date().toISOString().slice(0, 10)} className={`${fieldClass} tabular-nums`} />
            </label>
            <label className="flex flex-col gap-1">
              <span className="text-xs font-medium text-ink-muted">Viloyat</span>
              <select value={region} onChange={(e) => setRegion(e.target.value)} className={fieldClass}>
                <option value="">Viloyatni tanlang</option>
                {uzRegions.map((item) => (<option key={item} value={item}>{item}</option>))}
              </select>
            </label>
            <div className="flex flex-col gap-1">
              <span className="text-xs font-medium text-ink-muted">Jinsi</span>
              <div className="grid grid-cols-2 gap-2">
                {genderOptions.map((opt) => (
                  <button
                    key={opt.id}
                    type="button"
                    onClick={() => setGender(opt.id)}
                    className={`rounded-xl border px-3 py-2.5 text-sm font-medium transition-colors ${
                      gender === opt.id
                        ? "border-accent bg-accent text-paper"
                        : "border-line bg-paper text-ink hover:border-accent"
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {error ? <p className="rounded-xl bg-red-50 px-3.5 py-2.5 text-xs text-red-700">{error}</p> : null}

          <div className="flex flex-wrap gap-2.5 pt-1">
            <button
              type="submit"
              disabled={saving}
              className="rounded-full bg-accent px-5 py-2.5 text-sm font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-60"
            >
              {saving ? "Saqlanmoqda..." : "Saqlash"}
            </button>
            <button
              type="button"
              onClick={() => setEditing(false)}
              className="rounded-full border border-line bg-paper px-5 py-2.5 text-sm font-medium text-ink transition-colors hover:border-line-strong"
            >
              Bekor qilish
            </button>
          </div>
        </form>
      )}
    </section>
  );
}
