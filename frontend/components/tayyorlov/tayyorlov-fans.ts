export const tayyorlovFans = [
  { id: "matematika", title: "Matematika" },
  { id: "fizika", title: "Fizika" },
  { id: "kimyo", title: "Kimyo" },
  { id: "biologiya", title: "Biologiya" },
  { id: "ona-tili", title: "Ona tili va adabiyot" },
  { id: "ingliz-tili", title: "Ingliz tili" },
  { id: "tarix", title: "Tarix" },
  { id: "geografiya", title: "Geografiya" },
] as const;

export type TayyorlovFanId = (typeof tayyorlovFans)[number]["id"];

export function getTayyorlovFan(id: string) {
  return tayyorlovFans.find((fan) => fan.id === id);
}

export function titlesForFans(ids: readonly string[]) {
  return ids
    .map((id) => getTayyorlovFan(id)?.title)
    .filter((title): title is string => Boolean(title))
    .join(", ");
}