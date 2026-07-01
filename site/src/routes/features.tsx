import { createFileRoute } from "@tanstack/react-router";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { motion } from "framer-motion";
import { Languages, MessageSquareText, Zap, Shield, Globe, Sparkles, Cpu, Lock } from "lucide-react";

export const Route = createFileRoute("/features")({
  component: FeaturesPage,
});

const mainFeatures = [
  {
    name: "Real-time Translation",
    description: "Type in your native language and watch it transform into one of 50+ supported languages instantly. No more context switching.",
    icon: Languages,
    color: "text-blue-500",
    bg: "bg-blue-500/10",
  },
  {
    name: "Adaptive Tone Control",
    description: "Whether it's a professional email or a casual text, toggle between Formal, Friendly, Urgent, or Casual tones with a tap.",
    icon: MessageSquareText,
    color: "text-purple-500",
    bg: "bg-purple-500/10",
  },
  {
    name: "Context Analysis",
    description: "Receive a message you don't fully understand? Copy it to see an AI breakdown of slang, cultural nuances, and intent.",
    icon: Zap,
    color: "text-amber-500",
    bg: "bg-amber-500/10",
  },
  {
    name: "AI-Powered Replies",
    description: "FlowLingo suggests 3 contextually relevant replies for every message you receive, helping you keep the conversation flowing.",
    icon: Sparkles,
    color: "text-indigo-500",
    bg: "bg-indigo-500/10",
  },
];

const techFeatures = [
  {
    name: "Privacy-First Architecture",
    description: "Your data is processed locally whenever possible and encrypted end-to-end. We never store your keystrokes.",
    icon: Shield,
  },
  {
    name: "Smart Localization",
    description: "Automatically adjusts dates, currency symbols, and units of measure to match the culture of your recipient.",
    icon: Globe,
  },
  {
    name: "Personal Dictionary",
    description: "FlowLingo learns your preferred phrases and industry-specific terminology to provide personalized suggestions.",
    icon: Cpu,
  },
  {
    name: "Secure Enterprise SDK",
    description: "Deploy FlowLingo across your organization with dedicated endpoints and centralized security management.",
    icon: Lock,
  },
];

function FeaturesPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24">
        {/* Hero Section */}
        <section className="max-w-7xl mx-auto px-6 mb-24 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <h1 className="text-display sm:text-6xl font-bold tracking-tight mb-6">
              Communication without <br /> the language barrier.
            </h1>
            <p className="text-xl text-neutral-text-low max-w-3xl mx-auto leading-relaxed">
              FlowLingo isn't just a translator—it's an intelligent communication assistant that lives where you type.
            </p>
          </motion.div>
        </section>

        {/* Core Features Grid */}
        <section className="max-w-7xl mx-auto px-6 mb-32">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
            {mainFeatures.map((feature, index) => (
              <motion.div
                key={feature.name}
                initial={{ opacity: 0, x: index % 2 === 0 ? -20 : 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
                className="flex flex-col gap-6 p-10 rounded-[2.5rem] bg-neutral-surface dark:bg-dark-surface border border-neutral-text-low/5"
              >
                <div className={`w-16 h-16 ${feature.bg} rounded-2xl flex items-center justify-center`}>
                  <feature.icon className={`w-8 h-8 ${feature.color}`} />
                </div>
                <h3 className="text-2xl font-bold">{feature.name}</h3>
                <p className="text-lg text-neutral-text-low leading-relaxed italic">
                  {feature.description}
                </p>
              </motion.div>
            ))}
          </div>
        </section>

        {/* Detailed List */}
        <section className="bg-neutral-bg dark:bg-dark-bg py-24 border-y border-neutral-text-low/10">
          <div className="max-w-7xl mx-auto px-6">
            <h2 className="text-3xl sm:text-4xl font-bold mb-16 text-center italic">Built for the Modern Professional</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-12">
              {techFeatures.map((feature) => (
                <div key={feature.name}>
                  <feature.icon className="w-8 h-8 text-primary mb-6" />
                  <h4 className="text-lg font-bold mb-4">{feature.name}</h4>
                  <p className="text-sm text-neutral-text-low leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Keyboard Preview CTA */}
        <section className="max-w-7xl mx-auto px-6 pt-32 text-center">
          <div className="bg-primary rounded-[3rem] p-12 lg:p-24 text-white relative overflow-hidden">
            <div className="relative z-10">
              <h2 className="text-4xl sm:text-5xl font-bold mb-8 italic">See FlowLingo in action.</h2>
              <p className="text-xl opacity-90 mb-12 max-w-2xl mx-auto">
                Join 500,000+ users who have removed language barriers from their daily communication.
              </p>
              <button className="bg-white text-primary px-12 py-5 rounded-standard font-bold text-lg hover:bg-opacity-90 transition-all">
                Download Now
              </button>
            </div>
            {/* Background pattern */}
            <div className="absolute inset-0 opacity-10 pointer-events-none">
              <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-white via-transparent to-transparent scale-150" />
            </div>
          </div>
        </section>
      </main>
      <Footer />
    </div>
  );
}
