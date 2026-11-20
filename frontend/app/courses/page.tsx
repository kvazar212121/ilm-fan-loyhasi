import type { Metadata } from "next";

import { MemberCatalog } from "@/components/catalog/MemberCatalog";
import { GuestOnly } from "@/components/marketing/GuestOnly";
import { courseStory } from "@/components/marketing/stories/try";

export const metadata: Metadata = {
  title: "Kurslar",
};

export default function CoursesPage() {
  return (
    <GuestOnly story={courseStory}>
      <MemberCatalog kind="kurs" title="Kurslar" empty="Tayyorlov kurslari shu yerda chiqadi." />
    </GuestOnly>
  );
}
