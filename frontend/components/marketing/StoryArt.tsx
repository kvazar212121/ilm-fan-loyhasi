import type { ReactNode } from "react";

import type { StoryArtId } from "@/components/marketing/types";

const scenes: Record<StoryArtId, ReactNode> = {
  prep: (
    <>
      <rect x="48" y="46" width="150" height="176" rx="16" fill="#fff" stroke="#e2d9cc" />
      <rect x="68" y="70" width="78" height="10" rx="5" fill="#0f6e56" />
      <rect x="68" y="94" width="110" height="8" rx="4" fill="#e7d7c3" />
      <rect x="68" y="112" width="96" height="8" rx="4" fill="#e7d7c3" />
      <rect x="68" y="130" width="84" height="8" rx="4" fill="#e7d7c3" />
      <circle cx="214" cy="92" r="42" fill="#0f6e56" />
      <path d="M196 92 l12 12 24-28" fill="none" stroke="#fff" strokeWidth="6" strokeLinecap="round" />
      <rect x="176" y="150" width="96" height="72" rx="12" fill="#1c1915" />
      <rect x="190" y="166" width="68" height="6" rx="3" fill="#f4f0e8" />
      <rect x="190" y="180" width="48" height="6" rx="3" fill="#0f6e56" />
    </>
  ),
  guide: (
    <>
      <rect x="70" y="78" width="180" height="120" rx="16" fill="#fff" stroke="#e2d9cc" />
      <rect x="54" y="62" width="180" height="120" rx="16" fill="#fff" stroke="#e2d9cc" />
      <rect x="38" y="46" width="180" height="120" rx="16" fill="#fff" stroke="#0f6e56" />
      <rect x="58" y="70" width="90" height="10" rx="5" fill="#0f6e56" />
      <rect x="58" y="92" width="130" height="8" rx="4" fill="#e7d7c3" />
      <rect x="58" y="110" width="112" height="8" rx="4" fill="#e7d7c3" />
      <path d="M230 150 l28 48 -18 4 -20-36z" fill="#1c1915" />
      <path d="M248 186 l10 16" stroke="#0f6e56" strokeWidth="4" strokeLinecap="round" />
    </>
  ),
  book: (
    <>
      <path d="M48 58 h100 c8 28 8 120 0 150 H48 z" fill="#fff" stroke="#e2d9cc" />
      <path d="M272 58 H172 c-8 28 -8 120 0 150 h100 z" fill="#fff" stroke="#e2d9cc" />
      <path d="M148 58 v150" stroke="#0f6e56" strokeWidth="4" />
      <rect x="66" y="86" width="64" height="7" rx="3" fill="#0f6e56" />
      <rect x="66" y="106" width="58" height="6" rx="3" fill="#e7d7c3" />
      <rect x="66" y="122" width="52" height="6" rx="3" fill="#e7d7c3" />
      <rect x="188" y="86" width="64" height="7" rx="3" fill="#1c1915" />
      <rect x="188" y="106" width="58" height="6" rx="3" fill="#e7d7c3" />
      <rect x="188" y="122" width="50" height="6" rx="3" fill="#e7d7c3" />
    </>
  ),
  quiz: (
    <>
      <circle cx="246" cy="62" r="28" fill="#fff" stroke="#0f6e56" strokeWidth="4" />
      <text x="246" y="68" textAnchor="middle" fontSize="16" fontWeight="700" fill="#0f6e56">
        10
      </text>
      <rect x="40" y="48" width="176" height="42" rx="14" fill="#fff" stroke="#e2d9cc" />
      <rect x="40" y="104" width="176" height="42" rx="14" fill="#0f6e56" />
      <rect x="40" y="160" width="176" height="42" rx="14" fill="#fff" stroke="#e2d9cc" />
      <circle cx="64" cy="125" r="8" fill="#fff" />
      <circle cx="64" cy="69" r="8" fill="#e7d7c3" />
      <circle cx="64" cy="181" r="8" fill="#e7d7c3" />
    </>
  ),
  course: (
    <>
      <path d="M78 40 v180" stroke="#e2d9cc" strokeWidth="4" />
      <circle cx="78" cy="58" r="12" fill="#0f6e56" />
      <circle cx="78" cy="118" r="12" fill="#0f6e56" />
      <circle cx="78" cy="178" r="12" fill="#fff" stroke="#0f6e56" strokeWidth="4" />
      <rect x="108" y="42" width="160" height="36" rx="12" fill="#fff" stroke="#e2d9cc" />
      <rect x="108" y="102" width="160" height="36" rx="12" fill="#fff" stroke="#e2d9cc" />
      <rect x="108" y="162" width="160" height="36" rx="12" fill="#1c1915" />
      <rect x="122" y="56" width="70" height="8" rx="4" fill="#0f6e56" />
      <rect x="122" y="116" width="88" height="8" rx="4" fill="#0f6e56" />
      <rect x="122" y="176" width="64" height="8" rx="4" fill="#f4f0e8" />
    </>
  ),
  reel: (
    <>
      <rect x="108" y="28" width="104" height="204" rx="22" fill="#1c1915" />
      <rect x="116" y="44" width="88" height="156" rx="12" fill="#f7f3ea" />
      <circle cx="160" cy="122" r="26" fill="#0f6e56" />
      <path d="M152 108 l22 14 -22 14z" fill="#fff" />
      <rect x="128" y="168" width="64" height="6" rx="3" fill="#e7d7c3" />
      <circle cx="160" cy="214" r="4" fill="#f4f0e8" />
    </>
  ),
};

export function StoryArt({ id, label }: { id: StoryArtId; label: string }) {
  return (
    <figure className="overflow-hidden rounded-[28px] border border-line bg-white shadow-[0_24px_50px_-32px_rgba(28,25,21,0.55)]">
      <div className="relative aspect-[5/4] bg-[#f7f3ea]">
        <div className="absolute -top-12 -left-10 h-40 w-40 rounded-full bg-accent/15" />
        <div className="absolute right-4 bottom-4 h-28 w-28 rounded-full bg-[#e7d7c3]" />
        <svg viewBox="0 0 320 260" className="absolute inset-0 h-full w-full" role="img" aria-label={label}>
          {scenes[id]}
        </svg>
      </div>
    </figure>
  );
}
