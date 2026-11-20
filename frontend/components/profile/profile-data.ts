export type StudentProfileData = {
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
};

export type SavedProfile = StudentProfileData & {
  role?: "cert-teacher" | "guide-teacher" | "applicant" | "pupil" | "teacher" | "student";
  fanId?: string;
  fanIds?: string[];
};

export const studentProfileKey = "ilm-fan-student";
export const profileChangeEvent = "ilm-fan-profile-change";

export function readStoredProfileRaw(): string | null {
  if (typeof window === "undefined") return null;
  return sessionStorage.getItem(studentProfileKey);
}

export function notifyProfileSaved() {
  if (typeof window !== "undefined") {
    window.dispatchEvent(new Event(profileChangeEvent));
  }
}

export function subscribeProfileStore(onChange: () => void) {
  const handler = () => onChange();
  window.addEventListener(profileChangeEvent, handler);
  window.addEventListener("storage", handler);
  return () => {
    window.removeEventListener(profileChangeEvent, handler);
    window.removeEventListener("storage", handler);
  };
}
