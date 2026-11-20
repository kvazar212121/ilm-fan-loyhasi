import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="border-t border-line">
      <p className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-6 py-6 text-sm text-ink/60">
        <span>
          Tayyorlov platformasi. O‘qituvchi sertifikati va abituriyent imtihoni alohida. Sertifikat
          tashqarida beriladi.
        </span>
        <Link href="/admin" className="font-medium text-ink/70 hover:text-accent">
          Boshqaruv
        </Link>
      </p>
    </footer>
  );
}
