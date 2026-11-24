export const uzRegions = [
  "Toshkent shahri",
  "Toshkent viloyati",
  "Andijon viloyati",
  "Buxoro viloyati",
  "Farg‘ona viloyati",
  "Jizzax viloyati",
  "Namangan viloyati",
  "Navoiy viloyati",
  "Qashqadaryo viloyati",
  "Qoraqalpog‘iston Respublikasi",
  "Samarqand viloyati",
  "Sirdaryo viloyati",
  "Surxondaryo viloyati",
  "Xorazm viloyati",
] as const;

export const genderOptions = [
  { id: "male", label: "Erkak" },
  { id: "female", label: "Ayol" },
] as const;

export type GenderId = (typeof genderOptions)[number]["id"];

export function genderLabel(gender?: string | null): string {
  if (gender === "male") return "Erkak";
  if (gender === "female") return "Ayol";
  return "—";
}
