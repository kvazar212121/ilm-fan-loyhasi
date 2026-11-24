"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";

import { FanPicker } from "@/components/login/FanPicker";
import { LoginShell } from "@/components/login/LoginShell";
import { MethodList, type LoginMethodId } from "@/components/login/MethodList";
import { PhoneOtpStep } from "@/components/login/PhoneOtpStep";
import { ProfileForm, type ProfileDraft } from "@/components/login/ProfileForm";
import { RolePicker } from "@/components/login/RolePicker";
import { TelegramStep } from "@/components/login/TelegramStep";
import { getRole, type RoleId } from "@/components/login/roles";
import { saveBackendUserToProfile, type BackendUser } from "@/lib/auth/client";

type Prefill = {
  method?: string;
  phone?: string;
  phone_verified?: boolean;
  first_name?: string;
  last_name?: string;
  avatar_url?: string;
};
type StepMode = "method" | "telegram" | "phone" | "register";

export function LoginFlow() {
  const router = useRouter();
  const params = useSearchParams();
  const [step, setStep] = useState<StepMode>(() =>
    params.get("step") === "register" ? "register" : "method",
  );
  const [draft, setDraft] = useState<ProfileDraft | null>(null);
  const [roleId, setRoleId] = useState<RoleId | null>(null);
  const [prefill, setPrefill] = useState<Prefill>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(() => params.get("error"));

  const role = getRole(roleId);
  const fanMode = role?.fanMode ?? "none";

  const finishLogin = useCallback(
    (user: BackendUser) => {
      saveBackendUserToProfile(user);
      router.push("/profile");
    },
    [router],
  );

  const loadRegistrationPrefill = useCallback(async () => {
    const res = await fetch("/api/auth/registration/inspect");
    if (res.ok) {
      const data = await res.json().catch(() => ({}));
      setPrefill(data);
    }
    setDraft(null);
    setRoleId(null);
    setStep("register");
  }, []);

  useEffect(() => {
    if (params.get("auth") === "done") {
      fetch("/api/auth/me")
        .then((r) => (r.ok ? r.json() : null))
        .then((data) => {
          if (data?.user) finishLogin(data.user);
          else setError("Sessiyani yuklab bo‘lmadi, qayta urining.");
        });
    } else if (params.get("step") === "register") {
      loadRegistrationPrefill();
    }
  }, [params, finishLogin, loadRegistrationPrefill]);

  async function onSelectMethod(method: LoginMethodId) {
    setError(null);
    if (method === "google") {
      setBusy(true);
      try {
        const res = await fetch("/api/auth/google/start", { method: "POST" });
        const data = await res.json().catch(() => ({}));
        if (!res.ok || !data.authorization_url) {
          setError(data.message || "Google kirishni boshlab bo‘lmadi");
          return;
        }
        window.location.href = data.authorization_url;
      } finally {
        setBusy(false);
      }
      return;
    }
    setStep(method === "telegram" ? "telegram" : "phone");
  }

  async function submitRegistration(profile: ProfileDraft, chosenRole: RoleId, chosenFans: string[]) {
    setError(null);
    setBusy(true);
    try {
      const avatar = profile.avatarUrl?.startsWith("http") ? profile.avatarUrl : "";
      const res = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          role: chosenRole,
          fan_ids: chosenFans,
          first_name: profile.firstName,
          last_name: profile.lastName,
          phone: profile.phone,
          birth_date: profile.birthDate,
          region: profile.region,
          gender: profile.gender,
          avatar_url: avatar,
        }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.user) {
        setError(data.message || "Ro‘yxatdan o‘tishda xatolik");
        return;
      }
      finishLogin(data.user);
    } finally {
      setBusy(false);
    }
  }

  function onSelectRole(nextRole: RoleId) {
    if (!draft) return;
    const chosen = getRole(nextRole);
    if (chosen?.fanMode === "none") {
      submitRegistration(draft, nextRole, []);
      return;
    }
    setRoleId(nextRole);
  }

  const phoneVerified = Boolean(prefill.phone_verified || (prefill.phone && prefill.method === "phone"));
  const activeStep: 1 | 2 | 3 | 4 = step !== "register" ? 1 : !draft ? 2 : !role ? 3 : 4;

  return (
    <LoginShell activeStep={activeStep} showProgress={step === "register"}>
      {error && (step === "method" || Boolean(draft)) ? (
        <p className="mb-5 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">{error}</p>
      ) : null}

      {step === "method" ? (
        <div className={busy ? "pointer-events-none opacity-60" : ""}>
          <MethodList
            onSelect={onSelectMethod}
            onQrAuthenticated={finishLogin}
            onQrRegistrationRequired={loadRegistrationPrefill}
          />
        </div>
      ) : step === "phone" ? (
        <PhoneOtpStep
          onBack={() => setStep("method")}
          onAuthenticated={finishLogin}
          onRegistrationRequired={loadRegistrationPrefill}
        />
      ) : step === "telegram" ? (
        <TelegramStep
          onBack={() => setStep("method")}
          onAuthenticated={finishLogin}
          onRegistrationRequired={loadRegistrationPrefill}
        />
      ) : !draft ? (
        <ProfileForm
          key={`${prefill.first_name || ""}-${prefill.last_name || ""}-${prefill.phone || ""}-${phoneVerified}`}
          backLabel="← Kirish usuli"
          initialFirstName={prefill.first_name || ""}
          initialLastName={prefill.last_name || ""}
          initialPhone={prefill.phone || ""}
          phoneVerified={phoneVerified}
          initialAvatarUrl={prefill.avatar_url || null}
          error={error}
          onBack={() => setStep("method")}
          onAuthenticated={finishLogin}
          onSave={(next) => {
            setError(null);
            setDraft(next);
          }}
        />
      ) : !role ? (
        <RolePicker disabled={busy} onBack={() => setDraft(null)} onSelect={onSelectRole} />
      ) : (
        <FanPicker
          mode={fanMode === "many" ? "many" : "one"}
          submitting={busy}
          onBack={() => setRoleId(null)}
          onSelect={(fans) => submitRegistration(draft, role.id, fans)}
        />
      )}
    </LoginShell>
  );
}
