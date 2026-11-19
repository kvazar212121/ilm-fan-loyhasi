import type { CourseContentTypeId } from "@/components/teacher/course-content-types";

type ContentTypeIconProps = {
  id: CourseContentTypeId;
};

export function ContentTypeIcon({ id }: ContentTypeIconProps) {
  const props = {
    viewBox: "0 0 24 24",
    className: "h-5 w-5",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.6,
    "aria-hidden": true as const,
  };

  if (id === "video") {
    return (
      <svg {...props}>
        <rect x="3" y="6" width="14" height="12" rx="2" />
        <path d="M17 10l4-2v8l-4-2" />
      </svg>
    );
  }

  if (id === "text") {
    return (
      <svg {...props}>
        <path d="M6 6h12M6 10h12M6 14h8M6 18h6" />
      </svg>
    );
  }

  if (id === "voice") {
    return (
      <svg {...props}>
        <path d="M8 18V6l4-2v16l-4-2z" />
        <path d="M16 10v4a4 4 0 0 1-8 0" />
      </svg>
    );
  }

  if (id === "test") {
    return (
      <svg {...props}>
        <path d="M7 4h10v16H7z" />
        <path d="M10 8h4M10 12h4M10 16h2" />
      </svg>
    );
  }

  if (id === "image") {
    return (
      <svg {...props}>
        <rect x="4" y="5" width="16" height="14" rx="2" />
        <circle cx="9" cy="10" r="1.5" />
        <path d="M4 16l5-4 4 3 3-2 4 3" />
      </svg>
    );
  }

  if (id === "presentation") {
    return (
      <svg {...props}>
        <rect x="3" y="4" width="18" height="13" rx="2" />
        <path d="M8 20h8" />
        <path d="M12 17v3" />
      </svg>
    );
  }

  if (id === "word") {
    return (
      <svg {...props}>
        <path d="M7 4h7l4 4v12H7z" />
        <path d="M14 4v4h4" />
        <path d="M10 12h6M10 16h4" />
      </svg>
    );
  }

  if (id === "excel") {
    return (
      <svg {...props}>
        <rect x="5" y="4" width="14" height="16" rx="2" />
        <path d="M9 8h6v8H9z" />
        <path d="M9 12h6M12 8v8" />
      </svg>
    );
  }

  return (
    <svg {...props}>
      <path d="M7 4h7l4 4v12H7z" />
      <path d="M14 4v4h4" />
      <path d="M10 14h4" />
    </svg>
  );
}