import { TeacherPageHeader } from "@/components/teacher/TeacherPageHeader";
import { PaperTest } from "@/components/teacher/PaperTest";

export function TestCreateShell() {
  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-8 px-6 py-12">
      <TeacherPageHeader
        title="Test yaratish"
        subtitle="O‘quvchi uchun qog‘ozga chiqadigan test."
      />
      <PaperTest />
    </div>
  );
}