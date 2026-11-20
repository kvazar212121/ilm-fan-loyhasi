"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import {
  readStoredProfileRaw,
  subscribeProfileStore,
} from "@/components/profile/profile-data";

const authButtonClass =
  "rounded-full bg-accent px-4 py-2 text-sm font-medium text-white transition-opacity hover:opacity-90";

export function AuthNavLink() {
  const [loggedIn, setLoggedIn] = useState(false);

  useEffect(() => {
    const sync = () => setLoggedIn(Boolean(readStoredProfileRaw()));
    sync();
    return subscribeProfileStore(sync);
  }, []);

  return (
    <Link href={loggedIn ? "/profile" : "/login"} className={authButtonClass}>
      {loggedIn ? "Profil" : "Kirish"}
    </Link>
  );
}
