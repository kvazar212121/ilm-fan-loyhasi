"use client";

import Link from "next/link";
import { useId, useState } from "react";

import {
  courseContentTypes,
  type CourseContentTypeId,
} from "@/components/teacher/course-content-types";
import { ContentTypeIcon } from "@/components/teacher/ContentTypeIcon";

type CourseContentUploadProps = {
  typeId: CourseContentTypeId;
};

export function CourseContentUpload({ typeId }: CourseContentUploadProps) {
  const inputId = useId();
  const [fileName, setFileName] = useState<string | null>(null);
  const item = courseContentTypes.find((entry) => entry.id === typeId);

  if (!item) {
    return null;
  }

  return (
    <article className="flex h-full flex-col rounded-2xl border border-line bg-white p-4">
      <div className="flex items-center gap-2 text-accent">
        <ContentTypeIcon id={typeId} />
        <h3 className="text-base font-semibold text-ink">{item.title}</h3>
      </div>
      <p className="mt-2 flex-1 text-sm leading-6 text-ink/60">{item.text}</p>
      {typeId === "test" ? (
        <Link
          href="/profile/tests/create"
          className="mt-4 w-fit rounded-full border border-line px-4 py-2 text-sm font-medium"
        >
          {item.button}
        </Link>
      ) : (
        <label
          htmlFor={inputId}
          className="mt-4 w-fit cursor-pointer rounded-full border border-line px-4 py-2 text-sm font-medium"
        >
          {item.button}
        </label>
      )}
      {item.accept ? (
        <input
          id={inputId}
          type="file"
          accept={item.accept}
          className="sr-only"
          onChange={(event) => setFileName(event.target.files?.[0]?.name ?? null)}
        />
      ) : null}
      {fileName ? (
        <p className="mt-2 truncate text-xs text-ink/55">Tanlandi: {fileName}</p>
      ) : null}
    </article>
  );
}