import { getRole } from "@/components/login/roles";
import { LinkedMethodsCard } from "@/components/profile/LinkedMethodsCard";
import { MySections } from "@/components/profile/MySections";
import { ProfileBanner } from "@/components/profile/ProfileBanner";
import { ProfileSettings } from "@/components/profile/ProfileSettings";
import type { SavedProfile } from "@/components/profile/profile-data";
import { getTayyorlovFan, titlesForFans } from "@/components/tayyorlov/tayyorlov-fans";

type StudentProfileProps = {
  profile: SavedProfile | null;
};

export function StudentProfile({ profile }: StudentProfileProps) {
  const name = profile ? `${profile.firstName} ${profile.lastName}`.trim() || "O‘quvchi" : "O‘quvchi";
  const roleTitle = getRole(profile?.role)?.title ?? "O‘quvchi";
  const fanTitle =
    profile?.role === "applicant"
      ? titlesForFans(profile.fanIds ?? [])
      : profile?.role === "pupil"
        ? ""
        : (getTayyorlovFan(profile?.fanId ?? "")?.title ?? "");

  return (
    <div className="folio-enter mx-auto w-full max-w-6xl px-6 py-10 sm:py-14">
      <ProfileBanner profile={profile} name={name} roleTitle={roleTitle} fanTitle={fanTitle} />

      <div className="mt-8 grid gap-6 lg:grid-cols-12 lg:items-start">
        <div className="flex flex-col gap-6 lg:col-span-7">
          <ProfileSettings profile={profile} />
          <LinkedMethodsCard profile={profile} />
        </div>
        <aside className="flex flex-col gap-6 lg:col-span-5">
          <MySections />
        </aside>
      </div>
    </div>
  );
}
