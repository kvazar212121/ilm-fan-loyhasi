import type { Metadata } from "next";

import { RaceBuilder } from "@/components/tests/RaceBuilder";

export const metadata: Metadata = {
  title: "Musobaqa testi",
};

export default function RaceCreatePage() {
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-12">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">O‘qituvchi</p>
        <h1 className="text-3xl font-semibold tracking-tight">Auditoriya musobaqasi</h1>
        <p className="leading-7 text-ink/70">
          Savollarni yozing va to‘g‘ri javobni belgilang. Linkni ekranga chiqaring. O‘quvchilar
          telefondan javob beradi, birinchi to‘g‘ri topgan ball oladi.
        </p>
      </div>
      <RaceBuilder />
    </section>
  );
}
