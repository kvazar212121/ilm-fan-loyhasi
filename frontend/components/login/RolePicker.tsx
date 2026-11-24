import { RoleIcon } from "@/components/login/RoleIcon";
import { roles, type RoleId } from "@/components/login/roles";

type RolePickerProps = {
  disabled?: boolean;
  onBack: () => void;
  onSelect: (roleId: RoleId) => void;
};

export function RolePicker({ disabled = false, onBack, onSelect }: RolePickerProps) {
  return (
    <div className={`flex flex-col gap-6 ${disabled ? "pointer-events-none opacity-60" : ""}`}>
      <div className="space-y-1.5">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink-muted transition-colors hover:text-ink"
        >
          ← Shaxsiy ma’lumotlar
        </button>
        <h1 className="font-display text-3xl font-medium tracking-[-0.02em] text-ink">
          Qaysi rolda qatnashasiz?
        </h1>
        <p className="text-sm leading-6 text-ink-muted">
          O‘qituvchi bitta fan, abituriyent bir nechta fan tanlaydi. O‘quvchidan fan so‘ralmaydi.
        </p>
      </div>

      <ul className="grid gap-3 sm:grid-cols-2">
        {roles.map((role) => (
          <li key={role.id}>
            <button
              type="button"
              onClick={() => onSelect(role.id)}
              className="group flex h-full w-full flex-col items-start gap-2.5 rounded-xl border border-line bg-paper/70 p-4 text-left transition-colors hover:border-accent hover:bg-accent-soft/50"
            >
              <span className="flex h-9 w-9 items-center justify-center rounded-lg border border-line bg-surface text-accent transition-colors group-hover:border-accent group-hover:bg-accent group-hover:text-paper">
                <RoleIcon id={role.id} />
              </span>
              <span className="block text-sm font-semibold text-ink">{role.title}</span>
              <span className="block text-xs leading-5 text-ink-muted">{role.text}</span>
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
