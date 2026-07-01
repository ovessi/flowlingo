import { createFileRoute } from "@tanstack/react-router";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { useState } from "react";
import { ChevronDown, ChevronUp } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

export const Route = createFileRoute("/faq")({
  component: FAQPage,
});

const faqs = [
  {
    question: "Is FlowLingo safe to use?",
    answer: "Absolutely. FlowLingo is built with a privacy-first architecture. We do not store your keystrokes, and AI processing happens over encrypted channels. We only analyze text when you explicitly trigger an AI action.",
  },
  {
    question: "Does the keyboard require 'Full Access'?",
    answer: "To provide real-time translation and AI features, iOS and Android require 'Full Access'. This allows the keyboard to communicate with our secure AI engine. We use this access strictly for the features you trigger.",
  },
  {
    question: "Which languages are supported?",
    answer: "FlowLingo currently supports 50+ major world languages, including English, Spanish, French, German, Japanese, Chinese, Arabic, Portuguese, and many more. We are constantly adding more.",
  },
  {
    question: "Can I use FlowLingo offline?",
    answer: "Yes! Premium users can download offline translation packs for basic translation needs. However, advanced features like Tone Adjustment and AI Replies require an internet connection.",
  },
  {
    question: "How does the 'Copy-to-Analyze' feature work?",
    answer: "When you copy a message in any app, FlowLingo can automatically detect it (if enabled) and offer an instant breakdown. You can then tap a button in the keyboard to see the analysis or suggested replies.",
  },
  {
    question: "Do you offer enterprise pricing?",
    answer: "Yes, we offer custom plans for teams and organizations needing centralized billing, dedicated AI endpoints, and administrative controls. Contact our sales team for a demo.",
  },
];

function FAQItem({ faq }: { faq: typeof faqs[0] }) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="border-b border-neutral-text-low/10">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full py-8 flex items-center justify-between text-left group"
      >
        <span className="text-xl font-bold group-hover:text-primary transition-colors italic">
          {faq.question}
        </span>
        {isOpen ? (
          <ChevronUp className="w-6 h-6 text-primary shrink-0" />
        ) : (
          <ChevronDown className="w-6 h-6 text-neutral-text-low shrink-0" />
        )}
      </button>
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="overflow-hidden"
          >
            <p className="pb-8 text-neutral-text-low text-lg leading-relaxed">
              {faq.answer}
            </p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function FAQPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24">
        <div className="max-w-3xl mx-auto px-6">
          <div className="text-center mb-16">
            <h1 className="text-display sm:text-6xl font-bold tracking-tight mb-6 italic">Questions? <br /> We have answers.</h1>
            <p className="text-xl text-neutral-text-low leading-relaxed">
              Everything you need to know about the smart keyboard that's changing how the world communicates.
            </p>
          </div>

          <div className="mb-24">
            {faqs.map((faq) => (
              <FAQItem key={faq.question} faq={faq} />
            ))}
          </div>

          <div className="rounded-standard bg-neutral-surface dark:bg-dark-surface p-10 text-center border border-neutral-text-low/5">
            <h3 className="text-xl font-bold mb-4 italic">Still have questions?</h3>
            <p className="text-neutral-text-low mb-8">
              Can't find what you're looking for? Our support team is here to help.
            </p>
            <button className="bg-primary text-white px-8 py-3 rounded-standard font-bold hover:bg-primary/90 transition-all">
              Contact Support
            </button>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
