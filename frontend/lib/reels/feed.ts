export type FeedReel = {
  id: string;
  title: string;
  fan: string;
  text: string;
  seconds: number;
  likes: number;
};

export const starterReels: FeedReel[] = [
  {
    id: "reel-suv",
    title: "Suvning formulasi",
    fan: "Kimyo",
    text: "Suv — H₂O. Ikki atom vodorod, bitta atom kislorod. Shuning uchun formula H₂O.",
    seconds: 12,
    likes: 18,
  },
  {
    id: "reel-kvadrat",
    title: "Kvadratning yuzi",
    fan: "Matematika",
    text: "Tomon uzunligi a bo‘lsa, yuzi a × a. Tomon 4 bo‘lsa, yuz 16.",
    seconds: 12,
    likes: 24,
  },
  {
    id: "reel-tezlik",
    title: "Tezlik nimadan chiqadi",
    fan: "Fizika",
    text: "Tezlik — bosib o‘tilgan yo‘lni vaqtga bo‘lish. 100 metrni 20 soniyada yursangiz, tezlik 5 m/s.",
    seconds: 14,
    likes: 15,
  },
];
