import { MyCourses } from "@/components/teacher/MyCourses";
import { MyReels } from "@/components/teacher/MyReels";
import { TeacherQuickActions } from "@/components/teacher/TeacherQuickActions";
import type { SavedProfile } from "@/components/profile/profile-data";

type TeacherProfileProps = {
  profile: SavedProfile;
};

export function TeacherProfile({ profile }: TeacherProfileProps) {
  const name = `${profile.firstName} ${profile.lastName}`;

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-6 py-12">
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium tracking-[0.16em] text-accent uppercase">
          O‘qituvchi
        </p>
        <h1 className="text-3xl font-semibold tracking-tight">{name}</h1>
      </div>
      <div className="grid gap-3 sm:grid-cols-2">
        <MyCourses />
        <MyReels />
      </div>
      <TeacherQuickActions />
    </div>
  );
}