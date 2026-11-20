"use client";

import { useSyncExternalStore } from "react";

import { isTeacherRole } from "@/components/login/roles";
import {
  studentProfileKey,
  type SavedProfile,
} from "@/components/profile/profile-data";
import { StudentProfile } from "@/components/profile/StudentProfile";
import { TeacherProfile } from "@/components/teacher/TeacherProfile";

function readSavedProfile() {
  return sessionStorage.getItem(studentProfileKey);
}

export function ProfileHome() {
  const raw = useSyncExternalStore(emptySubscribe, readSavedProfile, emptySnapshot);
  const profile = raw ? (JSON.parse(raw) as SavedProfile) : null;

  if (profile && isTeacherRole(profile.role)) {
    return <TeacherProfile profile={profile} />;
  }

  return <StudentProfile profile={profile} />;
}

function emptySubscribe() {
  return () => {};
}

function emptySnapshot() {
  return null;
}
