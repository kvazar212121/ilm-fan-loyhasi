import { Suspense } from "react";
import type { Metadata } from "next";

import { LoginFlow } from "@/components/login/LoginFlow";

export const metadata: Metadata = {
  title: "Kirish",
};

export default function LoginPage() {
  return (
    <Suspense fallback={null}>
      <LoginFlow />
    </Suspense>
  );
}
