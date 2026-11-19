type ProfileReadyProps = {
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
};

export function ProfileReady({ firstName, lastName, avatarUrl }: ProfileReadyProps) {
  const initial = firstName.slice(0, 1).toUpperCase();

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
          Tayyor
        </p>
        <h1 className="text-3xl font-semibold tracking-tight">Xush kelibsiz</h1>
        <p className="text-sm leading-6 text-ink/60">
          {firstName} {lastName}. Keyingi kirishda bu qadam so‘ralmaydi.
        </p>
      </div>
      <div className="flex h-16 w-16 items-center justify-center overflow-hidden rounded-full border border-line bg-white text-lg font-medium">
        {avatarUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={avatarUrl} alt="" className="h-full w-full object-cover" />
        ) : (
          initial
        )}
      </div>
    </div>
  );
}
