import Link from "next/link";

import { trackCopy, type TrackId } from "@/components/tayyorlov/tracks";

type Props = {
  track: TrackId;
  title: string;
};

export function TayyorlovFanIntro({ track, title }: Props) {
  const copy = trackCopy[track];

  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-3 px-6 pt-12">
      <Link href={`/tayyorlov/${track}`} className="text-sm font-medium text-accent hover:underline">
        ← Barcha fanlar
      </Link>
      <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">{copy.eyebrow}</p>
      <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">{title}</h1>
      <p className="text-lg leading-8 text-ink/70">
        {title} — {copy.fanText}.
      </p>
    </section>
  );
}
