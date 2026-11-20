import type { Metadata } from "next";

import { GuestOnly } from "@/components/marketing/GuestOnly";
import { testStory } from "@/components/marketing/stories/try";
import { FanScope } from "@/components/tests/FanScope";
import { TestModes } from "@/components/tests/TestModes";

export const metadata: Metadata = {
  title: "Testlar",
};

export default function TestsPage() {
  return (
    <GuestOnly story={testStory}>
      <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-16">
        <div className="flex flex-col gap-3">
          <h1 className="text-3xl font-semibold tracking-tight">Testlar</h1>
          <p className="text-lg leading-8 text-ink/70">
            Yolg‘iz mashq qiling, birga vaqt bilan yeching yoki auditoriyada birinchi topgan ball
            oladigan musobaqa oching.
          </p>
        </div>
        <FanScope />
        <TestModes />
      </section>
    </GuestOnly>
  );
}
