import { ReelRules } from "@/components/reels/ReelRules";
import { ReelUploadForm } from "@/components/reels/ReelUploadForm";
import { TeacherPageHeader } from "@/components/teacher/TeacherPageHeader";

export function ReelCreateShell() {
  return (
    <div className="mx-auto flex w-full max-w-2xl flex-col gap-8 px-6 py-12">
      <TeacherPageHeader
        title="Reel joylash"
        subtitle="Qisqa o‘quv videosi. 2 daqiqa, format va siqish alohida qadamda."
      />
      <ReelRules />
      <ReelUploadForm />
    </div>
  );
}