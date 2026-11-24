import { getRole } from "@/components/login/roles";
import { LinkedMethodsCard } from "@/components/profile/LinkedMethodsCard";
import { ProfileBanner } from "@/components/profile/ProfileBanner";
import { ProfileSettings } from "@/components/profile/ProfileSettings";
import type { SavedProfile } from "@/components/profile/profile-data";
import { getTayyorlovFan } from "@/components/tayyorlov/tayyorlov-fans";
import { MyCourses } from "@/components/teacher/MyCourses";
import { MyReels } from "@/components/teacher/MyReels";
import { TeacherQuickActions } from "@/components/teacher/TeacherQuickActions";

type TeacherProfileProps = {
  profile: SavedProfile;
};

export function TeacherProfile({ profile }: TeacherProfileProps) {
  const name = `${profile.firstName} ${profile.lastName}`.trim() || "O‘qituvchi";
  const roleTitle = getRole(profile.role)?.title ?? "O‘qituvchi";
  const fanTitle = getTayyorlovFan(profile.fanId ?? "")?.title;

  return (
    <div className="folio-enter mx-auto w-full max-w-6xl px-6 py-10 sm:py-14">
      <ProfileBanner profile={profile} name={name} roleTitle={roleTitle} fanTitle={fanTitle} />

      <div className="mt-8 grid gap-6 lg:grid-cols-12 lg:items-start">
        <div className="flex flex-col gap-6 lg:col-span-7">
          <ProfileSettings profile={profile} />
          <LinkedMethodsCard profile={profile} />
        </div>
        <aside className="flex flex-col gap-6 lg:col-span-5">
          <TeacherQuickActions />
          <MyCourses />
          <MyReels />
        </aside>
      </div>
    </div>
  );
}
