import Link from "next/link";

import { StoryArt } from "@/components/marketing/StoryArt";
import { StoryBody } from "@/components/marketing/StoryBody";
import type { SectionStory } from "@/components/marketing/types";

export function SectionStoryView({ story }: { story: SectionStory }) {
  return (
    <div className="flex flex-col gap-12 pb-8">
      <section className="mx-auto grid w-full max-w-6xl items-center gap-10 px-6 pt-14 lg:grid-cols-2">
        <div className="flex flex-col gap-4">
          <p className="text-sm font-medium tracking-[0.18em] text-accent uppercase">{story.eyebrow}</p>
          <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">{story.title}</h1>
          <p className="text-lg leading-8 text-ink/75">{story.lead}</p>
        </div>
        <StoryArt id={story.art} label={story.title} />
      </section>
      <StoryBody story={story} />
      <section className="mx-auto w-full max-w-6xl px-6 pb-10">
        <div className="rounded-3xl bg-accent px-6 py-12 text-white sm:px-12">
          <p className="text-xs font-medium tracking-[0.16em] text-white/70 uppercase">Keyingi qadam</p>
          <h2 className="mt-3 max-w-xl text-3xl font-semibold tracking-tight">O‘qib bo‘ldingizmi?</h2>
          <p className="mt-3 max-w-xl text-base leading-7 text-white/85">
            Kirishni boshlagach Telegram, Google yoki telefon so‘raladi. Keyin rol va ism. O‘qituvchi
            bitta fan, abituriyent bir nechta fan tanlaydi. Oddiy o‘quvchidan fan so‘ralmaydi.
          </p>
          <Link
            href="/login"
            className="mt-6 inline-flex rounded-full bg-white px-5 py-3 text-sm font-medium text-accent"
          >
            Kirishni boshlash
          </Link>
        </div>
      </section>
    </div>
  );
}
