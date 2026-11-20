"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";

const links = [
  { href: "/admin", label: "Ko‘rinish" },
  { href: "/admin/odamlar", label: "Odamlar" },
  { href: "/admin/materiallar", label: "Materiallar" },
];

export function AdminNav() {
  const pathname = usePathname();
  const router = useRouter();

  async function logout() {
    await fetch("/api/admin/logout", { method: "POST" });
    router.refresh();
  }

  return (
    <aside className="flex w-full flex-col gap-2 border-b border-line bg-white p-4 lg:min-h-screen lg:w-60 lg:border-r lg:border-b-0">
      <Link href="/admin" className="px-2 text-lg font-semibold tracking-tight">
        Ilm Fan
      </Link>
      <p className="px-2 text-xs tracking-[0.14em] text-accent uppercase">Boshqaruv</p>
      <nav className="mt-2 flex flex-row gap-1 lg:flex-col">
        {links.map((link) => {
          const on = pathname === link.href;
          return (
            <Link
              key={link.href}
              href={link.href}
              className={`rounded-xl px-3 py-2 text-sm font-medium ${on ? "bg-accent text-white" : "text-ink/75 hover:bg-paper"}`}
            >
              {link.label}
            </Link>
          );
        })}
      </nav>
      <div className="mt-auto flex gap-3 px-2 pt-4 text-sm">
        <Link href="/" className="text-ink/60 hover:text-ink">
          Sayt
        </Link>
        <button type="button" onClick={logout} className="text-ink/60 hover:text-ink">
          Chiqish
        </button>
      </div>
    </aside>
  );
}
