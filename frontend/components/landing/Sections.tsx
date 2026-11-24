import Link from "next/link";

const sections = [
  {
    href: "/tayyorlov/sertifikat",
    title: "Sertifikatga tayyorlov",
    text: "O‘qituvchilar uchun fan bo‘yicha bosqichma-bosqich mavzular va sinov testlari.",
    tag: "Ustozlar",
  },
  {
    href: "/tayyorlov/abituriyent",
    title: "Abituriyent tayyorlovi",
    text: "OTM kirish imtihonlariga mo‘ljallangan ko‘p fanli o‘quv yo‘nalishi.",
    tag: "OTM",
  },
  {
    href: "/textbooks",
    title: "Darsliklar",
    text: "Bo‘lim va mavzularga ajratilgan zamonaviy matn, PDF, audio va video qo‘llanmalar.",
    tag: "Kutubxona",
  },
  {
    href: "/tests",
    title: "Testlar",
    text: "Imtihon oldidan bilimni tekshirish, yechim tahlili va jonli musobaqa xonalari.",
    tag: "Amaliyot",
  },
  {
    href: "/courses",
    title: "Kurslar",
    text: "Ustozlar ochgan tayyorlov kurslariga qo‘shilish va guruhda ishlash.",
    tag: "Guruhlar",
  },
  {
    href: "/reels",
    title: "Reels",
    text: "Murakkab mavzularni bir necha daqiqada tushuntiruvchi qisqa video darslar.",
    tag: "Video",
  },
];

export function Sections() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-16 sm:py-24">
      <div className="grid gap-10 lg:grid-cols-12 lg:gap-12">
        <div className="lg:col-span-4">
          <h2 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink sm:text-4xl">
            Platforma bo‘limlari
          </h2>
          <p className="mt-4 text-base leading-7 text-ink-muted">
            O‘qish, amaliy test va qisqa video tushuntirishlar bir-biriga bog‘langan — kerakli
            bo‘limni tanlab darhol boshlashingiz mumkin.
          </p>
        </div>

        <ul className="divide-y divide-line border-t border-b border-line lg:col-span-8">
          {sections.map((item) => (
            <li key={item.href}>
              <Link
                href={item.href}
                className="group flex flex-col justify-between gap-2 py-5 transition-colors sm:flex-row sm:items-center sm:gap-6"
              >
                <div className="max-w-xl">
                  <div className="flex flex-wrap items-center gap-3">
                    <h3 className="font-display text-2xl font-medium tracking-[-0.015em] text-ink transition-colors group-hover:text-accent">
                      {item.title}
                    </h3>
                    <span className="rounded-full bg-surface-muted px-2.5 py-0.5 text-xs font-medium text-ink-muted">
                      {item.tag}
                    </span>
                  </div>
                  <p className="mt-1.5 text-sm leading-6 text-ink-muted">{item.text}</p>
                </div>
                <span
                  aria-hidden
                  className="text-lg text-ink-muted transition-transform group-hover:translate-x-1 group-hover:text-accent"
                >
                  →
                </span>
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
