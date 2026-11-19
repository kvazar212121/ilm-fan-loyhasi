import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { TayyorlovFanIntro } from "@/components/tayyorlov/TayyorlovFanIntro";
import { TayyorlovFanMaterials } from "@/components/tayyorlov/TayyorlovFanMaterials";
import { getTayyorlovFan, tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";

type PageProps = {
  params: Promise<{ fanId: string }>;
};

export function generateStaticParams() {
  return tayyorlovFans.map((fan) => ({ fanId: fan.id }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { fanId } = await params;
  const fan = getTayyorlovFan(fanId);
  if (!fan) return { title: "Tayyorlovlar" };
  return { title: `${fan.title} — tayyorlov` };
}

export default async function TayyorlovFanPage({ params }: PageProps) {
  const { fanId } = await params;
  const fan = getTayyorlovFan(fanId);
  if (!fan) notFound();

  return (
    <>
      <TayyorlovFanIntro title={fan.title} />
      <TayyorlovFanMaterials fanId={fan.id} fanTitle={fan.title} />
    </>
  );
}