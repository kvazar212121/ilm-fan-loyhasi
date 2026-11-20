import type { Metadata } from "next";
import { connection } from "next/server";
import { Suspense } from "react";

import { AdminFrame } from "@/components/admin/AdminFrame";
import { AdminLogin } from "@/components/admin/AdminLogin";
import { DashboardCards } from "@/components/admin/DashboardCards";
import { isAdmin } from "@/lib/admin/auth";
import { readCatalog } from "@/lib/admin/store";

export const metadata: Metadata = {
  title: "Boshqaruv",
  robots: { index: false, follow: false },
};

export default function AdminPage() {
  return (
    <Suspense fallback={<AdminFrame><p className="text-sm text-ink/60">Yuklanmoqda</p></AdminFrame>}>
      <AdminHome />
    </Suspense>
  );
}

async function AdminHome() {
  await connection();
  if (!(await isAdmin())) return <AdminLogin />;
  return (
    <AdminFrame>
      <DashboardCards catalog={await readCatalog()} />
    </AdminFrame>
  );
}
