import type { Metadata } from "next";

import { EmptyState } from "@/components/shell/EmptyState";

export const metadata: Metadata = {
  title: "Darsliklar",
};

export default function TextbooksPage() {
  return (
    <EmptyState
      title="Darsliklar"
      description="O‘quvchi o‘zi uchun o‘qiydigan kitoblar shu yerda chiqadi."
    />
  );
}
