import { notFound } from "next/navigation";

import { PublishedFanItems } from "@/components/catalog/PublishedFanItems";
import { TayyorlovFanIntro } from "@/components/tayyorlov/TayyorlovFanIntro";
import { TayyorlovFanMaterials } from "@/components/tayyorlov/TayyorlovFanMaterials";
import { getTayyorlovFan } from "@/components/tayyorlov/tayyorlov-fans";
import type { TrackId } from "@/components/tayyorlov/tracks";

export async function TrackFanPage({
  track,
  fanId,
}: {
  track: TrackId;
  fanId: string;
}) {
  const fan = getTayyorlovFan(fanId);
  if (!fan) notFound();

  return (
    <>
      <TayyorlovFanIntro track={track} title={fan.title} />
      <TayyorlovFanMaterials fanId={fan.id} fanTitle={fan.title} />
      <PublishedFanItems kind={track} fanId={fan.id} />
    </>
  );
}
