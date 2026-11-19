import Link from "next/link";

type Props = {
  title: string;
};

export function TayyorlovFanIntro({ title }: Props) {
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-3 px-6 pt-12">
      <Link href="/tayyorlovlar" className="text-sm font-medium text-accent hover:underline">
        ← Barcha fanlar
      </Link>
      <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">Tayyorlov</p>
      <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">{title}</h1>
      <p className="text-lg leading-8 text-ink/70">
        Sertifikat imtihoni uchun {title.toLowerCase()} bo‘yicha video qo‘llanmalar va testlar.
      </p>
    </section>
  );
}