"use client";

import Link from "next/link";

import { courseContentTypes } from "@/components/teacher/course-content-types";
import type { LessonBlock } from "@/components/teacher/lesson-plan";

type LessonBlockItemProps = {
  block: LessonBlock;
  onChange: (next: LessonBlock) => void;
  onRemove: () => void;
  onMove: (dir: -1 | 1) => void;
  canMoveUp: boolean;
  canMoveDown: boolean;
};

export function LessonBlockItem({
  block,
  onChange,
  onRemove,
  onMove,
  canMoveUp,
  canMoveDown,
}: LessonBlockItemProps) {
  const meta = courseContentTypes.find((item) => item.id === block.typeId);
  const title = meta?.title ?? block.typeId;

  function onFile(name: string | undefined) {
    if (!name) {
      return;
    }
    onChange({ ...block, fileName: name });
  }

  return (
    <li className="rounded-xl border border-line bg-paper p-3">
      <p className="text-sm font-medium">{title}</p>
      <textarea
        value={block.note}
        onChange={(event) => onChange({ ...block, note: event.target.value })}
        placeholder="Reja: nima bo‘ladi, qanday tushuntirasiz"
        rows={2}
        className="mt-2 w-full resize-none rounded-xl border border-line bg-white px-3 py-2 text-sm outline-none focus:border-accent"
      />
      {block.typeId === "test" ? (
        <Link
          href="/profile/tests/create"
          className="mt-2 inline-flex text-xs font-medium text-accent"
        >
          Test tuzish sahifasi
        </Link>
      ) : null}
      {meta?.accept ? (
        <label className="mt-2 inline-flex cursor-pointer text-xs font-medium text-accent">
          Fayl tanlash
          <input
            type="file"
            accept={meta.accept}
            className="sr-only"
            onChange={(event) => onFile(event.target.files?.[0]?.name)}
          />
        </label>
      ) : null}
      {block.fileName ? (
        <p className="mt-1 truncate text-xs text-ink/55">{block.fileName}</p>
      ) : null}
      <div className="mt-2 flex flex-wrap gap-2">
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
    </li>
  );
}