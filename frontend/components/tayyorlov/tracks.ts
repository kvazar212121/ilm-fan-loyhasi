export const trackIds = ["sertifikat", "abituriyent"] as const;

export type TrackId = (typeof trackIds)[number];

export function isTrack(value: string): value is TrackId {
  return value === "sertifikat" || value === "abituriyent";
}

export const trackCopy: Record<
  TrackId,
  { eyebrow: string; title: string; lead: string; fans: string; fanText: string }
> = {
  sertifikat: {
    eyebrow: "O‘qituvchi",
    title: "Sertifikatga tayyorlov",
    lead: "O‘qituvchi davlat sertifikati imtihoniga shu yerda tayyorlanadi. Bitta fan tanlanadi, video darslar va testlar faqat shu fan bo‘yicha ochiladi. Sertifikatning o‘zi imtihondan keyin tashqarida beriladi.",
    fans: "Imtihon fanini oching. Video darslar va testlar shu fan ichida turadi.",
    fanText: "sertifikat imtihoni uchun video darslar va testlar",
  },
  abituriyent: {
    eyebrow: "Abituriyent",
    title: "Abituriyent tayyorlovi",
    lead: "Abituriyent oliy ta’lim imtihonlariga shu yerda tayyorlanadi. Bir nechta fan tanlanadi. Har bir fan bo‘yicha dars va test alohida ochiladi.",
    fans: "Imtihon fanlarini oching. Har bir fanning darsi va testi shu yerda.",
    fanText: "abituriyent imtihoni uchun video darslar va testlar",
  },
};
