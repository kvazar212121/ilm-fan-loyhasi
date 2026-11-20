"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

import { mutateCatalog } from "@/components/admin/mutate";
import { getRole, roles } from "@/components/login/roles";
import { tayyorlovFans } from "@/components/tayyorlov/tayyorlov-fans";
import type { CatalogPerson } from "@/lib/admin/types";

const field = "rounded-2xl border border-line bg-white px-4 py-3 text-sm outline-none focus:border-accent";

export function PeoplePanel({ people }: { people: CatalogPerson[] }) {
  const router = useRouter();
  const [error, setError] = useState("");

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    setError("");
    try {
      await mutateCatalog({
        action: "add-person",
        firstName: String(form.get("firstName") ?? ""),
        lastName: String(form.get("lastName") ?? ""),
        role: String(form.get("role") ?? ""),
        fanId: String(form.get("fanId") ?? ""),
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
      <h1 className="text-3xl font-semibold tracking-tight">Odamlar</h1>
      <form onSubmit={onSubmit} className="grid gap-2 rounded-2xl border border-line bg-white p-4 sm:grid-cols-2">
        <input name="firstName" placeholder="Ism" className={field} />
        <input name="lastName" placeholder="Familiya" className={field} />
        <select name="role" className={field} defaultValue="cert-teacher">
          {roles.map((role) => (
            <option key={role.id} value={role.id}>
              {role.title}
            </option>
          ))}
        </select>
        <select name="fanId" className={field} defaultValue="">
          <option value="">Fan yo‘q</option>
          {tayyorlovFans.map((fan) => (
            <option key={fan.id} value={fan.id}>
              {fan.title}
            </option>
          ))}
        </select>
        <button type="submit" className="rounded-full bg-accent px-5 py-3 text-sm font-medium text-white sm:col-span-2">
          Qo‘shish
        </button>
        {error ? <p className="text-sm text-ink/70 sm:col-span-2">{error}</p> : null}
      </form>
      <ul className="flex flex-col gap-2">
        {people.map((person) => (
          <li key={person.id} className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-line bg-white px-4 py-3">
            <div>
              <p className="font-medium">
                {person.firstName} {person.lastName}
              </p>
              <p className="text-sm text-ink/55">
                {getRole(person.role)?.title}
                {person.fanId ? ` · ${tayyorlovFans.find((fan) => fan.id === person.fanId)?.title ?? ""}` : ""}
                {person.status === "blocked" ? " · blokda" : ""}
              </p>
            </div>
            <div className="flex gap-2 text-sm">
              <button
                type="button"
                className="rounded-full border border-line px-3 py-1.5"
                onClick={() =>
                  run({
                    action: "person-status",
                    id: person.id,
                    status: person.status === "active" ? "blocked" : "active",
                  })
                }
              >
                {person.status === "active" ? "Bloklash" : "Ochish"}
              </button>
              <button
                type="button"
                className="rounded-full border border-line px-3 py-1.5"
                onClick={() => run({ action: "remove-person", id: person.id })}
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
