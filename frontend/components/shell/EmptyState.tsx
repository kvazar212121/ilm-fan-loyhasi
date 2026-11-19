type EmptyStateProps = {
  title: string;
  description: string;
};

export function EmptyState({ title, description }: EmptyStateProps) {
  return (
    <section className="mx-auto flex w-full max-w-3xl flex-col gap-3 px-6 py-16">
      <h1 className="text-3xl font-semibold tracking-tight">{title}</h1>
      <p className="text-lg leading-8 text-ink/70">{description}</p>
    </section>
  );
}
