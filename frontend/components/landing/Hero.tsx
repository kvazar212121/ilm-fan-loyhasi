import Link from "next/link";

import { tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";

const quickTracks = [
  {
    href: "/tayyorlov/sertifikat",
    title: "Davlat sertifikati",
    meta: "O‘qituvchilar uchun · bitta asosiy fan",
  },
  {
    href: "/tayyorlov/abituriyent",
    title: "OTM kirish imtihoni",
    meta: "Abituriyentlar uchun · bir nechta fan",
  },
];

export function Hero() {
  const featuredFans = tayyorlovFans.slice(0, 6);

  return (
    <section className="mx-auto w-full max-w-6xl px-6 pt-14 pb-16 sm:pt-20 sm:pb-24">
      <div className="grid items-start gap-12 lg:grid-cols-12 lg:gap-10">
        <div className="flex flex-col gap-7 lg:col-span-7">
          <h1 className="font-display text-4xl leading-[1.06] font-medium tracking-[-0.025em] text-ink sm:text-6xl">
            Faningiz bo‘yicha o‘qing, mashq qiling,{" "}
            <em className="font-normal text-accent italic">imtihonga</em> tayyor chiqing.
          </h1>
          <p className="max-w-[58ch] text-base leading-8 text-ink-muted sm:text-lg">
            O‘qituvchi davlat sertifikati imtihoniga, abituriyent esa oliy ta’lim kirish
            sinovlariga bir joyda tizimli tayyorlanadi. Darslik, oraliq test va qisqa video
            tushuntirishlar yagona o‘quv rejasida.
          </p>
          <div className="flex flex-wrap items-center gap-3 pt-1">
            <Link
              href="/tayyorlov/sertifikat"
              className="inline-flex items-center gap-2 rounded-full bg-accent px-6 py-3.5 text-sm font-medium text-paper transition-colors hover:bg-accent-hover"
            >
              Sertifikatga tayyorlov
              <span aria-hidden>→</span>
            </Link>
            <Link
              href="/tayyorlov/abituriyent"
              className="inline-flex items-center rounded-full border border-line-strong bg-surface px-6 py-3.5 text-sm font-medium text-ink transition-colors hover:border-accent hover:text-accent"
            >
              Abituriyent tayyorlovi
            </Link>
            <Link
              href="/login"
              className="px-3 py-3 text-sm font-medium text-ink-muted underline-offset-4 transition-colors hover:text-ink hover:underline"
            >
              Hisobga kirish
            </Link>
          </div>
        </div>

        <aside className="folio-enter rounded-2xl border border-line bg-surface p-6 sm:p-7 lg:col-span-5">
          <div className="flex items-baseline justify-between border-b border-line pb-4">
            <h2 className="font-display text-2xl font-medium tracking-[-0.02em] text-ink">
              Tayyorlov yo‘nalishlari
            </h2>
            <span className="text-xs font-medium text-ink-muted tabular-nums">
              {tayyorlovFans.length} ta fan
            </span>
          </div>

          <ul className="divide-y divide-line">
            {quickTracks.map((track) => (
              <li key={track.href}>
                <Link
                  href={track.href}
                  className="group flex items-center justify-between gap-4 py-4 transition-colors"
                >
                  <div>
                    <p className="text-base font-semibold text-ink transition-colors group-hover:text-accent">
                      {track.title}
                    </p>
                    <p className="mt-0.5 text-sm text-ink-muted">{track.meta}</p>
                  </div>
                  <span
                    aria-hidden
                    className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full border border-line text-sm text-ink-muted transition-colors group-hover:border-accent group-hover:bg-accent group-hover:text-paper"
                  >
                    →
                  </span>
                </Link>
              </li>
            ))}
          </ul>

          <div className="border-t border-line pt-5">
            <p className="mb-3 text-xs font-medium text-ink-muted">Tezkor fan tanlash</p>
            <div className="flex flex-wrap gap-2">
              {featuredFans.map((fan) => (
                <Link
                  key={fan.id}
                  href={`/tayyorlov/abituriyent/${fan.id}`}
                  className="rounded-full border border-line bg-paper px-3.5 py-1.5 text-xs font-medium text-ink transition-colors hover:border-accent hover:bg-accent-soft hover:text-accent"
                >
                  {fan.title}
                </Link>
              ))}
            </div>
          </div>
        </aside>
      </div>
    </section>
  );
}
