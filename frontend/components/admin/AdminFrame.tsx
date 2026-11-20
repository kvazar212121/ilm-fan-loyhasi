import type { ReactNode } from "react";

import { AdminNav } from "@/components/admin/AdminNav";

export function AdminFrame({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col lg:flex-row">
      <AdminNav />
      <div className="flex-1 px-6 py-8">{children}</div>
    </div>
  );
}
