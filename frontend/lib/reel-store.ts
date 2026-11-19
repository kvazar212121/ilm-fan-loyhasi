import { reelsStorageKey } from "@/lib/reel-config";

const reelsUpdatedEvent = "ilm-fan-reels-updated";

export function notifyReelsUpdated() {
  window.dispatchEvent(new Event(reelsUpdatedEvent));
}

export function subscribeReels(onChange: () => void) {
  window.addEventListener(reelsUpdatedEvent, onChange);
  return () => window.removeEventListener(reelsUpdatedEvent, onChange);
}

export function getReelsRaw() {
  return sessionStorage.getItem(reelsStorageKey);
}