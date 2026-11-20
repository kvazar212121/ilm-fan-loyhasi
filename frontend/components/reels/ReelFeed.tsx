import { ReelStage } from "@/components/reels/ReelStage";
import type { FeedReel } from "@/lib/reels/feed";

export function ReelFeed({ reels }: { reels: FeedReel[] }) {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-10">
      <h2 className="text-sm font-medium tracking-wide text-ink/55 uppercase">Tomosha</h2>
      <div className="mt-5 grid grid-cols-3 items-start gap-4">
        {reels.map((reel) => (
          <ReelStage key={reel.id} reel={reel} />
        ))}
      </div>
    </section>
  );
}
