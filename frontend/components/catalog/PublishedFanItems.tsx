import { connection } from "next/server";

import { publishedItems } from "@/lib/admin/store";
import type { ItemKind } from "@/lib/admin/types";

export async function PublishedFanItems({ kind, fanId }: { kind: ItemKind; fanId: string }) {
  await connection();
  const items = await publishedItems(kind, fanId);
  if (items.length === 0) return null;

  return (
    <section className="mx-auto w-full max-w-3xl px-6 pb-12">
      <h2 className="text-sm font-medium tracking-wide text-ink/55 uppercase">Nashr</h2>
      <ul className="mt-4 grid gap-3">
        {items.map((item) => (
          <li key={item.id} className="rounded-2xl border border-line bg-white p-5">
            <h3 className="text-lg font-semibold">{item.title}</h3>
            <p className="mt-2 text-sm leading-6 text-ink/70">{item.text}</p>
          </li>
        ))}
      </ul>
    </section>
  );
}
