"use client";

import { useState, type FormEvent } from "react";

type ProfileDraft = {
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
};

type ProfileFormProps = {
  step: string;
  backLabel: string;
  onBack: () => void;
  onSave: (profile: ProfileDraft) => void;
};

export function ProfileForm({ step, backLabel, onBack, onSave }: ProfileFormProps) {
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);
  const [missing, setMissing] = useState(false);

  function onFile(file: File | undefined) {
    if (!file) {
      return;
    }
    setAvatarUrl(URL.createObjectURL(file));
  }

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const given = firstName.trim();
    const family = lastName.trim();
    if (!given || !family) {
      setMissing(true);
      return;
    }
    onSave({ firstName: given, lastName: family, avatarUrl });
  }

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-8">
      <div className="flex flex-col gap-2">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink/55 transition-colors hover:text-ink"
        >
          {backLabel}
        </button>
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
          {step}
        </p>
        <h1 className="text-3xl font-semibold tracking-tight">Ism va familiya</h1>
        <p className="text-sm leading-6 text-ink/60">
          Bu qadam faqat birinchi marta kirganlar uchun.
        </p>
      </div>

      <label className="flex w-fit cursor-pointer items-center gap-4">
        <span className="flex h-16 w-16 items-center justify-center overflow-hidden rounded-full border border-line bg-white text-xs text-ink/45">
          {avatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={avatarUrl} alt="" className="h-full w-full object-cover" />
          ) : (
            "Rasm"
          )}
        </span>
        <span className="text-sm text-ink/70">Avatar yuklash, ixtiyoriy</span>
        <input
          type="file"
          accept="image/*"
          className="sr-only"
          onChange={(event) => onFile(event.target.files?.[0])}
        />
      </label>

      <div className="flex flex-col gap-2">
        <input
          value={firstName}
          onChange={(event) => setFirstName(event.target.value)}
          placeholder="Ism"
          autoComplete="given-name"
          className="rounded-2xl border border-line bg-white px-4 py-3 text-base outline-none focus:border-accent"
        />
        <input
          value={lastName}
          onChange={(event) => setLastName(event.target.value)}
          placeholder="Familiya"
          autoComplete="family-name"
          className="rounded-2xl border border-line bg-white px-4 py-3 text-base outline-none focus:border-accent"
        />
        {missing ? (
          <p className="text-sm text-ink/70">Ism va familiyani yozing.</p>
        ) : null}
      </div>

      <button
        type="submit"
        className="rounded-full bg-accent px-5 py-3 text-sm font-medium text-white"
      >
        Davom etish
      </button>
    </form>
  );
}
