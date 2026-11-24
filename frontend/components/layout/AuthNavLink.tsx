"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import {
  readStoredProfileRaw,
  subscribeProfileStore,
} from "@/components/profile/profile-data";
import { clearStoredProfile, saveBackendUserToProfile } from "@/lib/auth/client";

const authButtonClass =
  "rounded-full bg-accent px-4 py-2 text-sm font-medium text-paper transition-colors hover:bg-accent-hover";

export function AuthNavLink() {
  const [loggedIn, setLoggedIn] = useState(false);

  useEffect(() => {
    const sync = () => setLoggedIn(Boolean(readStoredProfileRaw()));
    sync();
    fetch("/api/auth/me")
      .then(async (r) => {
        if (r.ok) {
          const data = await r.json().catch(() => null);
          if (data?.user) saveBackendUserToProfile(data.user);
        } else if (r.status === 401 && readStoredProfileRaw()) {
          clearStoredProfile();
        }
      })
      .catch(() => {});
    return subscribeProfileStore(sync);
  }, []);

  return (
    <Link href={loggedIn ? "/profile" : "/login"} className={authButtonClass}>
      {loggedIn ? "Profil" : "Kirish"}
    </Link>
  );
}
