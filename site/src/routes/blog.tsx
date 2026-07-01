import { createFileRoute } from "@tanstack/react-router";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { motion } from "framer-motion";
import { Calendar, User, ArrowRight } from "lucide-react";

export const Route = createFileRoute("/blog")({
  component: BlogPage,
});

const posts = [
  {
    title: "Breaking Language Barriers: The Future of AI Keyboards",
    excerpt: "How real-time AI is changing the way we communicate across cultures without leaving our favorite apps.",
    author: "Elena Rodriguez",
    date: "June 25, 2026",
    category: "Technology",
  },
  {
    title: "5 Tips for International Business Communication",
    excerpt: "Mastering tone and cultural context in global sales and operations.",
    author: "Marcus Chen",
    date: "June 20, 2026",
    category: "Business",
  },
  {
    title: "Privacy First: How We Secure Your Data",
    excerpt: "A deep dive into FlowLingo's encryption and on-device processing architecture.",
    author: "Sarah Jenkins",
    date: "June 15, 2026",
    category: "Privacy",
  },
];

function BlogPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24">
        <div className="max-w-7xl mx-auto px-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="text-center mb-16"
          >
            <h1 className="text-display sm:text-6xl font-bold tracking-tight text-neutral-text-high dark:text-dark-text-high mb-6">
              FlowLingo Blog
            </h1>
            <p className="text-xl text-neutral-text-low dark:text-dark-text-low max-w-2xl mx-auto">
              Insights on AI, communication, and the world without language barriers.
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {posts.map((post, index) => (
              <motion.article
                key={post.title}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="group p-8 rounded-[2rem] border border-neutral-text-low/10 bg-white dark:bg-dark-surface shadow-sm hover:shadow-xl transition-all"
              >
                <div className="text-xs font-bold uppercase tracking-widest text-primary mb-4">
                  {post.category}
                </div>
                <h2 className="text-2xl font-bold mb-4 group-hover:text-primary transition-colors">
                  {post.title}
                </h2>
                <p className="text-neutral-text-low dark:text-dark-text-low mb-8 line-clamp-3">
                  {post.excerpt}
                </p>
                <div className="flex items-center justify-between mt-auto pt-6 border-t border-neutral-text-low/5">
                  <div className="flex flex-col gap-1">
                    <span className="text-sm font-bold">{post.author}</span>
                    <span className="text-xs text-neutral-text-low">{post.date}</span>
                  </div>
                  <div className="w-10 h-10 rounded-full bg-neutral-surface dark:bg-dark-bg flex items-center justify-center group-hover:bg-primary group-hover:text-white transition-all">
                    <ArrowRight className="w-5 h-5" />
                  </div>
                </div>
              </motion.article>
            ))}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
