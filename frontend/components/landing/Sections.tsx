import Link from "next/link";

const sections = [
  {
    href: "/tayyorlov/sertifikat",
    title: "Sertifikatga tayyorlov",
    text: "O‘qituvchi davlat sertifikati imtihoniga tayyorlanadi.",
  },
  {
    href: "/tayyorlov/abituriyent",
    title: "Abituriyent tayyorlovi",
    text: "Abituriyent oliy ta’lim imtihonlariga tayyorlanadi.",
  },
  {
    href: "/textbooks",
    title: "Darsliklar",
    text: "O‘quvchi o‘zi uchun o‘qiydigan kitoblar.",
  },
  {
    href: "/tests",
    title: "Testlar",
    text: "Imtihon oldidan mashq. Kurs tashkilotchisi test chiqaradi.",
  },
  {
    href: "/courses",
    title: "Kurslar",
    text: "Tayyorlov kursini tashkil qilish.",
  },
  {
    href: "/reels",
    title: "Reels",
    text: "Qisqa video darslar lentada.",
  },
];

export function Sections() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-8">
      <h2 className="mb-4 text-2xl font-semibold tracking-tight">Bo‘limlar</h2>
      <ul className="grid gap-4 sm:grid-cols-2">
        {sections.map((item) => (
          <li key={item.href}>
            <Link
              href={item.href}
              className="block rounded-2xl border border-line bg-white p-5 transition-colors hover:border-accent"
            >
              <h3 className="text-lg font-semibold">{item.title}</h3>
              <p className="mt-2 text-sm leading-6 text-ink/70">{item.text}</p>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}
