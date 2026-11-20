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
    <section className="rounded-2xl border border-line bg-white p-5">
      <h2 className="text-lg font-semibold">Asboblar</h2>
      <ul className="mt-4 flex flex-col gap-2">
        {actions.map((item) => (
          <li key={item.href}>
            <Link
              href={item.href}
              className="flex items-center justify-between gap-3 rounded-xl border border-line px-4 py-3 transition-colors hover:border-accent"
            >
              <span>
                <span className="block text-sm font-medium">{item.title}</span>
                <span className="block text-xs text-ink/55">{item.text}</span>
              </span>
              <span aria-hidden className="text-ink/30">
                →
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}