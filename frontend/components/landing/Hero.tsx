import Link from "next/link";

export function Hero() {
  return (
    <section className="mx-auto flex w-full max-w-6xl flex-col gap-6 px-6 py-16 sm:py-24">
      <p className="text-sm font-medium tracking-[0.18em] text-accent uppercase">
        Sertifikat imtihoniga tayyorlov
      </p>
      <h1 className="max-w-3xl text-4xl font-semibold tracking-tight sm:text-6xl">
        Faningiz bo‘yicha o‘qing, mashq qiling, imtihonga chiqing.
      </h1>
      <p className="max-w-2xl text-lg leading-8 text-ink/70">
        O‘qituvchi va o‘quvchi material, test va qisqa dars oladi. Kurs
        tashkilotchisi tayyorlov kursi ochadi. Sertifikatning o‘zi imtihondan
        keyin tashqarida beriladi.
      </p>
      <div className="flex flex-wrap gap-3">
        <Link
          href="/tayyorlovlar"
          className="rounded-full bg-accent px-5 py-3 text-sm font-medium text-white"
        >
          Tayyorlovlarga o‘tish
        </Link>
        <Link
          href="/login"
          className="rounded-full border border-line bg-white px-5 py-3 text-sm font-medium"
        >
          Kirish
        </Link>
      </div>
    </section>
  );
}
