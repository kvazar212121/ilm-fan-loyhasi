import { RoleIcon } from "@/components/login/RoleIcon";
import { roles, type RoleId } from "@/components/login/roles";

type RolePickerProps = {
  onBack: () => void;
  onSelect: (roleId: RoleId) => void;
};

export function RolePicker({ onBack, onSelect }: RolePickerProps) {
  return (
    <div className="flex flex-col gap-8">
      <div className="flex flex-col gap-2">
        <button
          type="button"
          onClick={onBack}
          className="w-fit text-sm text-ink/55 transition-colors hover:text-ink"
        >
          ← Kirish usuli
        </button>
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">2-qadam</p>
        <h1 className="text-3xl font-semibold tracking-tight">Qaysi rol?</h1>
        <p className="text-sm leading-6 text-ink/60">
          O‘qituvchi bitta fan, abituriyent bir nechta fan tanlaydi. O‘quvchidan fan so‘ralmaydi.
        </p>
      </div>
      <ul className="grid gap-3 sm:grid-cols-2">
        {roles.map((role) => (
          <li key={role.id}>
            <button
              type="button"
              onClick={() => onSelect(role.id)}
              className="flex h-full w-full flex-col items-start gap-3 rounded-2xl border border-line bg-white p-4 text-left transition-colors hover:border-accent"
            >
              <span className="flex h-10 w-10 items-center justify-center rounded-full bg-paper text-accent">
                <RoleIcon id={role.id} />
              </span>
              <span className="block text-base font-medium">{role.title}</span>
              <span className="block text-sm leading-5 text-ink/55">{role.text}</span>
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
