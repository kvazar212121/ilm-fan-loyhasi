import type { Metadata } from "next";

import { GuestOnly } from "@/components/marketing/GuestOnly";
import { certificateStory } from "@/components/marketing/stories/tracks";
import { TrackHome } from "@/components/tayyorlov/TrackHome";

export const metadata: Metadata = {
  title: "Sertifikatga tayyorlov",
};

export default function CertificateTrackPage() {
  return (
    <GuestOnly story={certificateStory}>
      <TrackHome track="sertifikat" />
    </GuestOnly>
  );
}
