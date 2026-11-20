import { TayyorlovAudienceNote } from "@/components/tayyorlov/TayyorlovAudienceNote";
import { TayyorlovFanGrid } from "@/components/tayyorlov/TayyorlovFanGrid";
import { TayyorlovIntro } from "@/components/tayyorlov/TayyorlovIntro";
import type { TrackId } from "@/components/tayyorlov/tracks";

export function TrackHome({ track }: { track: TrackId }) {
  return (
    <>
      <TayyorlovIntro track={track} />
      <div className="mx-auto w-full max-w-3xl px-6 pt-2">
        <TayyorlovAudienceNote track={track} />
      </div>
      <TayyorlovFanGrid track={track} />
    </>
  );
}
