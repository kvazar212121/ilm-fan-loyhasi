"use client";

import { useEffect, useState, type ReactNode } from "react";

import { SectionStoryView } from "@/components/marketing/SectionStoryView";
import type { SectionStory } from "@/components/marketing/types";
import { readStoredProfileRaw, subscribeProfileStore } from "@/components/profile/profile-data";

type GuestOnlyProps = {
  story: SectionStory;
  children: ReactNode;
};

export function GuestOnly({ story, children }: GuestOnlyProps) {
  const [member, setMember] = useState(false);

  useEffect(() => {
    const sync = () => setMember(Boolean(readStoredProfileRaw()));
    sync();
    return subscribeProfileStore(sync);
  }, []);

  if (member) return children;
  return <SectionStoryView story={story} />;
}
