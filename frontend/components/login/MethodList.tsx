import { MethodIcon } from "@/components/login/MethodIcon";
import type { Role } from "@/components/login/roles";

export const loginMethods = [
  { id: "google", label: "Google" },
  { id: "telegram", label: "Telegram" },
  { id: "phone", label: "Telefon raqam" },
] as const;

export type LoginMethodId = (typeof loginMethods)[number]["id"];

type MethodListProps = {
  role: Role;
  onBack: () => void;
  onSelect: (methodId: LoginMethodId) => void;
};

export function MethodList({ role, onBack, onSelect }: MethodListProps) {
  return (
    <div className="flex flex-col gap-8">
      <div className="flex flex-col gap-2">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink/55 transition-colors hover:text-ink"
        >
          ← Rolni o‘zgartirish
        </button>
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
          2-qadam
        </p>
        <h1 className="text-3xl font-semibold tracking-tight">Kirish</h1>
        <p className="text-sm leading-6 text-ink/60">{role.title} sifatida usulni tanlang.</p>
      </div>
      <ul className="flex flex-col gap-2">
        {loginMethods.map((method) => (
          <li key={method.id}>
            <button
              type="button"
              onClick={() => onSelect(method.id)}
              className="flex w-full items-center gap-3 rounded-2xl border border-line bg-white px-4 py-4 text-left text-base font-medium transition-colors hover:border-accent"
            >
              <MethodIcon id={method.id} />
              {method.label}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
