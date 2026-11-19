import Link from "next/link";

export function MyCourses() {
  return (
    <section className="rounded-2xl border border-line bg-white p-5">
      <div className="flex items-start justify-between gap-3">
        <h2 className="text-lg font-semibold">Mening kurslarim</h2>
        <Link
          href="/profile/courses/create"
          className="text-sm font-medium text-accent"
        >
          Yaratish
        </Link>
      </div>
      <p className="mt-4 text-sm text-ink/60">Hozircha kursingiz yo‘q.</p>
    </section>
  );
}