export const roles = [
  {
    id: "cert-teacher",
    title: "Sertifikat ustozi",
    text: "Davlat sertifikati imtihoniga o‘zi tayyorlanayotgan o‘qituvchi.",
    kind: "teacher",
    fanMode: "one",
  },
  {
    id: "guide-teacher",
    title: "Qo‘llanma ustozi",
    text: "O‘z o‘quvchilari uchun qo‘llanma va vazifa yasaydigan o‘qituvchi.",
    kind: "teacher",
    fanMode: "one",
  },
  {
    id: "applicant",
    title: "Abituriyent",
    text: "Oliy ta’limga tayyorlanayotgan o‘quvchi. Bir nechta fan tanlaydi.",
    kind: "learner",
    fanMode: "many",
  },
  {
    id: "pupil",
    title: "O‘quvchi",
    text: "Ustoz bergan vazifani bajaradi. Fan tanlanmaydi.",
    kind: "learner",
    fanMode: "none",
  },
] as const;

export type RoleId = (typeof roles)[number]["id"];
export type Role = (typeof roles)[number];

export function getRole(id: string | null | undefined) {
  return roles.find((role) => role.id === id);
}

export function isTeacherRole(id: string | undefined) {
  return getRole(id)?.kind === "teacher" || id === "teacher";
}
