import { createFileRoute, Link } from "@tanstack/react-router";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { BookOpen, Code, Terminal, Smartphone, ShieldCheck, Zap } from "lucide-react";

export const Route = createFileRoute("/docs")({
  component: DocsPage,
});

const docCategories = [
  {
    title: "Getting Started",
    icon: BookOpen,
    links: ["Installation", "Keyboard Setup", "First Translation"],
  },
  {
    title: "AI Features",
    icon: Zap,
    links: ["Tone Adjustment", "Context Analysis", "Smart Replies"],
  },
  {
    title: "Mobile Apps",
    icon: Smartphone,
    links: ["iOS Extension", "Android Service", "Companion App"],
  },
  {
    title: "Developer API",
    icon: Code,
    links: ["Authentication", "Translation Endpoint", "Webhooks"],
  },
  {
    title: "Security",
    icon: ShieldCheck,
    links: ["Data Privacy", "Encryption", "Compliance"],
  },
  {
    title: "CLI Tools",
    icon: Terminal,
    links: ["Local Testing", "Debug Logs", "Profile Export"],
  },
];

function DocsPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24 px-6">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-20">
            <h1 className="text-4xl sm:text-6xl font-bold tracking-tight mb-6 italic">Documentation</h1>
            <p className="text-xl text-neutral-text-low max-w-2xl mx-auto leading-relaxed">
              Everything you need to set up, use, and integrate with FlowLingo.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {docCategories.map((category) => (
              <div key={category.title} className="p-8 rounded-[2rem] border border-neutral-text-low/10 bg-white dark:bg-dark-surface hover:shadow-md transition-shadow">
                <div className="w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center mb-6">
                  <category.icon className="w-6 h-6 text-primary" />
                </div>
                <h3 className="text-xl font-bold mb-6 italic">{category.title}</h3>
                <ul className="space-y-4">
                  {category.links.map((link) => (
                    <li key={link}>
                      <a href="#" className="text-neutral-text-low hover:text-primary transition-colors text-sm font-medium flex items-center gap-2 group">
                        <span className="w-1.5 h-1.5 rounded-full bg-neutral-text-low group-hover:bg-primary transition-colors" />
                        {link}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>

          <div className="mt-20 p-12 rounded-[2.5rem] bg-primary text-white flex flex-col md:flex-row items-center justify-between gap-8">
            <div>
              <h2 className="text-3xl font-bold mb-2 italic">Need developer support?</h2>
              <p className="opacity-80">Our engineering team is ready to help you with deep integrations.</p>
            </div>
            <button className="bg-white text-primary px-8 py-4 rounded-standard font-bold whitespace-nowrap hover:bg-opacity-90 transition-all">
              Join Discord
            </button>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
