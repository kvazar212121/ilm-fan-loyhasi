"use client";

import { useEffect, useSyncExternalStore } from "react";
import { useRouter } from "next/navigation";

import { isTeacherRole } from "@/components/login/roles";
import {
  readStoredProfileRaw,
  subscribeProfileStore,
  type SavedProfile,
} from "@/components/profile/profile-data";
import { StudentProfile } from "@/components/profile/StudentProfile";
import { TeacherProfile } from "@/components/teacher/TeacherProfile";
import { clearStoredProfile, saveBackendUserToProfile } from "@/lib/auth/client";

export function ProfileHome() {
  const router = useRouter();
  const raw = useSyncExternalStore(subscribeProfileStore, readStoredProfileRaw, () => null);
  const profile = raw ? (JSON.parse(raw) as SavedProfile) : null;

  useEffect(() => {
    fetch("/api/auth/me")
      .then(async (r) => {
        if (r.status === 401) {
          clearStoredProfile();
          router.replace("/login");
          return;
        }
        if (r.ok) {
          const data = await r.json().catch(() => null);
          if (data?.user) saveBackendUserToProfile(data.user);
        }
      })
      .catch(() => {});
  }, [router]);

  if (profile && isTeacherRole(profile.role)) {
    return <TeacherProfile profile={profile} />;
  }

  return <StudentProfile profile={profile} />;
}
