import { createFileRoute } from "@tanstack/react-router";
import { Download } from "../components/Download";
import { FeaturePreview } from "../components/Features";
import { Footer } from "../components/Footer";
import { Hero } from "../components/Hero";
import { Navbar } from "../components/Navbar";
import { WaitlistSignup } from "../components/WaitlistSignup";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "FlowLingo — AI Keyboard for Seamless Cross-Language Communication" },
      { name: "description", content: "FlowLingo translates, localizes, and adjusts tone across 50+ languages inside any messaging app. Type naturally, speak globally." },
      { property: "og:title", content: "FlowLingo — Your Keyboard, Perfectly Fluent" },
      { property: "og:description", content: "The intelligent AI keyboard that removes language barriers. Translate across 50+ languages inside any app." },
    ],
  }),
  component: Home,
});

function Home() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1">
        <Hero />
        <WaitlistSignup />
        <FeaturePreview />
        <Download />
      </main>
      <Footer />
    </div>
  );
}
