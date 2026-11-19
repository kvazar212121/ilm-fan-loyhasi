import { reelMaxDurationSec, reelTargetFormat } from "@/lib/reel-config";

export function ReelRules() {
  return (
    <section className="rounded-2xl border border-line bg-white p-5 text-sm leading-6 text-ink/70">
      <h2 className="text-base font-semibold text-ink">Reel qoidalari</h2>
      <ul className="mt-3 list-disc space-y-1 pl-5">
        <li>Video uzunligi {reelMaxDurationSec / 60} daqiqadan oshmasin.</li>
        <li>Tizim videoni {reelTargetFormat} ga o‘tkazadi.</li>
        <li>Siqish sifatni saqlagan holda hajmni kamaytiradi (serverda).</li>
        <li>Tayyor reel “Mening reelslarim” va umumiy lentada chiqadi.</li>
      </ul>
    </section>
  );
}