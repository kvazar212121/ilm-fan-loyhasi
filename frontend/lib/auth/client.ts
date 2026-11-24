import {
  notifyProfileSaved,
  studentProfileKey,
  type SavedProfile,
} from "@/components/profile/profile-data";

export type BackendUser = {
  id: number;
  first_name: string;
  last_name?: string | null;
  role?: string;
  fan_ids?: string[];
  avatar_url?: string | null;
  phone?: string | null;
  email?: string | null;
  birth_date?: string | null;
  region?: string | null;
  gender?: "male" | "female" | null;
};

export function backendRoleToWebRole(role?: string): SavedProfile["role"] {
  switch (role) {
    case "teacher":
    case "cert-teacher":
      return "cert-teacher";
    case "teacherMaterials":
    case "guide-teacher":
      return "guide-teacher";
    case "student":
    case "applicant":
    case "universityStudent":
      return "applicant";
    case "schoolStudent":
    case "pupil":
      return "pupil";
    default:
      return "pupil";
  }
}

export function saveBackendUserToProfile(user: BackendUser) {
  if (typeof window === "undefined") return;
  const webRole = backendRoleToWebRole(user.role);
  const fanIds = Array.isArray(user.fan_ids) ? user.fan_ids : [];
  const profile: SavedProfile = {
    firstName: user.first_name || "",
    lastName: user.last_name || "",
    avatarUrl: user.avatar_url || null,
    phone: user.phone || null,
    email: user.email || null,
    birthDate: user.birth_date || null,
    region: user.region || null,
    gender: user.gender || null,
    role: webRole,
    ...(fanIds.length === 1 && (webRole === "cert-teacher" || webRole === "guide-teacher")
      ? { fanId: fanIds[0] }
      : {}),
    ...(fanIds.length > 0 ? { fanIds } : {}),
  };
  sessionStorage.setItem(studentProfileKey, JSON.stringify(profile));
  notifyProfileSaved();
}

export function clearStoredProfile() {
  if (typeof window === "undefined") return;
  sessionStorage.removeItem(studentProfileKey);
  notifyProfileSaved();
}

export async function logoutFromProfile() {
  try {
    await fetch("/api/auth/logout", { method: "POST" });
  } finally {
    clearStoredProfile();
  }
}
