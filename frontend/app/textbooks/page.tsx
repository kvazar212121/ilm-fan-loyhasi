import type { Metadata } from "next";

import { MemberCatalog } from "@/components/catalog/MemberCatalog";
import { GuestOnly } from "@/components/marketing/GuestOnly";
import { textbookStory } from "@/components/marketing/stories/read";

export const metadata: Metadata = {
  title: "Darsliklar",
};

export default function TextbooksPage() {
  return (
    <GuestOnly story={textbookStory}>
      <MemberCatalog
        kind="darslik"
        title="Darsliklar"
        empty="O‘quvchi o‘zi uchun o‘qiydigan kitoblar shu yerda chiqadi."
      />
    </GuestOnly>
  );
}
