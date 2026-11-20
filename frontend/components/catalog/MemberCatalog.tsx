import { connection } from "next/server";
import { Suspense } from "react";

import { EmptyState } from "@/components/shell/EmptyState";
import { getTayyorlovFan } from "@/components/tayyorlov/tayyorlov-fans";
import { publishedItems } from "@/lib/admin/store";
import type { ItemKind } from "@/lib/admin/types";

type Props = {
  kind: ItemKind;
  title: string;
  empty: string;
};

export function MemberCatalog({ kind, title, empty }: Props) {
  return (
    <Suspense fallback={<EmptyState title={title} description={empty} />}>
      <MemberList kind={kind} title={title} empty={empty} />
    </Suspense>
  );
}

async function MemberList({ kind, title, empty }: Props) {
  await connection();
  const items = await publishedItems(kind);
  if (items.length === 0) return <EmptyState title={title} description={empty} />;

  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-16">
      <h1 className="text-3xl font-semibold tracking-tight">{title}</h1>
      <ul className="grid gap-3">
        {items.map((item) => (
          <li key={item.id} className="rounded-2xl border border-line bg-white p-5">
            <p className="text-xs font-medium tracking-[0.14em] text-accent uppercase">
              {getTayyorlovFan(item.fanId)?.title}
            </p>
            <h2 className="mt-1 text-lg font-semibold">{item.title}</h2>
            <p className="mt-2 text-sm leading-6 text-ink/70">{item.text}</p>
          </li>
        ))}
      </ul>
    </section>
  );
}
