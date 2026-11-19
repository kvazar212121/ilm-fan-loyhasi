import type { Metadata } from "next";

import { LoginFlow } from "@/components/login/LoginFlow";

export const metadata: Metadata = {
  title: "Kirish",
};

export default function LoginPage() {
  return <LoginFlow />;
}
