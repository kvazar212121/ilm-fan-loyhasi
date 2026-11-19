export const roles = [
  {
    id: "teacher",
    title: "O‘qituvchi",
    text: "Fan bo‘yicha imtihonga tayyorlanadi.",
  },
  {
    id: "pupil",
    title: "O‘quvchi",
    text: "Darslik va qo‘llanma bilan o‘qiydi.",
  },
  {
    id: "student",
    title: "Talaba",
    text: "Yo‘nalishi bo‘yicha tayyorlanadi.",
  },
] as const;

export type RoleId = (typeof roles)[number]["id"];

export type Role = (typeof roles)[number];
