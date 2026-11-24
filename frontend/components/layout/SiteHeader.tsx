import Link from "next/link";

import { AuthNavLink } from "@/components/layout/AuthNavLink";
import { navItems } from "@/lib/nav";

const authHrefs = new Set(["/profile", "/login"]);

const linkClass =
  "text-sm text-ink-muted underline-offset-4 transition-colors hover:text-ink hover:underline";

export function SiteHeader() {
  const mainItems = navItems.filter((item) => !authHrefs.has(item.href));

  return (
    <header className="sticky top-0 z-20 border-b border-line bg-paper/92 backdrop-blur-sm">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-4 px-6 py-4">
        <Link href="/" className="group flex items-center gap-2.5">
          <span
            aria-hidden
            className="flex h-8 w-8 items-center justify-center rounded-lg bg-accent text-paper transition-colors group-hover:bg-accent-hover"
          >
            <svg viewBox="0 0 20 20" className="h-4 w-4" fill="none">
              <path
                d="M4 5.5C6.2 4.7 8.4 5 10 6.2C11.6 5 13.8 4.7 16 5.5V15C13.8 14.2 11.6 14.5 10 15.7C8.4 14.5 6.2 14.2 4 15V5.5Z"
                stroke="currentColor"
                strokeWidth="1.6"
                strokeLinejoin="round"
              />
              <path d="M10 6.2V15.5" stroke="currentColor" strokeWidth="1.5" />
            </svg>
          </span>
          <span className="font-display text-xl font-medium tracking-[-0.02em] text-ink">
            Ilm Fan
          </span>
        </Link>

        <nav className="flex flex-wrap items-center gap-x-5 gap-y-2">
          {mainItems.map((item) => (
            <Link key={item.href} href={item.href} className={linkClass}>
              {item.label}
            </Link>
          ))}
          <span className="hidden h-4 w-px shrink-0 bg-line sm:block" aria-hidden />
          <AuthNavLink />
        </nav>
      </div>
    </header>
  );
}
