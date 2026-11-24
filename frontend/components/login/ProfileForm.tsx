"use client";

import { useState, type FormEvent } from "react";

import { RegistrationPhoneField } from "@/components/login/RegistrationPhoneField";
import {
  genderOptions,
  uzRegions,
  type GenderId,
} from "@/components/login/profile-options";
import type { BackendUser } from "@/lib/auth/client";

export type ProfileDraft = {
  firstName: string;
  lastName: string;
  phone: string;
  birthDate: string;
  region: string;
  gender: GenderId;
  avatarUrl: string | null;
};

type ProfileFormProps = {
  backLabel: string;
  initialFirstName?: string;
  initialLastName?: string;
  initialPhone?: string;
  initialBirthDate?: string;
  initialRegion?: string;
  initialGender?: GenderId | "";
  phoneVerified?: boolean;
  initialAvatarUrl?: string | null;
  submitting?: boolean;
  error?: string | null;
  onBack: () => void;
  onSave: (profile: ProfileDraft) => void;
  onAuthenticated: (user: BackendUser) => void;
};

const fieldClass =
  "w-full rounded-xl border border-line bg-paper px-3.5 py-2.5 text-sm text-ink outline-none transition-colors focus:border-accent focus:bg-surface";

export function ProfileForm({
  backLabel,
  initialFirstName = "",
  initialLastName = "",
  initialPhone = "",
  initialBirthDate = "",
  initialRegion = "",
  initialGender = "",
  phoneVerified: initialPhoneVerified = false,
  initialAvatarUrl = null,
  submitting = false,
  error = null,
  onBack,
  onSave,
  onAuthenticated,
}: ProfileFormProps) {
  const [firstName, setFirstName] = useState(initialFirstName);
  const [lastName, setLastName] = useState(initialLastName);
  const [phone, setPhone] = useState(initialPhone || "+998");
  const [phoneVerified, setPhoneVerified] = useState(initialPhoneVerified);
  const [birthDate, setBirthDate] = useState(initialBirthDate);
  const [region, setRegion] = useState(initialRegion);
  const [gender, setGender] = useState<GenderId | "">(initialGender);
  const [avatarUrl, setAvatarUrl] = useState<string | null>(initialAvatarUrl);
  const [validationError, setValidationError] = useState<string | null>(null);

  function onFile(file: File | undefined) {
    if (!file) return;
    setAvatarUrl(URL.createObjectURL(file));
  }

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const given = firstName.trim();
    const family = lastName.trim();
    if (!given || !family) return setValidationError("Ism va familiyani kiriting.");
    if (!phoneVerified) return setValidationError("Avval telefon raqamingizni SMS kod orqali tasdiqlang.");
    if (!birthDate) return setValidationError("Tug‘ilgan sanani tanlang.");
    if (!region) return setValidationError("Viloyatni tanlang.");
    if (!gender) return setValidationError("Jinsingizni tanlang.");
    setValidationError(null);
    onSave({ firstName: given, lastName: family, phone: phone.trim(), birthDate, region, gender, avatarUrl });
  }

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-5">
      <div className="space-y-1.5">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink-muted transition-colors hover:text-ink"
        >
          {backLabel}
        </button>
        <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
          Shaxsiy ma’lumotlar
        </h1>
        <p className="text-sm leading-6 text-ink-muted">
          Ma’lumotlaringizni kiriting va telefon raqamingizni SMS kod orqali tasdiqlang.
        </p>
      </div>

      <label className="flex w-fit cursor-pointer items-center gap-3.5">
        <span className="flex h-12 w-12 items-center justify-center overflow-hidden rounded-full border border-line bg-paper text-xs text-ink-muted">
          {avatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={avatarUrl} alt="" className="h-full w-full object-cover" />
          ) : (
            "Rasm"
          )}
        </span>
        <span className="text-xs font-medium text-ink-muted underline-offset-4 hover:text-ink hover:underline">
          Avatar yuklash (ixtiyoriy)
        </span>
        <input type="file" accept="image/*" className="sr-only" onChange={(e) => onFile(e.target.files?.[0])} />
      </label>

      <div className="grid gap-3.5 sm:grid-cols-2">
        <label className="flex flex-col gap-1">
          <span className="text-xs font-medium text-ink-muted">Ism</span>
          <input value={firstName} onChange={(e) => setFirstName(e.target.value)} placeholder="Ismingiz" autoComplete="given-name" className={fieldClass} />
        </label>
        <label className="flex flex-col gap-1">
          <span className="text-xs font-medium text-ink-muted">Familiya</span>
          <input value={lastName} onChange={(e) => setLastName(e.target.value)} placeholder="Familiyangiz" autoComplete="family-name" className={fieldClass} />
        </label>

        <RegistrationPhoneField
          phone={phone}
          verified={phoneVerified}
          onPhoneChange={setPhone}
          onVerified={(verifiedPhone) => {
            setPhone(verifiedPhone);
            setPhoneVerified(true);
            setValidationError(null);
          }}
          onAuthenticated={onAuthenticated}
        />

        <label className="flex flex-col gap-1">
          <span className="text-xs font-medium text-ink-muted">Tug‘ilgan sana</span>
          <input type="date" value={birthDate} onChange={(e) => setBirthDate(e.target.value)} max={new Date().toISOString().slice(0, 10)} className={`${fieldClass} tabular-nums`} />
        </label>
        <label className="flex flex-col gap-1">
          <span className="text-xs font-medium text-ink-muted">Viloyat</span>
          <select value={region} onChange={(e) => setRegion(e.target.value)} className={fieldClass}>
            <option value="">Tanlang</option>
            {uzRegions.map((item) => (
              <option key={item} value={item}>{item}</option>
            ))}
          </select>
        </label>
        <div className="flex flex-col gap-1 sm:col-span-2">
          <span className="text-xs font-medium text-ink-muted">Jinsi</span>
          <div className="grid grid-cols-2 gap-2.5">
            {genderOptions.map((opt) => (
              <button
                key={opt.id}
                type="button"
                onClick={() => setGender(opt.id)}
                className={`rounded-xl border px-4 py-2.5 text-sm font-medium transition-colors ${
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

      {validationError ? <p className="rounded-xl bg-surface-muted px-3.5 py-2.5 text-sm text-ink">{validationError}</p> : null}
      {error ? <p className="rounded-xl bg-red-50 px-3.5 py-2.5 text-sm text-red-700">{error}</p> : null}

      <button
        type="submit"
        disabled={submitting}
        className="mt-1 rounded-full bg-accent px-6 py-3.5 text-sm font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-60"
      >
        {submitting ? "Saqlanmoqda..." : "Davom etish"}
      </button>
    </form>
  );
}
