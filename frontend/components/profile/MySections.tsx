import Link from "next/link";

const sections = [
  {
    title: "Mening kurslarim",
    text: "Hozircha yozilgan kursingiz yo‘q.",
    href: "/courses",
    action: "Kurslarni ko‘rish",
  },
  {
    title: "Mening reelslarim",
    text: "Hozircha saqlangan reelsingiz yo‘q.",
    href: "/reels",
    action: "Reelslarni ko‘rish",
  },
  {
    title: "Tayyorlov yo‘nalishlari",
    text: "Milliy sertifikat va SAT bo‘yicha fanlar to‘plami.",
    href: "/tayyorlovlar",
    action: "Fanlarga o‘tish",
  },
];

export function MySections() {
  return (
    <section className="rounded-2xl border border-line bg-surface p-6">
      <div className="border-b border-line pb-4">
        <h2 className="font-display text-xl font-medium tracking-[-0.015em] text-ink">
          O‘quv bo‘limlari
        </h2>
        <p className="mt-0.5 text-xs text-ink-muted">
          Kurslar, qisqa darslar va tayyorlov materiallari.
        </p>
      </div>

      <ul className="mt-2 flex flex-col divide-y divide-line">
        {sections.map((section) => (
          <li key={section.title} className="py-4 last:pb-0">
            <div className="flex items-start justify-between gap-4">
              <div>
                <h3 className="text-sm font-medium text-ink">{section.title}</h3>
                <p className="mt-1 text-xs leading-5 text-ink-muted">{section.text}</p>
              </div>
              <Link
                href={section.href}
                className="shrink-0 text-xs font-medium text-accent transition-colors hover:text-accent-hover"
              >
                {section.action} →
              </Link>
            </div>
          </li>
        ))}
      </ul>
    </section>
  );
}
