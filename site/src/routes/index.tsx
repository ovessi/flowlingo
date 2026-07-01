import { createFileRoute } from "@tanstack/react-router";
import { Download } from "../components/Download";
import { FeaturePreview } from "../components/Features";
import { Footer } from "../components/Footer";
import { Hero } from "../components/Hero";
import { Navbar } from "../components/Navbar";

export const Route = createFileRoute("/")({
  component: Home,
});

function Home() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1">
        <Hero />
        <FeaturePreview />
        <Download />
      </main>
      <Footer />
    </div>
  );
}
