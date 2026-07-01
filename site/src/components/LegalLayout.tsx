import { Navbar } from "./Navbar";
import { Footer } from "./Footer";
import { motion } from "framer-motion";

interface LegalLayoutProps {
  title: string;
  lastUpdated: string;
  children: React.ReactNode;
}

export function LegalLayout({ title, lastUpdated, children }: LegalLayoutProps) {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24">
        <div className="max-w-3xl mx-auto px-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-neutral-text-high dark:text-dark-text-high mb-4">
              {title}
            </h1>
            <p className="text-sm text-neutral-text-low mb-12">
              Last Updated: {lastUpdated}
            </p>
            <div className="prose prose-neutral dark:prose-invert max-w-none prose-h2:text-2xl prose-h2:mt-12 prose-h2:mb-6 prose-p:text-neutral-text-low dark:prose-p:text-dark-text-low prose-p:leading-relaxed prose-li:text-neutral-text-low dark:prose-li:text-dark-text-low">
              {children}
            </div>
          </motion.div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
