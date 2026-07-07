import { createServerFn } from "@tanstack/react-start";
import { motion } from "framer-motion";
import { ArrowRight, Check, Loader2 } from "lucide-react";
import { useState } from "react";

const submitWaitlist = createServerFn({ method: "POST" })
  .validator((data: unknown) => {
    if (typeof data !== "object" || data === null) throw new Error("Invalid request");
    const d = data as Record<string, unknown>;
    if (typeof d.email !== "string") throw new Error("Email is required");
    return { email: d.email };
  })
  .handler(async ({ data }) => {
    // Store signup durably to a shared file
    const fs = await import("node:fs/promises");
    const path = await import("node:path");
    const filePath = path.join(process.cwd(), "..", "waitlist-signups.json");

    let signups: Array<{ email: string; timestamp: string }> = [];
    try {
      const existing = await fs.readFile(filePath, "utf-8");
      signups = JSON.parse(existing);
    } catch {
      // File doesn't exist yet, start fresh
    }

    // Avoid duplicates
    if (!signups.some((s) => s.email === data.email)) {
      signups.push({ email: data.email, timestamp: new Date().toISOString() });
      await fs.writeFile(filePath, JSON.stringify(signups, null, 2), "utf-8");
    }

    return { success: true, message: "Thanks! We'll be in touch." };
  });

export function WaitlistSignup() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [message, setMessage] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !email.includes("@")) return;

    setStatus("loading");
    try {
      const result = await submitWaitlist({ data: { email } });
      setStatus("success");
      setMessage(result.message);
      setEmail("");
    } catch {
      setStatus("error");
      setMessage("Something went wrong. Please try again.");
    }
  };

  if (status === "success") {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-full max-w-md mx-auto mt-12"
      >
        <div className="rounded-2xl bg-primary/5 dark:bg-primary/10 border border-primary/20 p-6 text-center">
          <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
            <Check className="w-6 h-6 text-primary" />
          </div>
          <p className="text-lg font-bold mb-1">You're on the list!</p>
          <p className="text-sm text-neutral-text-low">
            We'll notify you when beta access is ready.
          </p>
        </div>
      </motion.div>
    );
  }

  return (
    <motion.div
      id="waitlist"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.5 }}
      className="w-full max-w-md mx-auto mt-12"
    >
      <div className="rounded-2xl bg-neutral-surface/80 dark:bg-dark-surface/80 backdrop-blur-sm border border-neutral-text-low/10 p-6 shadow-sm">
        <p className="text-sm font-bold mb-1 text-center">Join the FlowLingo Beta</p>
        <p className="text-xs text-neutral-text-low mb-4 text-center">
                    We'll contact selected testers when builds are ready.
                  </p>
        <form onSubmit={handleSubmit} className="flex gap-2">
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@email.com"
            required
            className="flex-1 px-4 py-3 rounded-standard bg-white dark:bg-dark-bg border border-neutral-text-low/20 text-sm outline-none focus:ring-2 focus:ring-primary/50 transition-all placeholder:text-neutral-text-low/50"
            disabled={status === "loading"}
          />
          <button
            type="submit"
            disabled={status === "loading"}
            className="px-6 py-3 rounded-standard bg-primary text-white font-bold text-sm hover:bg-primary/90 transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 shrink-0"
          >
            {status === "loading" ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <ArrowRight className="w-4 h-4" />
            )}
            Join
          </button>
        </form>
        {status === "error" && (
          <p className="text-xs text-error mt-2 text-center">{message}</p>
        )}
      </div>
    </motion.div>
  );
}