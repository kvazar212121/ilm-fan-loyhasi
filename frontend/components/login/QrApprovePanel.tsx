import { MethodIcon } from "@/components/login/MethodIcon";

const verifyMethods = [
  { id: "telegram", label: "Telegram orqali", note: "Botda tasdiqlash, parolsiz" },
  { id: "google", label: "Google orqali", note: "Bir bosishda tezkor kirish" },
  { id: "phone", label: "SMS kod orqali", note: "Telefon raqamga 5 xonali kod" },
] as const;

type QrApprovePanelProps = {
  device: string;
  meName: string;
  busy: boolean;
  error: string | null;
  onApproveSession: () => void;
  onSelectMethod: (id: "google" | "telegram" | "phone") => void;
  onReject: () => void;
};

export function QrApprovePanel({
  device,
  meName,
  busy,
  error,
  onApproveSession,
  onSelectMethod,
  onReject,
}: QrApprovePanelProps) {
  return (
    <div className="flex flex-col gap-5">
      <div className="space-y-1.5">
        <span className="inline-flex rounded-full border border-line bg-paper px-3 py-1 text-xs font-medium text-ink-muted">
          {device}
        </span>
        <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
          Kompyuterda kirishni tasdiqlang
        </h1>
        <p className="text-sm leading-6 text-ink-muted">
          Quyidagi usullardan birini tanlang — tasdiqlangan zahoti kompyuter avtomatik kiradi.
        </p>
      </div>

      {error ? <p className="rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">{error}</p> : null}

      <ul className={`flex flex-col gap-2.5 ${busy ? "pointer-events-none opacity-60" : ""}`}>
        {verifyMethods.map((m) => (
          <li key={m.id}>
            <button
              type="button"
              onClick={() => onSelectMethod(m.id)}
              className="group flex w-full items-center justify-between gap-4 rounded-xl border border-line bg-paper/80 px-4 py-3.5 text-left transition-colors hover:border-accent hover:bg-accent-soft/50 active:scale-[0.99]"
            >
              <span className="flex items-center gap-3.5">
                <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-line bg-surface">
                  <MethodIcon id={m.id} />
                </span>
                <span>
                  <span className="block text-sm font-semibold text-ink">{m.label}</span>
                  <span className="block text-xs text-ink-muted">{m.note}</span>
                </span>
              </span>
              <span aria-hidden className="text-base text-ink-muted group-hover:text-accent">
                →
              </span>
            </button>
          </li>
        ))}
      </ul>

      {meName ? (
        <div className="flex flex-col gap-2 border-t border-line pt-4">
          <button
            type="button"
            disabled={busy}
            onClick={onApproveSession}
            className="w-full rounded-full bg-accent px-5 py-3 text-sm font-medium text-paper transition-colors hover:bg-accent-hover disabled:opacity-60"
          >
            {busy ? "Tasdiqlanmoqda..." : `${meName} sifatida 1 bosishda kirish`}
          </button>
        </div>
      ) : null}

      <button
        type="button"
        disabled={busy}
        onClick={onReject}
        className="w-fit text-xs font-medium text-ink-muted transition-colors hover:text-red-700"
      >
        Kirish so‘rovini rad etish
      </button>
    </div>
  );
}
