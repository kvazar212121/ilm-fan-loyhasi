import type { Metadata } from "next";

import { ReelCreateShell } from "@/components/reels/ReelCreateShell";

export const metadata: Metadata = {
  title: "Reel joylash",
};

export default function ReelCreatePage() {
  return <ReelCreateShell />;
}