import type { Metadata } from "next";

import { EmptyState } from "@/components/shell/EmptyState";

export const metadata: Metadata = {
  title: "Testlar",
};

export default function TestsPage() {
  return (
    <EmptyState
      title="Testlar"
      description="Imtihon oldidan mashq testlari shu yerda chiqadi. Kurs tashkilotchisi o‘z testini keyin shu bo‘limga chiqaradi."
    />
  );
}
