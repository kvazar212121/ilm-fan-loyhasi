import type { Metadata } from "next";
import { Suspense } from "react";

import { LiveRoom } from "@/components/tests/LiveRoom";

export const metadata: Metadata = {
  title: "Jonli test xonasi",
};

export default function LiveRoomPage({
  params,
}: {
  params: Promise<{ code: string }>;
}) {
  return (
    <Suspense fallback={<p className="px-6 py-16 text-sm text-ink/70">Xona yuklanmoqda...</p>}>
      <LiveRoomGate params={params} />
    </Suspense>
  );
}

async function LiveRoomGate({ params }: { params: Promise<{ code: string }> }) {
  const { code } = await params;
  const roomCode = code.toUpperCase();
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-16">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Jonli test</p>
        <h1 className="text-3xl font-semibold tracking-tight">Xona {roomCode}</h1>
      </div>
      <LiveRoom code={roomCode} />
    </section>
  );
}
