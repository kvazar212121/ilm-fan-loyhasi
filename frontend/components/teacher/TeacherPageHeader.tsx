import Link from "next/link";

type TeacherPageHeaderProps = {
  title: string;
  subtitle?: string;
};

export function TeacherPageHeader({ title, subtitle }: TeacherPageHeaderProps) {
  return (
    <header className="flex flex-col gap-2">
      <Link
        href="/profile"
        className="w-fit text-sm text-ink/55 transition-colors hover:text-ink"
      >
        ← Profil
      </Link>
      <h1 className="text-3xl font-semibold tracking-tight">{title}</h1>
      {subtitle ? (
        <p className="text-sm leading-6 text-ink/60">{subtitle}</p>
      ) : null}
    </header>
  );
}