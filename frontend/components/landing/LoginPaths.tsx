import Link from "next/link";

const paths = ["Google", "Telegram", "Telefon raqam"];

export function LoginPaths() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-8 pb-16">
      <h2 className="mb-4 text-2xl font-semibold tracking-tight">Kirish</h2>
      <ul className="flex flex-wrap gap-3">
        {paths.map((label) => (
          <li key={label}>
            <Link
              href="/login"
              className="inline-flex rounded-full border border-line bg-white px-4 py-2 text-sm font-medium"
            >
              {label}
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}
