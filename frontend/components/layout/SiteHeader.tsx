import Link from "next/link";

import { AuthNavLink } from "@/components/layout/AuthNavLink";
import { navItems } from "@/lib/nav";

const authHrefs = new Set(["/profile", "/login"]);

const linkClass = "text-ink/75 transition-colors hover:text-ink";

export function SiteHeader() {
  const mainItems = navItems.filter((item) => !authHrefs.has(item.href));

  return (
    <header className="sticky top-0 z-10 border-b border-line bg-paper/90 backdrop-blur">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-4 px-6 py-4">
        <Link href="/" className="text-lg font-semibold tracking-tight">
          Ilm Fan
        </Link>
        <nav className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm">
          {mainItems.map((item) => (
            <Link key={item.href} href={item.href} className={linkClass}>
              {item.label}
            </Link>
          ))}
          <span
            className="mx-1 hidden h-4 w-px shrink-0 bg-line sm:block"
            aria-hidden
          />
          <AuthNavLink />
        </nav>
      </div>
    </header>
  );
}
