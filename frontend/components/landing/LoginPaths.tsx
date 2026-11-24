import Link from "next/link";

const methods = ["Google", "Telegram", "Telefon raqam"];

export function LoginPaths() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 pb-20">
      <div className="rounded-2xl bg-accent px-7 py-10 text-paper sm:px-12 sm:py-14">
        <div className="grid items-center gap-8 lg:grid-cols-12">
          <div className="space-y-3 lg:col-span-7">
            <h2 className="font-display text-3xl leading-[1.12] font-medium tracking-[-0.02em] sm:text-4xl">
              Bitta profil bilan barcha qurilmalarda davom eting.
            </h2>
            <p className="max-w-[54ch] text-base leading-7 text-paper/80">
              Google, Telegram yoki telefon raqam orqali kiring — keyinchalik qolgan usullarni ham
              profildan ulab, bitta hisobda birlashtirishingiz mumkin.
            </p>
          </div>

          <div className="flex flex-col items-start gap-4 lg:col-span-5 lg:items-end">
            <Link
              href="/login"
              className="inline-flex items-center gap-2 rounded-full bg-paper px-6 py-3.5 text-sm font-semibold text-accent transition-colors hover:bg-surface"
            >
              Hisobga kirish
              <span aria-hidden>→</span>
            </Link>
            <div className="flex flex-wrap gap-2">
              {methods.map((label) => (
                <Link
                  key={label}
                  href="/login"
                  className="rounded-full border border-paper/30 px-3.5 py-1.5 text-xs font-medium text-paper/90 transition-colors hover:border-paper hover:bg-paper/10"
                >
                  {label}
                </Link>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
