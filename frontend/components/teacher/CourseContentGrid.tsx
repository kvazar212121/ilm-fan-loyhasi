import { courseContentTypes } from "@/components/teacher/course-content-types";
import { CourseContentUpload } from "@/components/teacher/CourseContentUpload";

export function CourseContentGrid() {
  return (
    <section className="flex flex-col gap-3">
      <div>
        <h2 className="text-lg font-semibold">Kurs materiallari</h2>
        <p className="text-sm leading-6 text-ink/60">
          Yuklangan fayllar kurs ochilganda o‘quvchiga shu formatda ko‘rsatiladi.
        </p>
      </div>
      <ul className="grid gap-3 sm:grid-cols-2">
        {courseContentTypes.map((item) => (
          <li key={item.id}>
            <CourseContentUpload typeId={item.id} />
          </li>
        ))}
      </ul>
    </section>
  );
}