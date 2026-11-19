import type { Metadata } from "next";

import { TestCreateShell } from "@/components/teacher/TestCreateShell";

export const metadata: Metadata = {
  title: "Test yaratish",
};

export default function TestCreatePage() {
  return <TestCreateShell />;
}