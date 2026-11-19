"use client";

import { LessonBlockItem } from "@/components/teacher/LessonBlockItem";
import { LessonMaterialMenu } from "@/components/teacher/LessonMaterialMenu";
import type { CourseContentTypeId } from "@/components/teacher/course-content-types";
import { newBlock, type LessonPlan } from "@/components/teacher/lesson-plan";

type CourseLessonCardProps = {
  lesson: LessonPlan;
  index: number;
  onChange: (next: LessonPlan) => void;
  onRemove: () => void;
  onMove: (dir: -1 | 1) => void;
  canMoveUp: boolean;
  canMoveDown: boolean;
};

export function CourseLessonCard({
  lesson,
  index,
  onChange,
  onRemove,
  onMove,
  canMoveUp,
  canMoveDown,
}: CourseLessonCardProps) {
  function addBlock(typeId: CourseContentTypeId) {
    onChange({ ...lesson, blocks: [...lesson.blocks, newBlock(typeId)] });
  }

  function patchBlock(id: string, next: (typeof lesson.blocks)[number]) {
    onChange({
      ...lesson,
      blocks: lesson.blocks.map((item) => (item.id === id ? next : item)),
    });
  }

  function removeBlock(id: string) {
    onChange({ ...lesson, blocks: lesson.blocks.filter((item) => item.id !== id) });
  }

  function moveBlock(id: string, dir: -1 | 1) {
    const list = [...lesson.blocks];
    const at = list.findIndex((item) => item.id === id);
    const swap = at + dir;
    if (at < 0 || swap < 0 || swap >= list.length) {
      return;
    }
    [list[at], list[swap]] = [list[swap], list[at]];
    onChange({ ...lesson, blocks: list });
  }

  return (
    <article className="rounded-2xl border border-line bg-white p-5">
      <div className="flex flex-wrap items-center gap-2">
        <span className="text-xs font-medium text-accent">Dars {index + 1}</span>
        <input
          value={lesson.title}
          onChange={(event) => onChange({ ...lesson, title: event.target.value })}
          className="min-w-[10rem] flex-1 rounded-xl border border-line px-3 py-2 text-sm outline-none focus:border-accent"
        />
        <button
          type="button"
          disabled={!canMoveUp}
          onClick={() => onMove(-1)}
          className="rounded-full border border-line px-2 py-1 text-xs disabled:opacity-40"
        >
          ↑
        </button>
        <button
          type="button"
          disabled={!canMoveDown}
          onClick={() => onMove(1)}
          className="rounded-full border border-line px-2 py-1 text-xs disabled:opacity-40"
        >
          ↓
        </button>
        <button
          type="button"
          onClick={onRemove}
          className="rounded-full border border-line px-2 py-1 text-xs"
        >
          O‘chirish
        </button>
      </div>
      <p className="mt-3 text-sm text-ink/60">
        Har bir qism: video, matn, ovoz, test va boshqa fayllar. Tartibni ↑↓ bilan o‘zgartiring.
      </p>
      <div className="mt-4">
        <LessonMaterialMenu onPick={addBlock} />
      </div>
      {lesson.blocks.length === 0 ? (
        <p className="mt-4 text-sm text-ink/55">Hozircha material yo‘q.</p>
      ) : (
        <ul className="mt-4 flex flex-col gap-2">
          {lesson.blocks.map((block, blockIndex) => (
            <LessonBlockItem
              key={block.id}
              block={block}
              onChange={(next) => patchBlock(block.id, next)}
              onRemove={() => removeBlock(block.id)}
              onMove={(dir) => moveBlock(block.id, dir)}
              canMoveUp={blockIndex > 0}
              canMoveDown={blockIndex < lesson.blocks.length - 1}
            />
          ))}
        </ul>
      )}
    </article>
  );
}