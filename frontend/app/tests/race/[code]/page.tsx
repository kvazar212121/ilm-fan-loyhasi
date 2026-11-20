import type { Metadata } from "next";
import { Suspense } from "react";

import { RaceRoom } from "@/components/tests/RaceRoom";

export const metadata: Metadata = {
  title: "Auditoriya musobaqasi",
};

export default function RacePage({
  params,
  searchParams,
}: {
  params: Promise<{ code: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  return (
    <Suspense fallback={<p className="px-6 py-16 text-sm text-ink/70">Musobaqa yuklanmoqda...</p>}>
      <RaceGate params={params} searchParams={searchParams} />
    </Suspense>
  );
}

async function RaceGate({
  params,
  searchParams,
}: {
  params: Promise<{ code: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const { code } = await params;
  const { view } = await searchParams;
  const roomCode = code.toUpperCase();
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-12">
      <RaceRoom code={roomCode} screen={view === "screen"} />
    </section>
  );
}
