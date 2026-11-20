import type { Metadata } from "next";
import { connection } from "next/server";
import { Suspense } from "react";

import { ReelFeed } from "@/components/reels/ReelFeed";
import { ReelIntro } from "@/components/reels/ReelIntro";
import { getTayyorlovFan } from "@/components/tayyorlov/tayyorlov-fans";
import { publishedItems } from "@/lib/admin/store";
import { starterReels, type FeedReel } from "@/lib/reels/feed";

export const metadata: Metadata = {
  title: "Reels",
};

export default function ReelsPage() {
  return (
    <>
      <ReelIntro />
      <Suspense>
        <PublishedReels />
      </Suspense>
    </>
  );
}

async function PublishedReels() {
  await connection();
  const published = await publishedItems("reel");
  const extra: FeedReel[] = published.map((item) => ({
    id: item.id,
    title: item.title,
    fan: getTayyorlovFan(item.fanId)?.title ?? "Fan",
    text: item.text,
    seconds: 16,
    likes: 0,
  }));
  return <ReelFeed reels={[...extra, ...starterReels]} />;
}
