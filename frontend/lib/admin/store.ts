import { randomUUID } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

import { emptyCatalog, type Catalog, type CatalogItem, type CatalogPerson, type ItemKind } from "@/lib/admin/types";

const file = path.join(process.cwd(), "data", "catalog.json");

let queue: Promise<void> = Promise.resolve();

export async function readCatalog(): Promise<Catalog> {
  try {
    const raw = await readFile(file, "utf8");
    const parsed = JSON.parse(raw) as Catalog;
    return {
      people: Array.isArray(parsed.people) ? parsed.people : [],
      items: Array.isArray(parsed.items) ? parsed.items : [],
    };
  } catch {
    return emptyCatalog();
  }
}

async function save(catalog: Catalog) {
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file, JSON.stringify(catalog, null, 2));
}

export function updateCatalog(change: (catalog: Catalog) => void) {
  const run = queue.then(async () => {
    const catalog = await readCatalog();
    change(catalog);
    await save(catalog);
  });
  queue = run.then(
    () => undefined,
    () => undefined,
  );
  return run;
}

export function addPerson(person: Omit<CatalogPerson, "id" | "status">) {
  return updateCatalog((catalog) => {
    catalog.people.unshift({ ...person, id: randomUUID(), status: "active" });
  });
}

export function setPersonStatus(id: string, status: CatalogPerson["status"]) {
  return updateCatalog((catalog) => {
    const person = catalog.people.find((item) => item.id === id);
    if (person) person.status = status;
  });
}

export function removePerson(id: string) {
  return updateCatalog((catalog) => {
    catalog.people = catalog.people.filter((item) => item.id !== id);
  });
}

export function addItem(item: Omit<CatalogItem, "id" | "status">) {
  return updateCatalog((catalog) => {
    catalog.items.unshift({ ...item, id: randomUUID(), status: "draft" });
  });
}

export function setItemStatus(id: string, status: CatalogItem["status"]) {
  return updateCatalog((catalog) => {
    const item = catalog.items.find((entry) => entry.id === id);
    if (item) item.status = status;
  });
}

export function removeItem(id: string) {
  return updateCatalog((catalog) => {
    catalog.items = catalog.items.filter((item) => item.id !== id);
  });
}

export async function publishedItems(kind: ItemKind, fanId?: string) {
  const catalog = await readCatalog();
  return catalog.items.filter(
    (item) => item.status === "published" && item.kind === kind && (!fanId || item.fanId === fanId),
  );
}
