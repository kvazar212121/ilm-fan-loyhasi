import Link from "next/link";

const audiences = [
  {
    title: "O‘qituvchi",
    text: "O‘z fani bo‘yicha davlat sertifikatiga tayyorlanadi, o‘quvchilari uchun darslik va test tuzadi.",
    href: "/tayyorlov/sertifikat",
    cta: "Sertifikat bo‘limiga o‘tish",
  },
  {
    title: "Abituriyent va o‘quvchi",
    text: "Bir nechta fandan rejali o‘qiydi, mavzu testlarini yechadi va ustoz bergan vazifalarni topshiradi.",
    href: "/tayyorlov/abituriyent",
    cta: "Tayyorlovni boshlash",
  },
  {
    title: "Kurs tashkilotchisi",
    text: "Tayyorlov guruhlarini boshqaradi, mualliflik darsliklari va imtihon variantlarini nashr etadi.",
    href: "/courses",
    cta: "Kurslarni ko‘rish",
  },
];

export function Audiences() {
  return (
    <section className="border-y border-line bg-surface">
      <div className="mx-auto max-w-6xl px-6 py-14 sm:py-16">
        <h2 className="font-display mb-10 text-3xl font-medium tracking-[-0.02em] text-ink sm:text-4xl">
          Kimlar uchun mo‘ljallangan
        </h2>
        <ul className="grid divide-y divide-line md:grid-cols-3 md:divide-x md:divide-y-0">
          {audiences.map((item, idx) => (
            <li
              key={item.title}
              className={`flex flex-col justify-between gap-5 py-6 md:py-0 ${
                idx === 0 ? "md:pr-8" : idx === 1 ? "md:px-8" : "md:pl-8"
              }`}
            >
              <div>
                <h3 className="text-lg font-semibold text-ink">{item.title}</h3>
                <p className="mt-2.5 text-sm leading-7 text-ink-muted">{item.text}</p>
              </div>
              <Link
                href={item.href}
                className="inline-flex w-fit items-center gap-1.5 text-sm font-medium text-accent underline-offset-4 transition-colors hover:text-accent-hover hover:underline"
              >
                {item.cta}
                <span aria-hidden>→</span>
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
