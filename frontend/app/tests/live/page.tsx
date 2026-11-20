import type { Metadata } from "next";

import { LiveSetup } from "@/components/tests/LiveSetup";

export const metadata: Metadata = {
  title: "Jonli test",
};

export default function LiveTestPage() {
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-16">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Hamma bilan</p>
        <h1 className="text-3xl font-semibold tracking-tight">Jonli test</h1>
        <p className="leading-7 text-ink/70">
          Xona oching, kodni ulashing. Savol hammaga bir vaqtda tushadi va tanlangan soniya
          tugagach to‘g‘ri javob hamda necha kishi topgani ochiladi.
        </p>
      </div>
      <LiveSetup />
    </section>
  );
}
