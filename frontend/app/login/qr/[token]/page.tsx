import type { Metadata } from "next";

import { QrApproveFlow } from "@/components/login/QrApproveFlow";

export const metadata: Metadata = {
  title: "QR tasdiqlash — Ilm Fan",
};

export const instant = false;

const BACKEND_URL = (process.env.BACKEND_API_URL || "http://127.0.0.1:8080").replace(/\/$/, "");

type ScanResponse = {
  success?: boolean;
  message?: string;
  payload?: {
    status?: string;
    desktop_device?: string;
  };
};

export default async function QrApprovePage({
  params,
  searchParams,
}: {
  params: Promise<{ token: string }>;
  searchParams: Promise<{ done?: string; new?: string; error?: string }>;
}) {
  const [{ token }, query] = await Promise.all([params, searchParams]);

  if (query.done === "1") {
    return (
      <QrApproveFlow
        token={token}
        initialView="done"
        initialDevice="Kompyuter brauzeri"
        initialNewHandoff={query.new === "1"}
        initialError={null}
      />
    );
  }

  let initialView: "ready" | "done" | "invalid" = "ready";
  let initialDevice = "Kompyuter brauzeri";
  let initialError: string | null = query.error || null;

  try {
    const res = await fetch(`${BACKEND_URL}/api/v1/auth/qr/scan`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify({ qr_token: token }),
      cache: "no-store",
    });
    const data = (await res.json().catch(() => ({}))) as ScanResponse;
    if (!res.ok || !data.success || !data.payload) {
      initialView = "invalid";
      initialError = data.message || "QR kod yaroqsiz yoki muddati tugagan";
    } else if (data.payload.status === "approved") {
      initialView = "done";
    } else if (data.payload.desktop_device) {
      initialDevice = data.payload.desktop_device;
    }
  } catch {
    initialView = "invalid";
    initialError = "Server bilan bog‘lanib bo‘lmadi, qayta urining";
  }

  return (
    <QrApproveFlow
      token={token}
      initialView={initialView}
      initialDevice={initialDevice}
      initialNewHandoff={false}
      initialError={initialError}
    />
  );
}
