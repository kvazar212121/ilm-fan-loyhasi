import { MethodIcon } from "@/components/login/MethodIcon";
import { QrLoginStep } from "@/components/login/QrLoginStep";
import type { BackendUser } from "@/lib/auth/client";

export const loginMethods = [
  {
    id: "google",
    label: "Google bilan davom etish",
    note: "Bir bosishda tezkor kirish",
  },
  {
    id: "telegram",
    label: "Telegram orqali kirish",
    note: "Botda tasdiqlash, parolsiz",
  },
  {
    id: "phone",
    label: "Telefon raqam bilan",
    note: "5 xonali SMS kod orqali",
  },
] as const;

export type LoginMethodId = (typeof loginMethods)[number]["id"];

type MethodListProps = {
  onSelect: (methodId: LoginMethodId) => void;
  onQrAuthenticated: (user: BackendUser) => void;
  onQrRegistrationRequired: () => void;
};

export function MethodList({
  onSelect,
  onQrAuthenticated,
  onQrRegistrationRequired,
}: MethodListProps) {
  return (
    <div className="flex flex-col gap-5">
      <div className="space-y-1.5">
        <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink sm:text-4xl">
          Hisobga kirish
        </h1>
        <p className="text-sm leading-6 text-ink-muted">
          O‘zingizga qulay usulni tanlang yoki quyidagi QR kodni telefondan skanerlang.
        </p>
      </div>

      <ul className="flex flex-col gap-2.5">
        {loginMethods.map((method) => (
          <li key={method.id}>
            <button
              type="button"
              onClick={() => onSelect(method.id)}
              className="group flex w-full items-center justify-between gap-4 rounded-xl border border-line bg-paper/70 px-4 py-3 text-left transition-colors hover:border-accent hover:bg-accent-soft/50"
            >
              <span className="flex items-center gap-3.5">
                <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-line bg-surface">
                  <MethodIcon id={method.id} />
                </span>
                <span>
                  <span className="block text-sm font-semibold text-ink">{method.label}</span>
                  <span className="block text-xs text-ink-muted">{method.note}</span>
                </span>
              </span>
              <span
                aria-hidden
                className="text-base text-ink-muted transition-transform group-hover:translate-x-0.5 group-hover:text-accent"
              >
                →
              </span>
            </button>
          </li>
        ))}
      </ul>

      <QrLoginStep
        onAuthenticated={onQrAuthenticated}
        onRegistrationRequired={onQrRegistrationRequired}
      />
    </div>
  );
}
