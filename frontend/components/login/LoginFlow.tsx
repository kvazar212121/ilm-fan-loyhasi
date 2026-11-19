"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { MethodList, type LoginMethodId } from "@/components/login/MethodList";
import { ProfileForm } from "@/components/login/ProfileForm";
import { ProfileReady } from "@/components/login/ProfileReady";
import { RolePicker } from "@/components/login/RolePicker";
import { roles, type RoleId } from "@/components/login/roles";
import { studentProfileKey } from "@/components/profile/profile-data";

type Profile = {
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
};

export function LoginFlow() {
  const [roleId, setRoleId] = useState<RoleId | null>(null);
  const [methodId, setMethodId] = useState<LoginMethodId | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const router = useRouter();
  const role = roles.find((item) => item.id === roleId);

  function onSave(next: Profile) {
    if (roleId === "pupil" || roleId === "teacher") {
      sessionStorage.setItem(
        studentProfileKey,
        JSON.stringify({ ...next, role: roleId }),
      );
      router.push("/profile");
      return;
    }
    setProfile(next);
  }

  const wide = !role;

  return (
    <section
      className={`mx-auto flex w-full flex-1 flex-col justify-center px-6 py-16 ${wide ? "max-w-3xl" : "max-w-md"}`}
    >
      {profile ? (
        <ProfileReady {...profile} />
      ) : methodId ? (
        <ProfileForm onBack={() => setMethodId(null)} onSave={onSave} />
      ) : role ? (
        <MethodList
          role={role}
          onBack={() => setRoleId(null)}
          onSelect={setMethodId}
        />
      ) : (
        <RolePicker onSelect={setRoleId} />
      )}
    </section>
  );
}
