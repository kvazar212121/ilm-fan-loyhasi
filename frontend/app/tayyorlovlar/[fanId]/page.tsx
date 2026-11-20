import { Suspense } from "react";
import { notFound, redirect } from "next/navigation";

import { getTayyorlovFan, tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";

type PageProps = {
  params: Promise<{ fanId: string }>;
};

export function generateStaticParams() {
  return tayyorlovFans.map((fan) => ({ fanId: fan.id }));
}

export default function LegacyFanPage({ params }: PageProps) {
  return (
    <Suspense>
      <LegacyFan params={params} />
    </Suspense>
  );
}

async function LegacyFan({ params }: PageProps) {
  const { fanId } = await params;
  if (!getTayyorlovFan(fanId)) notFound();
  redirect(`/tayyorlov/sertifikat/${fanId}`);
}
