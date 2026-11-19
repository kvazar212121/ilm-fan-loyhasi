const audiences = [
  {
    title: "O‘qituvchi",
    text: "Tanlagan fani bo‘yicha o‘qiydi va imtihon oldidan mashq qiladi.",
  },
  {
    title: "O‘quvchi",
    text: "O‘zi uchun darslik va qo‘llanma o‘qiydi.",
  },
  {
    title: "Kurs tashkilotchisi",
    text: "Tayyorlov kursi ochadi va o‘z testini chiqaradi.",
  },
];

export function Audiences() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 pb-8">
      <h2 className="mb-4 text-2xl font-semibold tracking-tight">Kimlar uchun</h2>
      <ul className="grid gap-4 sm:grid-cols-3">
        {audiences.map((item) => (
          <li key={item.title} className="rounded-2xl border border-line bg-white p-5">
            <h3 className="text-lg font-semibold">{item.title}</h3>
            <p className="mt-2 text-sm leading-6 text-ink/70">{item.text}</p>
          </li>
        ))}
      </ul>
    </section>
  );
}
