import { Audiences } from "@/components/landing/Audiences";
import { Hero } from "@/components/landing/Hero";
import { LoginPaths } from "@/components/landing/LoginPaths";
import { Sections } from "@/components/landing/Sections";

export default function Home() {
  return (
    <>
      <Hero />
      <Audiences />
      <Sections />
      <LoginPaths />
    </>
  );
}
