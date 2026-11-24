import type { ReactNode } from "react";

type LoginShellProps = {
  activeStep: 1 | 2 | 3 | 4;
  showProgress: boolean;
  children: ReactNode;
};

const stepLabels = [
  { num: 1, label: "Kirish" },
  { num: 2, label: "Ma’lumotlar" },
  { num: 3, label: "Rol" },
  { num: 4, label: "Fan" },
] as const;

const highlights = [
  "O‘qituvchi sertifikati va abituriyent tayyorlovi alohida rejalarda",
  "Google, Telegram va telefon raqam bitta profilga ulanadi",
  "Darsliklar, oraliq testlar va video saboqlar doim qo‘l ostida",
];

export function LoginShell({ activeStep, showProgress, children }: LoginShellProps) {
  return (
    <section className="mx-auto flex w-full max-w-6xl flex-1 items-center px-6 py-10 sm:py-16">
      <div className="grid w-full overflow-hidden rounded-2xl border border-line bg-surface lg:grid-cols-12">
        <aside className="hidden flex-col justify-between bg-accent p-10 text-paper lg:col-span-5 lg:flex">
          <div className="space-y-6">
            <div className="inline-flex h-10 w-10 items-center justify-center rounded-xl border border-paper/25">
              <svg viewBox="0 0 20 20" className="h-5 w-5" fill="none" aria-hidden>
                <path
                  d="M4 5.5C6.2 4.7 8.4 5 10 6.2C11.6 5 13.8 4.7 16 5.5V15C13.8 14.2 11.6 14.5 10 15.7C8.4 14.5 6.2 14.2 4 15V5.5Z"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinejoin="round"
                />
                <path d="M10 6.2V15.5" stroke="currentColor" strokeWidth="1.4" />
              </svg>
            </div>
            <h2 className="font-display text-4xl leading-[1.1] font-medium tracking-[-0.02em]">
              Ilm yo‘lida <em className="font-normal italic">tartibli</em> tayyorlov.
            </h2>
            <p className="max-w-[38ch] text-sm leading-7 text-paper/80">
              Hisobingizga kiring va o‘z yo‘nalishingiz bo‘yicha darsliklar, testlar hamda
              natijalaringizni bir joyda kuzating.
            </p>
          </div>

          <ul className="space-y-3.5 border-t border-paper/20 pt-6 text-sm text-paper/90">
            {highlights.map((text) => (
              <li key={text} className="flex items-start gap-3">
                <svg
                  viewBox="0 0 16 16"
                  className="mt-1 h-4 w-4 shrink-0 text-paper/80"
                  fill="none"
                  aria-hidden
                >
                  <path
                    d="M3.5 8.5L6.5 11.5L12.5 5"
                    stroke="currentColor"
                    strokeWidth="1.6"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
                <span className="leading-6">{text}</span>
              </li>
            ))}
          </ul>
        </aside>

        <div className="flex flex-col justify-center p-6 sm:p-10 lg:col-span-7 lg:p-12">
          {showProgress ? (
            <nav aria-label="Ro‘yxatdan o‘tish bosqichlari" className="mb-8 border-b border-line pb-5">
              <ol className="flex flex-wrap items-center gap-x-5 gap-y-2 text-xs font-medium">
                {stepLabels.map((item) => {
                  const done = item.num < activeStep;
                  const current = item.num === activeStep;
                  return (
                    <li
                      key={item.num}
                      className={`flex items-center gap-2 ${
                        current ? "text-ink" : done ? "text-accent" : "text-ink-muted"
                      }`}
                    >
                      <span
                        className={`flex h-6 w-6 items-center justify-center rounded-full text-xs tabular-nums ${
                          current
                            ? "bg-accent text-paper"
                            : done
                              ? "bg-accent-soft text-accent"
                              : "border border-line bg-paper text-ink-muted"
                        }`}
                      >
                        {item.num}
                      </span>
                      <span>{item.label}</span>
                    </li>
                  );
                })}
              </ol>
            </nav>
          ) : null}

          <div className="mx-auto w-full max-w-lg">{children}</div>
        </div>
      </div>
    </section>
  );
}
