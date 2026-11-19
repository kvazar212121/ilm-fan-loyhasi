import type { Metadata } from "next";

import { EmptyState } from "@/components/shell/EmptyState";

export const metadata: Metadata = {
  title: "O‘quv qo‘llanmalar",
};

export default function GuidesPage() {
  return (
    <EmptyState
      title="O‘quv qo‘llanmalar"
      description="Fan bo‘yicha tayyorlov materiallari shu yerda chiqadi."
    />
  );
}
