import type { Metadata } from "next";
import { connection } from "next/server";
import { Suspense } from "react";

import { AdminFrame } from "@/components/admin/AdminFrame";
import { AdminLogin } from "@/components/admin/AdminLogin";
import { MaterialPanel } from "@/components/admin/MaterialPanel";
import { isAdmin } from "@/lib/admin/auth";
import { readCatalog } from "@/lib/admin/store";

export const metadata: Metadata = {
  title: "Materiallar",
  robots: { index: false, follow: false },
};

export default function MaterialsPage() {
  return (
    <Suspense fallback={<AdminFrame><p className="text-sm text-ink/60">Yuklanmoqda</p></AdminFrame>}>
      <MaterialsBody />
    </Suspense>
  );
}

async function MaterialsBody() {
  await connection();
  if (!(await isAdmin())) return <AdminLogin />;
  const catalog = await readCatalog();
  return (
    <AdminFrame>
      <MaterialPanel items={catalog.items} />
    </AdminFrame>
  );
}
