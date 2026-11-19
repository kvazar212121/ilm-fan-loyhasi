import type { Metadata } from "next";

import { EmptyState } from "@/components/shell/EmptyState";

export const metadata: Metadata = {
  title: "Kurslar",
};

export default function CoursesPage() {
  return (
    <EmptyState
      title="Kurslar"
      description="Tayyorlov kurslari shu yerda chiqadi."
    />
  );
}
