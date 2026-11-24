import type { Metadata } from "next";
import { Newsreader, Plus_Jakarta_Sans } from "next/font/google";

import { SiteChrome } from "@/components/layout/SiteChrome";

import "./globals.css";

const newsreader = Newsreader({
  variable: "--font-newsreader",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
  style: ["normal", "italic"],
});

const plusJakarta = Plus_Jakarta_Sans({
  variable: "--font-jakarta",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: "Ilm Fan — Sertifikat va abituriyent tayyorlov platformasi",
  description: "O‘qituvchi sertifikati va abituriyent imtihoniga tartibli tayyorlov.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="uz" className={`${newsreader.variable} ${plusJakarta.variable} h-full antialiased`}>
      <body className="flex min-h-full flex-col bg-paper text-ink">
        <SiteChrome>{children}</SiteChrome>
      </body>
    </html>
  );
}
