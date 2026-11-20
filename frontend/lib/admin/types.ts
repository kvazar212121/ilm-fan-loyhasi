export const personRoles = ["cert-teacher", "guide-teacher", "applicant", "pupil"] as const;

export type PersonRole = (typeof personRoles)[number];

export const itemKinds = [
  { id: "sertifikat", title: "Sertifikatga tayyorlov" },
  { id: "abituriyent", title: "Abituriyent tayyorlovi" },
  { id: "darslik", title: "Darslik" },
  { id: "kurs", title: "Kurs" },
  { id: "reel", title: "Reel" },
] as const;

export type ItemKind = (typeof itemKinds)[number]["id"];

export type CatalogPerson = {
  id: string;
  firstName: string;
  lastName: string;
  role: PersonRole;
  fanId: string;
  status: "active" | "blocked";
};

export type CatalogItem = {
  id: string;
  kind: ItemKind;
  fanId: string;
  title: string;
  text: string;
  status: "draft" | "published";
};

export type Catalog = {
  people: CatalogPerson[];
  items: CatalogItem[];
};

export function emptyCatalog(): Catalog {
  return { people: [], items: [] };
}
