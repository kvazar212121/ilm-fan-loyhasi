export type StoryArtId = "prep" | "guide" | "book" | "quiz" | "course" | "reel";

export type StoryPoint = {
  title: string;
  text: string;
};

export type SectionStory = {
  art: StoryArtId;
  eyebrow: string;
  title: string;
  lead: string;
  purpose: string;
  benefits: StoryPoint[];
  gives: StoryPoint[];
  steps: StoryPoint[];
};
