import Link from "next/link";

import { tayyorlovMaterialKinds } from "@/components/tayyorlov/tayyorlov-material-kinds";
import type { TayyorlovFanId } from "@/components/tayyorlov/tayyorlov-fans";

type Props = {
  fanId: TayyorlovFanId;
  fanTitle: string;
};

export function TayyorlovFanMaterials({ fanId, fanTitle }: Props) {
  return (
    <section className="mx-auto w-full max-w-3xl px-6 pb-12">
      <h2 className="text-sm font-medium tracking-wide text-ink/55 uppercase">Materiallar</h2>
      <ul className="mt-6 grid gap-4 sm:grid-cols-2">
        {tayyorlovMaterialKinds.map((item) => (
          <li key={item.id}>
            <Link
              href={`${item.href}?fan=${fanId}`}
              className="flex h-full flex-col rounded-2xl border border-line bg-white p-5 transition-colors hover:border-accent"
            >
              <h3 className="text-lg font-semibold">{item.title}</h3>
              <p className="mt-2 flex-1 text-sm leading-6 text-ink/70">
                {fanTitle} — {item.text}
              </p>
              <span className="mt-4 text-sm font-medium text-accent">Ko‘rish →</span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}