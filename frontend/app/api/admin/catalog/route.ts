import { connection } from "next/server";

import { isAdmin } from "@/lib/admin/auth";
import {
  addItem,
  addPerson,
  readCatalog,
  removeItem,
  removePerson,
  setItemStatus,
  setPersonStatus,
} from "@/lib/admin/store";
import { itemKinds, personRoles, type ItemKind, type PersonRole } from "@/lib/admin/types";
import { getTayyorlovFan } from "@/components/tayyorlov/tayyorlov-fans";

type Body = {
  action?: string;
  id?: string;
  firstName?: string;
  lastName?: string;
  role?: string;
  fanId?: string;
  kind?: string;
  title?: string;
  text?: string;
  status?: string;
};

function isRole(value: string): value is PersonRole {
  return personRoles.some((role) => role === value);
}

function isKind(value: string): value is ItemKind {
  return itemKinds.some((kind) => kind.id === value);
}

export async function GET() {
  await connection();
  if (!(await isAdmin())) return Response.json({ error: "Kirish kerak" }, { status: 401 });
  return Response.json(await readCatalog());
}

export async function POST(request: Request) {
  await connection();
  if (!(await isAdmin())) return Response.json({ error: "Kirish kerak" }, { status: 401 });
  const body = (await request.json()) as Body;
  const fanId = body.fanId?.trim() ?? "";
  if (fanId && !getTayyorlovFan(fanId)) {
    return Response.json({ error: "Fan topilmadi" }, { status: 400 });
  }

  if (body.action === "add-person") {
    const firstName = body.firstName?.trim() ?? "";
    const lastName = body.lastName?.trim() ?? "";
    if (!firstName || !lastName || !body.role || !isRole(body.role)) {
      return Response.json({ error: "Ism, familiya va rol kerak" }, { status: 400 });
    }
    await addPerson({ firstName, lastName, role: body.role, fanId });
    return Response.json({ ok: true });
  }

  if (body.action === "person-status" && body.id && (body.status === "active" || body.status === "blocked")) {
    await setPersonStatus(body.id, body.status);
    return Response.json({ ok: true });
  }

  if (body.action === "remove-person" && body.id) {
    await removePerson(body.id);
    return Response.json({ ok: true });
  }

  if (body.action === "add-item") {
    const title = body.title?.trim() ?? "";
    const text = body.text?.trim() ?? "";
    if (!title || !text || !body.kind || !isKind(body.kind) || !fanId) {
      return Response.json({ error: "Bo‘lim, fan, sarlavha va matn kerak" }, { status: 400 });
    }
    await addItem({ kind: body.kind, fanId, title, text });
    return Response.json({ ok: true });
  }

  if (body.action === "item-status" && body.id && (body.status === "draft" || body.status === "published")) {
    await setItemStatus(body.id, body.status);
    return Response.json({ ok: true });
  }

  if (body.action === "remove-item" && body.id) {
    await removeItem(body.id);
    return Response.json({ ok: true });
  }

  return Response.json({ error: "Noma’lum amal" }, { status: 400 });
}
