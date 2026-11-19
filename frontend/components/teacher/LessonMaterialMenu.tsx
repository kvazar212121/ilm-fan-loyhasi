import {
  courseContentTypes,
  type CourseContentTypeId,
} from "@/components/teacher/course-content-types";

type LessonMaterialMenuProps = {
  onPick: (typeId: CourseContentTypeId) => void;
};

export function LessonMaterialMenu({ onPick }: LessonMaterialMenuProps) {
  return (
    <p className="flex flex-wrap gap-2">
      {courseContentTypes.map((item) => (
        <button
          key={item.id}
          type="button"
          onClick={() => onPick(item.id)}
          className="rounded-full border border-line bg-white px-3 py-1.5 text-xs font-medium"
        >
          + {item.title}
        </button>
      ))}
    </p>
  );
}