import { CourseBasicsForm } from "@/components/teacher/CourseBasicsForm";
import { CourseLessonPlanner } from "@/components/teacher/CourseLessonPlanner";
import { TeacherPageHeader } from "@/components/teacher/TeacherPageHeader";

export function CourseCreateShell() {
  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-8 px-6 py-12">
      <TeacherPageHeader
        title="Kurs yaratish"
        subtitle="Darslarga bo‘ling: video, matn, ovoz, test va boshqa materiallar."
      />
      <CourseBasicsForm />
      <CourseLessonPlanner />
    </div>
  );
}