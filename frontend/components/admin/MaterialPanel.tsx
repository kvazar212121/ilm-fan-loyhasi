"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

import { mutateCatalog } from "@/components/admin/mutate";
import { tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";
import { itemKinds, type CatalogItem } from "@/lib/admin/types";

const field = "rounded-2xl border border-line bg-white px-4 py-3 text-sm outline-none focus:border-accent";

export function MaterialPanel({ items }: { items: CatalogItem[] }) {
  const router = useRouter();
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    setError("");
    try {
      await mutateCatalog({
        action: "add-item",
        kind: String(form.get("kind") ?? ""),
        fanId: String(form.get("fanId") ?? ""),
        title: String(form.get("title") ?? ""),
        text: String(form.get("text") ?? ""),
      });
      event.currentTarget.reset();
      router.refresh();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "Saqlanmadi");
    }
  }

  async function run(body: Record<string, string>) {
    await mutateCatalog(body);
    router.refresh();
  }

  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-6">
      <h1 className="text-3xl font-semibold tracking-tight">Materiallar</h1>
      <form onSubmit={onSubmit} className="grid gap-2 rounded-2xl border border-line bg-white p-4">
        <div className="grid gap-2 sm:grid-cols-2">
          <select name="kind" className={field} defaultValue="sertifikat">
            {itemKinds.map((kind) => (
              <option key={kind.id} value={kind.id}>
                {kind.title}
              </option>
            ))}
          </select>
          <select name="fanId" className={field} defaultValue="matematika">
            {tayyorlovFans.map((fan) => (
              <option key={fan.id} value={fan.id}>
                {fan.title}
              </option>
            ))}
          </select>
        </div>
        <input name="title" placeholder="Sarlavha" className={field} />
        <textarea name="text" placeholder="Qisqa matn" rows={3} className={field} />
        <button type="submit" className="w-fit rounded-full bg-accent px-5 py-3 text-sm font-medium text-white">
          Qoralama saqlash
        </button>
        {error ? <p className="text-sm text-ink/70">{error}</p> : null}
      </form>
      <ul className="flex flex-col gap-2">
        {items.map((item) => (
          <li key={item.id} className="rounded-2xl border border-line bg-white px-4 py-3">
            <p className="text-xs tracking-[0.12em] text-accent uppercase">
              {itemKinds.find((kind) => kind.id === item.kind)?.title} ·{" "}
              {tayyorlovFans.find((fan) => fan.id === item.fanId)?.title}
            </p>
            <p className="mt-1 font-medium">{item.title}</p>
            <p className="mt-1 text-sm leading-6 text-ink/65">{item.text}</p>
            <div className="mt-3 flex gap-2 text-sm">
              <button
                type="button"
                className="rounded-full border border-line px-3 py-1.5"
                onClick={() =>
                  run({
                    action: "item-status",
                    id: item.id,
                    status: item.status === "published" ? "draft" : "published",
                  })
                }
              >
                {item.status === "published" ? "Qoralamaga" : "Nashr qilish"}
              </button>
              <button
                type="button"
                className="rounded-full border border-line px-3 py-1.5"
                onClick={() => run({ action: "remove-item", id: item.id })}
              >
                O‘chirish
              </button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
