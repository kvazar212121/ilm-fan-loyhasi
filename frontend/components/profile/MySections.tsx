const sections = [
  {
    title: "Mening kurslarim",
    text: "Hozircha kursingiz yo‘q.",
  },
  {
    title: "Mening reelslarim",
    text: "Hozircha reelsingiz yo‘q.",
  },
];

export function MySections() {
  return (
    <ul className="grid gap-3 sm:grid-cols-2">
      {sections.map((section) => (
        <li key={section.title} className="rounded-2xl border border-line bg-white p-5">
          <h2 className="text-lg font-semibold">{section.title}</h2>
          <p className="mt-2 text-sm leading-6 text-ink/60">{section.text}</p>
        </li>
      ))}
    </ul>
  );
}
