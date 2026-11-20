import Link from "next/link";

const modes = [
  {
    href: "/tests/individual",
    title: "Individual",
    text: "O‘zingiz, o‘z vaqtingizda yechasiz. Javobni belgilagach to‘g‘ri variant shu joyida ochiladi.",
  },
  {
    href: "/tests/live",
    title: "Hamma bilan",
    text: "Bir xona, bir vaqt. Savol hammaga birga tushadi, belgilangan soniya kutadi, keyin kim to‘g‘ri topgani ko‘rinadi.",
  },
  {
    href: "/profile/tests/race",
    title: "Auditoriya",
    text: "O‘qituvchi test tuzadi va linkni ekranga chiqaradi. Birinchi to‘g‘ri topgan o‘quvchi ball oladi.",
  },
] as const;

export function TestModes() {
  return (
    <div className="grid gap-3 sm:grid-cols-2">
      {modes.map((mode) => (
        <Link
          key={mode.href}
          href={mode.href}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-white p-5 transition-colors hover:border-accent"
        >
          <span className="text-lg font-semibold">{mode.title}</span>
          <span className="text-sm leading-6 text-ink/70">{mode.text}</span>
          <span className="text-sm font-medium text-accent">Ochish →</span>
        </Link>
      ))}
    </div>
  );
}
