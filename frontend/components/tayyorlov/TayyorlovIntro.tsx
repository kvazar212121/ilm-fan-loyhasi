import { trackCopy, type TrackId } from "@/components/tayyorlov/tracks";

export function TayyorlovIntro({ track }: { track: TrackId }) {
  const copy = trackCopy[track];

  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-3 px-6 pt-12">
      <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">{copy.eyebrow}</p>
      <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">{copy.title}</h1>
      <p className="text-lg leading-8 text-ink/70">{copy.lead}</p>
    </section>
  );
}
