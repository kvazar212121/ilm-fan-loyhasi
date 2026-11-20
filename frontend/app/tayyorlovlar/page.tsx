import type { Metadata } from "next";

import { TayyorlovChoice } from "@/components/tayyorlov/TayyorlovChoice";

export const metadata: Metadata = {
  title: "Tayyorlovlar",
};

export default function TayyorlovlarPage() {
  return <TayyorlovChoice />;
}
