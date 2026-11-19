import { MySections } from "@/components/profile/MySections";
import { ProfileSettings } from "@/components/profile/ProfileSettings";
import type { StudentProfileData } from "@/components/profile/profile-data";

type StudentProfileProps = {
  profile: StudentProfileData | null;
};

export function StudentProfile({ profile }: StudentProfileProps) {
  const name = profile ? `${profile.firstName} ${profile.lastName}` : "O‘quvchi";

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-12">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
          O‘quvchi
        </p>
        <h1 className="text-3xl font-semibold tracking-tight">{name}</h1>
      </div>
      <MySections />
      <ProfileSettings profile={profile} />
    </div>
  );
}
