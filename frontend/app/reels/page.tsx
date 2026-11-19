import type { Metadata } from "next";

import { EmptyState } from "@/components/shell/EmptyState";

export const metadata: Metadata = {
  title: "Reels",
};

export default function ReelsPage() {
  return (
    <EmptyState
      title="Reels"
      description="O‘quv qo‘llanma qisqa video sifatida shu lentada chiqadi."
    />
  );
}