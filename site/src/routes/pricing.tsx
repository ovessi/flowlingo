import { createFileRoute } from "@tanstack/react-router";
import { Check, X } from "lucide-react";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { motion, AnimatePresence } from "framer-motion";
import { useState } from "react";

export const Route = createFileRoute("/pricing")({
  component: PricingPage,
});

const tiers = [
  {
    name: "Free",
    price: { monthly: "$0", annual: "$0" },
    description: "Perfect for casual travelers and beginners.",
    features: [
      "5 AI actions per day",
      "Basic translation",
      "Standard tone adjustment",
      "50+ languages supported",
    ],
    notIncluded: [
      "Tone profiles",
      "AI Memory",
      "Offline packs",
      "Shared memory pools",
    ],
    cta: "Get Started",
    popular: false,
  },
  {
    name: "Premium",
    price: { monthly: "$9.99", annual: "$7.99" },
    period: "/mo",
    description: "The complete AI communication suite.",
    features: [
      "Unlimited AI actions",
      "All tone profiles",
      "AI Memory & Dictionary",
      "Offline translation packs",
      "Priority AI processing",
    ],
    notIncluded: [
      "Shared memory pools",
      "Team management",
    ],
    cta: "Start Free Trial",
    popular: true,
  },
  {
    name: "Family",
    price: { monthly: "$19.99", annual: "$15.99" },
    period: "/mo",
    description: "Seamless connection for the whole family.",
    features: [
      "Up to 5 users included",
      "Shared memory pools",
      "All Premium features",
      "Individual usage stats",
      "Family dashboard",
    ],
    notIncluded: [
      "Enterprise security SLA",
    ],
    cta: "Upgrade Now",
    popular: false,
  },
];

function PricingPage() {
  const [isAnnual, setIsAnnual] = useState(true);

  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24">
        <div className="max-w-7xl mx-auto px-6 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <h1 className="text-display sm:text-6xl font-bold tracking-tight text-neutral-text-high dark:text-dark-text-high mb-6">
              Pricing that grows <br className="hidden sm:block" /> with your world.
            </h1>
            <p className="text-xl text-neutral-text-low dark:text-dark-text-low max-w-2xl mx-auto mb-12">
              Choose the plan that fits your communication needs. From casual chats to global enterprise operations.
            </p>

            <div className="flex items-center justify-center gap-4 mb-16">
              <span className={`text-sm font-bold ${!isAnnual ? "text-neutral-text-high" : "text-neutral-text-low"}`}>Monthly</span>
              <button
                onClick={() => setIsAnnual(!isAnnual)}
                className="w-14 h-8 rounded-full bg-neutral-surface dark:bg-dark-surface p-1 relative transition-colors"
              >
                <motion.div
                  animate={{ x: isAnnual ? 24 : 0 }}
                  className="w-6 h-6 rounded-full bg-primary shadow-sm"
                />
              </button>
              <span className={`text-sm font-bold ${isAnnual ? "text-neutral-text-high" : "text-neutral-text-low"}`}>
                Annual <span className="text-primary ml-1">(Save 20%)</span>
              </span>
            </div>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-24">
            {tiers.map((tier, index) => (
              <motion.div
                key={tier.name}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className={`relative p-8 rounded-[2rem] border ${
                  tier.popular
                    ? "border-primary bg-primary/[0.02] dark:bg-primary/[0.05] shadow-xl shadow-primary/10"
                    : "border-neutral-text-low/10 bg-white dark:bg-dark-surface shadow-sm"
                }`}
              >
                {tier.popular && (
                  <div className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-primary text-white text-xs font-bold uppercase tracking-widest px-4 py-1 rounded-full">
                    Most Popular
                  </div>
                )}
                <div className="mb-8">
                  <h3 className="text-xl font-bold mb-2">{tier.name}</h3>
                  <div className="flex items-baseline justify-center gap-1">
                    <AnimatePresence mode="wait">
                      <motion.span
                        key={isAnnual ? 'annual' : 'monthly'}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        className="text-4xl font-bold tracking-tight"
                      >
                        {isAnnual ? tier.price.annual : tier.price.monthly}
                      </motion.span>
                    </AnimatePresence>
                    {tier.period && <span className="text-neutral-text-low text-sm font-medium">{tier.period}</span>}
                  </div>
                  <p className="mt-4 text-sm text-neutral-text-low leading-relaxed">
                    {tier.description}
                  </p>
                </div>

                <ul className="space-y-4 mb-10 text-left">
                  {tier.features.map((feature) => (
                    <li key={feature} className="flex items-start gap-3 text-sm">
                      <Check className="w-5 h-5 text-primary shrink-0" />
                      <span className="text-neutral-text-high dark:text-dark-text-high">{feature}</span>
                    </li>
                  ))}
                  {tier.notIncluded.map((feature) => (
                    <li key={feature} className="flex items-start gap-3 text-sm opacity-40 grayscale">
                      <X className="w-5 h-5 shrink-0" />
                      <span>{feature}</span>
                    </li>
                  ))}
                </ul>

                <button
                  className={`w-full py-4 rounded-standard font-bold transition-all active:scale-95 ${
                    tier.popular
                      ? "bg-primary text-white shadow-lg hover:bg-primary/90"
                      : "bg-neutral-surface dark:bg-dark-bg border border-neutral-text-low/10 hover:bg-neutral-surface/80"
                  }`}
                >
                  {tier.cta}
                </button>
              </motion.div>
            ))}
          </div>

          <div className="rounded-[2.5rem] bg-neutral-surface dark:bg-dark-surface p-12 lg:p-20 text-center relative overflow-hidden">
            <div className="relative z-10 max-w-3xl mx-auto">
              <h2 className="text-3xl sm:text-4xl font-bold mb-6 italic">FlowLingo for Enterprise</h2>
              <p className="text-lg text-neutral-text-low mb-10 leading-relaxed">
                Scale global communication across your entire organization with dedicated AI endpoints, SSO, and team-wide admin controls.
              </p>
              <button className="bg-neutral-text-high dark:bg-white text-white dark:text-black px-10 py-4 rounded-standard font-bold hover:opacity-90 transition-all">
                Contact Sales
              </button>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
