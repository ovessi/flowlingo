import { motion } from "framer-motion";
import { Languages, MessageSquareText, Shield, Zap } from "lucide-react";

const features = [
  {
    name: "Instant Translation",
    description: "Translate messages in real-time as you type or receive them, without leaving your favorite apps.",
    icon: Languages,
    color: "bg-blue-500",
  },
  {
    name: "Tone Adjustment",
    description: "Switch between Professional, Casual, Friendly, or Assertive tones with a single tap.",
    icon: MessageSquareText,
    color: "bg-purple-500",
  },
  {
    name: "Context Analysis",
    description: "Understand slang, cultural nuances, and hidden meanings in foreign messages instantly.",
    icon: Zap,
    color: "bg-amber-500",
  },
  {
    name: "Privacy First",
    description: "Your data is encrypted and never stored. AI processing happens with maximum security.",
    icon: Shield,
    color: "bg-emerald-500",
  },
];

export function FeaturePreview() {
  return (
    <section className="py-24 px-6 bg-neutral-surface dark:bg-dark-surface/50">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-heading sm:text-4xl font-bold text-neutral-text-high dark:text-dark-text-high mb-4">
            Everything you need for global communication
          </h2>
          <p className="text-neutral-text-low dark:text-dark-text-low max-w-2xl mx-auto">
            FlowLingo brings powerful AI tools directly to your fingertips, integrated seamlessly into your mobile experience.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature, index) => (
            <motion.div
              key={feature.name}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              className="p-8 rounded-standard bg-white dark:bg-dark-surface border border-neutral-text-low/10 shadow-sm hover:shadow-md transition-shadow"
            >
              <div className={`w-12 h-12 ${feature.color} rounded-xl flex items-center justify-center mb-6 shadow-lg shadow-current/20`}>
                <feature.icon className="w-6 h-6 text-white" />
              </div>
              <h3 className="text-lg font-bold text-neutral-text-high dark:text-dark-text-high mb-3">
                {feature.name}
              </h3>
              <p className="text-neutral-text-low dark:text-dark-text-low text-sm leading-relaxed">
                {feature.description}
              </p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
