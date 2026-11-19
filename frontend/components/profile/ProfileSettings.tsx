import type { StudentProfileData } from "@/components/profile/profile-data";

type ProfileSettingsProps = {
  profile: StudentProfileData | null;
};

export function ProfileSettings({ profile }: ProfileSettingsProps) {
  const initial = profile?.firstName.slice(0, 1).toUpperCase() ?? "?";

  return (
    <section className="rounded-2xl border border-line bg-white p-5">
      <h2 className="text-lg font-semibold">Profil sozlamalari</h2>
      <div className="mt-4 flex items-center gap-4">
        <div className="flex h-14 w-14 items-center justify-center overflow-hidden rounded-full border border-line bg-paper text-lg font-medium">
          {profile?.avatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={profile.avatarUrl} alt="" className="h-full w-full object-cover" />
          ) : (
            initial
          )}
        </div>
        <div className="text-sm leading-6 text-ink/70">
          <p>Ism: {profile?.firstName ?? "—"}</p>
          <p>Familiya: {profile?.lastName ?? "—"}</p>
        </div>
      </div>
    </section>
  );
}
