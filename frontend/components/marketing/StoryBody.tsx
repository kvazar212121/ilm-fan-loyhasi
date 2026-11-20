import type { SectionStory } from "@/components/marketing/types";

const blocks = [
  { key: "benefits" as const, kicker: "Qulaylik", title: "Nima uchun qulay" },
  { key: "gives" as const, kicker: "Natija", title: "Nima beradi" },
];

export function StoryBody({ story }: { story: SectionStory }) {
  return (
    <>
      <section className="mx-auto w-full max-w-6xl px-6">
        <div className="rounded-3xl border border-line bg-white p-6 sm:p-10">
          <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Nima uchun bor</p>
          <h2 className="mt-2 max-w-xl text-2xl font-semibold tracking-tight sm:text-3xl">
            Shu bo‘lim tizimda nima qiladi
          </h2>
          <p className="mt-4 max-w-3xl text-base leading-7 text-ink/75">{story.purpose}</p>
        </div>
      </section>
      {blocks.map((block) => (
        <section key={block.key} className="mx-auto w-full max-w-6xl px-6">
          <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">{block.kicker}</p>
          <h2 className="mt-2 text-2xl font-semibold tracking-tight">{block.title}</h2>
          <ul className="mt-5 grid gap-3 sm:grid-cols-2">
            {story[block.key].map((item, index) => (
              <li key={item.title} className="rounded-2xl border border-line bg-white p-5">
                <p className="text-xs font-medium tracking-[0.14em] text-accent">
                  {String(index + 1).padStart(2, "0")}
                </p>
                <h3 className="mt-2 text-lg font-semibold">{item.title}</h3>
                <p className="mt-2 text-sm leading-6 text-ink/70">{item.text}</p>
              </li>
            ))}
          </ul>
        </section>
      ))}
      <section className="mx-auto w-full max-w-6xl px-6">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Yo‘l</p>
        <h2 className="mt-2 text-2xl font-semibold tracking-tight">Qanday boshlanadi</h2>
        <ol className="mt-5 grid gap-3 lg:grid-cols-3">
          {story.steps.map((step, index) => (
            <li key={step.title} className="rounded-2xl bg-white p-5 ring-1 ring-line">
              <p className="text-3xl font-semibold text-accent/80">{index + 1}</p>
              <h3 className="mt-2 text-lg font-semibold">{step.title}</h3>
              <p className="mt-2 text-sm leading-6 text-ink/70">{step.text}</p>
            </li>
          ))}
        </ol>
      </section>
    </>
  );
}
