import Link from "next/link";

const footerLinks = [
  { href: "/tayyorlov/sertifikat", label: "Sertifikat" },
  { href: "/tayyorlov/abituriyent", label: "Abituriyent" },
  { href: "/textbooks", label: "Darsliklar" },
  { href: "/tests", label: "Testlar" },
  { href: "/courses", label: "Kurslar" },
  { href: "/admin", label: "Boshqaruv" },
];

export function SiteFooter() {
  return (
    <footer className="border-t border-line bg-paper">
      <div className="mx-auto flex max-w-6xl flex-col gap-6 px-6 py-10 sm:flex-row sm:items-end sm:justify-between">
        <div className="max-w-md space-y-2">
          <p className="font-display text-lg font-medium tracking-[-0.015em] text-ink">Ilm Fan</p>
          <p className="text-sm leading-6 text-ink-muted">
            O‘qituvchi sertifikati va abituriyent imtihoniga tayyorlov platformasi. Rasmiy
            sertifikat imtihondan so‘ng vakolatli tashkilot tomonidan beriladi.
          </p>
        </div>
        <nav className="flex flex-wrap gap-x-5 gap-y-2 text-sm text-ink-muted">
          {footerLinks.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="underline-offset-4 transition-colors hover:text-ink hover:underline"
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </div>
    </footer>
  );
}
