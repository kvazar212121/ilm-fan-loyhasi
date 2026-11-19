import type { Metadata } from "next";

import { CourseCreateShell } from "@/components/teacher/CourseCreateShell";

export const metadata: Metadata = {
  title: "Kurs yaratish",
};

export default function CourseCreatePage() {
  return <CourseCreateShell />;
}