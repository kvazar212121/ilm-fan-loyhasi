import type { RoleId } from "@/components/login/roles";

type RoleIconProps = {
  id: RoleId;
};

export function RoleIcon({ id }: RoleIconProps) {
  const props = {
    viewBox: "0 0 24 24",
    className: "h-6 w-6",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.6,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
    "aria-hidden": true as const,
  };

  if (id === "cert-teacher" || id === "guide-teacher") {
    return (
      <svg {...props}>
        <circle cx="7" cy="8" r="2.2" />
        <path d="M3.2 18a4 4 0 0 1 7.6 0" />
        <path d="M14 5.5h7v7h-7z" />
        <path d="M14 9h7" />
      </svg>
    );
  }

  if (id === "pupil") {
    return (
      <svg {...props}>
        <circle cx="12" cy="8" r="3" />
        <path d="M5 19c1.5-3.2 3.9-4.8 7-4.8s5.5 1.6 7 4.8" />
      </svg>
    );
  }

  return (
    <svg {...props}>
      <path d="M3 10 12 6l9 4-9 4-9-4z" />
      <path d="M7.5 12.2V16c1.3 1.2 2.8 1.8 4.5 1.8s3.2-.6 4.5-1.8v-3.8" />
      <path d="M21 10v5" />
    </svg>
  );
}
