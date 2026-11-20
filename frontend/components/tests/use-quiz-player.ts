"use client";

import { useEffect, useState } from "react";

import { readStoredProfileRaw, subscribeProfileStore } from "@/components/profile/profile-data";

const playerKey = "ilm-fan-quiz-player";

function readPlayerId() {
  const existing = sessionStorage.getItem(playerKey);
  if (existing) return existing;
  const next = crypto.randomUUID();
  sessionStorage.setItem(playerKey, next);
  return next;
}

function readProfileName() {
  const raw = readStoredProfileRaw();
  if (!raw) return "";
  try {
    const profile = JSON.parse(raw) as { firstName?: string; lastName?: string };
    return [profile.firstName, profile.lastName].filter(Boolean).join(" ");
  } catch {
    return "";
  }
}

export function useQuizPlayerId() {
  const [id, setId] = useState("");

  useEffect(() => {
    setId(readPlayerId());
  }, []);

  return id;
}

export function useProfileName() {
  const [name, setName] = useState("");

  useEffect(() => {
    const sync = () => setName(readProfileName());
    sync();
    return subscribeProfileStore(sync);
  }, []);

  return name;
}
