import Link from "next/link";

import { itemKinds, type Catalog } from "@/lib/admin/types";

export function DashboardCards({ catalog }: { catalog: Catalog }) {
  const active = catalog.people.filter((person) => person.status === "active").length;
  const published = catalog.items.filter((item) => item.status === "published").length;

  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-6">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Boshqaruv</p>
        <h1 className="text-3xl font-semibold tracking-tight">Platforma</h1>
        <p className="max-w-2xl text-sm leading-6 text-ink/65">
          Odamlarni yozib qo‘yasiz, materialni avval qoralama saqlaysiz. Nashr qilingach u saytda,
          shu fan va bo‘lim ichida chiqadi.
        </p>
      </div>
      <ul className="grid gap-3 sm:grid-cols-3">
        <li className="rounded-2xl border border-line bg-white p-5">
          <p className="text-sm text-ink/55">Odamlar</p>
          <p className="mt-2 text-3xl font-semibold">{catalog.people.length}</p>
          <p className="mt-1 text-sm text-ink/60">{active} tasi faol</p>
        </li>
        <li className="rounded-2xl border border-line bg-white p-5">
          <p className="text-sm text-ink/55">Materiallar</p>
          <p className="mt-2 text-3xl font-semibold">{catalog.items.length}</p>
          <p className="mt-1 text-sm text-ink/60">{published} tasi nashrda</p>
        </li>
        <li className="rounded-2xl border border-line bg-white p-5">
          <p className="text-sm text-ink/55">Qoralama</p>
          <p className="mt-2 text-3xl font-semibold">{catalog.items.length - published}</p>
          <p className="mt-1 text-sm text-ink/60">Hali saytda yo‘q</p>
        </li>
      </ul>
      <ul className="grid gap-3 sm:grid-cols-2">
        {itemKinds.map((kind) => {
          const count = catalog.items.filter((item) => item.kind === kind.id && item.status === "published").length;
          return (
            <li key={kind.id} className="rounded-2xl border border-line bg-white px-5 py-4">
              <p className="font-medium">{kind.title}</p>
              <p className="mt-1 text-sm text-ink/60">{count} ta nashr</p>
            </li>
          );
        })}
      </ul>
      <div className="flex flex-wrap gap-3">
        <Link href="/admin/odamlar" className="rounded-full bg-accent px-5 py-3 text-sm font-medium text-white">
          Odam qo‘shish
        </Link>
        <Link
          href="/admin/materiallar"
          className="rounded-full border border-line bg-white px-5 py-3 text-sm font-medium"
        >
          Material qo‘shish
        </Link>
      </div>
    </div>
  );
}
