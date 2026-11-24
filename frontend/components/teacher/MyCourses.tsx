import Link from "next/link";

export function MyCourses() {
  return (
    <section className="rounded-2xl border border-line bg-surface p-6">
      <div className="flex items-center justify-between gap-3 border-b border-line pb-4">
        <h2 className="font-display text-xl font-medium tracking-[-0.015em] text-ink">
          Mening kurslarim
        </h2>
        <Link
          href="/profile/courses/create"
          className="rounded-full bg-accent-soft px-3.5 py-1.5 text-xs font-medium text-accent transition-colors hover:bg-accent hover:text-paper"
        >
          Yaratish
        </Link>
      </div>
      <p className="mt-4 text-sm leading-6 text-ink-muted">
        Hozircha kursingiz yo‘q. Yangi tayyorlov kursini yuqoridagi tugma orqali ochishingiz mumkin.
      </p>
    </section>
  );
}
