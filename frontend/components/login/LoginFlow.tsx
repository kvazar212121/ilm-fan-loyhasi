"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { FanPicker } from "@/components/login/FanPicker";
import { MethodList, type LoginMethodId } from "@/components/login/MethodList";
import { ProfileForm } from "@/components/login/ProfileForm";
import { RolePicker } from "@/components/login/RolePicker";
import { getRole, type RoleId } from "@/components/login/roles";
import { notifyProfileSaved, studentProfileKey } from "@/components/profile/profile-data";

type Profile = {
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
};

export function LoginFlow() {
  const [roleId, setRoleId] = useState<RoleId | null>(null);
  const [fanIds, setFanIds] = useState<string[]>([]);
  const [methodId, setMethodId] = useState<LoginMethodId | null>(null);
  const router = useRouter();
  const role = getRole(roleId);
  const fanMode = role?.fanMode ?? "none";
  const fansReady = Boolean(role) && (fanMode === "none" || fanIds.length > 0);
  const wide = Boolean(methodId && !fansReady);

  function chooseRole(next: RoleId) {
    setRoleId(next);
    setFanIds([]);
  }

  function onSave(next: Profile) {
    if (!roleId || !role || !fansReady) return;
    sessionStorage.setItem(
      studentProfileKey,
      JSON.stringify({
        ...next,
        role: roleId,
        ...(fanMode === "one" ? { fanId: fanIds[0] } : {}),
        ...(fanMode === "many" ? { fanIds } : {}),
      }),
    );
    notifyProfileSaved();
    router.push("/profile");
  }

  return (
    <section
      className={`mx-auto flex w-full flex-1 flex-col justify-center px-6 py-16 ${wide ? "max-w-3xl" : "max-w-md"}`}
    >
      {!methodId ? (
        <MethodList onSelect={setMethodId} />
      ) : !role ? (
        <RolePicker onBack={() => setMethodId(null)} onSelect={chooseRole} />
      ) : !fansReady ? (
        <FanPicker
          mode={fanMode === "many" ? "many" : "one"}
          onBack={() => setRoleId(null)}
          onSelect={setFanIds}
        />
      ) : (
        <ProfileForm
          step={fanMode === "none" ? "3-qadam" : "4-qadam"}
          backLabel={
            fanMode === "none"
              ? "← Rolni o‘zgartirish"
              : fanMode === "many"
                ? "← Fanlarni o‘zgartirish"
                : "← Fanni o‘zgartirish"
          }
          onBack={() => (fanMode === "none" ? setRoleId(null) : setFanIds([]))}
          onSave={onSave}
        />
      )}
    </section>
  );
}
