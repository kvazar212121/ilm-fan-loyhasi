import type { Metadata } from "next";

import { TayyorlovAudienceNote } from "@/components/tayyorlov/TayyorlovAudienceNote";
import { TayyorlovFanGrid } from "@/components/tayyorlov/TayyorlovFanGrid";
import { TayyorlovIntro } from "@/components/tayyorlov/TayyorlovIntro";

export const metadata: Metadata = {
  title: "Tayyorlovlar",
};

export default function TayyorlovlarPage() {
  return (
    <>
      <TayyorlovIntro />
      <div className="mx-auto w-full max-w-3xl px-6 pt-2">
        <TayyorlovAudienceNote />
      </div>
      <TayyorlovFanGrid />
    </>
  );
}