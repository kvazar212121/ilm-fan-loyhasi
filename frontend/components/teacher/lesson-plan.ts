import type { CourseContentTypeId } from "@/components/teacher/course-content-types";

export type LessonBlock = {
  id: string;
  typeId: CourseContentTypeId;
  note: string;
  fileName: string | null;
};

export type LessonPlan = {
  id: string;
  title: string;
  blocks: LessonBlock[];
};

export function newLesson(order: number): LessonPlan {
  return {
    id: crypto.randomUUID(),
    title: `${order}-dars`,
    blocks: [],
  };
}

export function newBlock(typeId: CourseContentTypeId): LessonBlock {
  return {
    id: crypto.randomUUID(),
    typeId,
    note: "",
    fileName: null,
  };
}