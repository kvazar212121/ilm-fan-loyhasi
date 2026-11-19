import Link from "next/link";

import { tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";

export function TayyorlovFanGrid() {
  return (
    <section className="mx-auto w-full max-w-3xl px-6 py-10">
      <h2 className="text-sm font-medium tracking-wide text-ink/55 uppercase">Fanlar</h2>
      <p className="mt-2 text-sm leading-6 text-ink/65">
        Avval fan tanlang. Har bir fanda video qo‘llanmalar va testlar chiqadi.
      </p>
      <ul className="mt-6 grid gap-3 sm:grid-cols-2">
        {tayyorlovFans.map((fan) => (
          <li key={fan.id}>
            <Link
              href={`/tayyorlovlar/${fan.id}`}
              className="flex items-center justify-between rounded-2xl border border-line bg-white px-5 py-4 transition-colors hover:border-accent"
            >
              <span className="font-medium">{fan.title}</span>
              <span className="text-sm text-accent">Ochish →</span>
            </Link>
          </li>
        ))}
      </ul>
      <p className="mt-8 rounded-2xl border border-dashed border-line bg-white p-5 text-sm text-ink/60">
        Fanlar ro‘yxati keyin backenddan kengayadi. Materiallar har fan uchun alohida jamlanadi.
      </p>
    </section>
  );
}