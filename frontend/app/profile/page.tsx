import type { Metadata } from "next";

import { ProfileHome } from "@/components/profile/ProfileHome";

export const metadata: Metadata = {
  title: "Profil",
};

export default function ProfilePage() {
  return <ProfileHome />;
}
