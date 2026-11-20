import type { Metadata } from "next";

import { GuestOnly } from "@/components/marketing/GuestOnly";
import { applicantStory } from "@/components/marketing/stories/tracks";
import { TrackHome } from "@/components/tayyorlov/TrackHome";

export const metadata: Metadata = {
  title: "Abituriyent tayyorlovi",
};

export default function ApplicantTrackPage() {
  return (
    <GuestOnly story={applicantStory}>
      <TrackHome track="abituriyent" />
    </GuestOnly>
  );
}
