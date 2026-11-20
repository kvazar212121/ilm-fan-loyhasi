export async function mutateCatalog(body: Record<string, string>) {
  const response = await fetch("/api/admin/catalog", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    const payload = (await response.json().catch(() => ({}))) as { error?: string };
    throw new Error(payload.error ?? "Saqlanmadi");
  }
}
