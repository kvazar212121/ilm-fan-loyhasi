import { getRole } from "@/components/login/roles";
import { MySections } from "@/components/profile/MySections";
import { ProfileSettings } from "@/components/profile/ProfileSettings";
import type { SavedProfile } from "@/components/profile/profile-data";
import { getTayyorlovFan, titlesForFans } from "@/components/tayyorlov/tayyorlov-fans";

type StudentProfileProps = {
  profile: SavedProfile | null;
};

export function StudentProfile({ profile }: StudentProfileProps) {
  const name = profile ? `${profile.firstName} ${profile.lastName}` : "O‘quvchi";
  const roleTitle = getRole(profile?.role)?.title ?? "O‘quvchi";
  const fanTitle =
    profile?.role === "applicant"
      ? titlesForFans(profile.fanIds ?? [])
      : profile?.role === "pupil"
        ? ""
        : (getTayyorlovFan(profile?.fanId ?? "")?.title ?? "");

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-12">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
          {roleTitle}
          {fanTitle ? ` · ${fanTitle}` : ""}
        </p>
        <h1 className="text-3xl font-semibold tracking-tight">{name}</h1>
      </div>
      <MySections />
      <ProfileSettings profile={profile} />
    </div>
  );
}
