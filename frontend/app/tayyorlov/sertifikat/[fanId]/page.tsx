import type { Metadata } from "next";
import { Suspense } from "react";

import { TrackFanPage } from "@/components/tayyorlov/TrackFanPage";
import { getTayyorlovFan, tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";

type PageProps = { params: Promise<{ fanId: string }> };

export function generateStaticParams() {
  return tayyorlovFans.map((fan) => ({ fanId: fan.id }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { fanId } = await params;
  const fan = getTayyorlovFan(fanId);
  return { title: fan ? `${fan.title} — Sertifikatga tayyorlov` : "Sertifikatga tayyorlov" };
}

export default function Page({ params }: PageProps) {
  return (
    <Suspense>
      <CertificateFan params={params} />
    </Suspense>
  );
}

async function CertificateFan({ params }: PageProps) {
  const { fanId } = await params;
  return <TrackFanPage track="sertifikat" fanId={fanId} />;
}
