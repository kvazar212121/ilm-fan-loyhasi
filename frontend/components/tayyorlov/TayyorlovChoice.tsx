import Link from "next/link";

import { trackCopy, trackIds } from "@/components/tayyorlov/tracks";

export function TayyorlovChoice() {
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-16">
      <div className="flex flex-col gap-3">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Tayyorlov</p>
        <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">Ikki xil tayyorlov</h1>
        <p className="text-lg leading-8 text-ink/70">
          O‘qituvchi sertifikat olish uchun tayyorlanadi. Abituriyent o‘z imtihonlari uchun
          tayyorlanadi. Ikkalasi alohida yo‘l.
        </p>
      </div>
      <ul className="grid gap-3">
        {trackIds.map((track) => (
          <li key={track}>
            <Link
              href={`/tayyorlov/${track}`}
              className="block rounded-2xl border border-line bg-white p-5 transition-colors hover:border-accent"
            >
              <h2 className="text-lg font-semibold">{trackCopy[track].title}</h2>
              <p className="mt-2 text-sm leading-6 text-ink/70">{trackCopy[track].lead}</p>
              <span className="mt-3 inline-block text-sm font-medium text-accent">Ochish →</span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}
