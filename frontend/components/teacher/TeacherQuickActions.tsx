import Link from "next/link";

const actions = [
  {
    href: "/profile/courses/create",
    title: "Kurs yaratish",
    text: "Tayyorlov kursi ochish.",
  },
  {
    href: "/profile/tests/create",
    title: "Test yaratish",
    text: "Qog‘ozga chiqadigan test tuzish.",
  },
  {
    href: "/profile/tests/race",
    title: "Auditoriya musobaqasi",
    text: "Linkni ekranga chiqarish. Birinchi to‘g‘ri javob ball oladi.",
  },
  {
    href: "/profile/reels/create",
    title: "Reel joylash",
    text: "2 daqiqalik video, format va siqish.",
  },
];

export function TeacherQuickActions() {
  return (
    <section className="rounded-2xl border border-line bg-surface p-6">
      <div className="border-b border-line pb-4">
        <h2 className="font-display text-xl font-medium tracking-[-0.015em] text-ink">
          O‘qituvchi asboblari
        </h2>
        <p className="mt-0.5 text-xs text-ink-muted">
          Dars, test va musobaqa materiallarini tezkor boshqarish.
        </p>
      </div>

      <ul className="mt-2 flex flex-col divide-y divide-line">
        {actions.map((item) => (
          <li key={item.href}>
            <Link
              href={item.href}
              className="group -mx-2 flex items-center justify-between gap-3 rounded-xl px-2 py-3.5 transition-colors hover:bg-paper"
            >
              <span>
                <span className="block text-sm font-medium text-ink transition-colors group-hover:text-accent">
                  {item.title}
                </span>
                <span className="mt-0.5 block text-xs leading-5 text-ink-muted">{item.text}</span>
              </span>
              <span
                aria-hidden
                className="shrink-0 text-sm text-ink-muted transition-transform group-hover:translate-x-0.5 group-hover:text-accent"
              >
                →
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}
