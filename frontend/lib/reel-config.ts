export const reelMaxDurationSec = 120;

export const reelTargetFormat = "MP4 (H.264 + AAC)";

export const reelsStorageKey = "ilm-fan-reels";

export type StoredReel = {
  id: string;
  title: string;
  fileName: string;
  durationSec: number;
  createdAt: string;
};