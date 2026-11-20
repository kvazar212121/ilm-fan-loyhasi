import type { Metadata } from "next";
import { connection } from "next/server";
import { Suspense } from "react";

import { AdminFrame } from "@/components/admin/AdminFrame";
import { AdminLogin } from "@/components/admin/AdminLogin";
import { PeoplePanel } from "@/components/admin/PeoplePanel";
import { isAdmin } from "@/lib/admin/auth";
import { readCatalog } from "@/lib/admin/store";

export const metadata: Metadata = {
  title: "Odamlar",
  robots: { index: false, follow: false },
};

export default function PeoplePage() {
  return (
    <Suspense fallback={<AdminFrame><p className="text-sm text-ink/60">Yuklanmoqda</p></AdminFrame>}>
      <PeopleBody />
    </Suspense>
  );
}

async function PeopleBody() {
  await connection();
  if (!(await isAdmin())) return <AdminLogin />;
  const catalog = await readCatalog();
  return (
    <AdminFrame>
      <PeoplePanel people={catalog.people} />
    </AdminFrame>
  );
}
