export type StudentProfileData = {
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
};

export type SavedProfile = StudentProfileData & {
  role?: "teacher" | "pupil" | "student";
};

export const studentProfileKey = "ilm-fan-student";
