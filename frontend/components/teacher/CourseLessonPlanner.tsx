"use client";

import { useState } from "react";

import { CourseLessonCard } from "@/components/teacher/CourseLessonCard";
import { newLesson, type LessonPlan } from "@/components/teacher/lesson-plan";

export function CourseLessonPlanner() {
  const [lessons, setLessons] = useState<LessonPlan[]>([newLesson(1)]);

  function addLesson() {
    setLessons((current) => [...current, newLesson(current.length + 1)]);
  }

  function patchLesson(id: string, next: LessonPlan) {
    setLessons((current) => current.map((item) => (item.id === id ? next : item)));
  }

  function removeLesson(id: string) {
    setLessons((current) => current.filter((item) => item.id !== id));
  }

  function moveLesson(id: string, dir: -1 | 1) {
    setLessons((current) => {
      const list = [...current];
      const at = list.findIndex((item) => item.id === id);
      const swap = at + dir;
      if (at < 0 || swap < 0 || swap >= list.length) {
        return current;
      }
      [list[at], list[swap]] = [list[swap], list[at]];
      return list;
    });
  }

  return (
    <section className="flex flex-col gap-4">
      <div>
        <h2 className="text-lg font-semibold">Darslar rejasi</h2>
        <p className="text-sm leading-6 text-ink/60">
          Kursni darslarga bo‘ling. Har darsda material tartibini oldindan rejalashtiring.
        </p>
      </div>
      <ul className="flex flex-col gap-4">
        {lessons.map((lesson, index) => (
          <li key={lesson.id}>
            <CourseLessonCard
              lesson={lesson}
              index={index}
              onChange={(next) => patchLesson(lesson.id, next)}
              onRemove={() => removeLesson(lesson.id)}
              onMove={(dir) => moveLesson(lesson.id, dir)}
              canMoveUp={index > 0}
              canMoveDown={index < lessons.length - 1}
            />
          </li>
        ))}
      </ul>
      <button
        type="button"
        onClick={addLesson}
        className="w-fit rounded-full bg-accent px-5 py-3 text-sm font-medium text-white"
      >
        Dars qo‘shish
      </button>
    </section>
  );
}