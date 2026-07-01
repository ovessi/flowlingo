import { createFileRoute } from "@tanstack/react-router";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";

export const Route = createFileRoute("/privacy")({
  component: PrivacyPage,
});

function PrivacyPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24 px-6">
        <article className="max-w-3xl mx-auto prose dark:prose-invert prose-neutral prose-headings:italic prose-headings:font-bold prose-p:text-neutral-text-low prose-li:text-neutral-text-low">
          <h1 className="text-4xl sm:text-5xl font-bold mb-8 italic">Privacy Policy</h1>
          <p className="text-sm opacity-50 mb-12 uppercase tracking-widest font-bold">Last Updated: June 20, 2026</p>
          
          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">1. Our Commitment to Privacy</h2>
            <p className="leading-relaxed">
              At FlowLingo, privacy is not an afterthought—it's the foundation of our product. We understand that your communication is personal, and our smart keyboard is designed to respect that boundary.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">2. Data We DO NOT Collect</h2>
            <ul className="list-disc pl-6 space-y-4">
              <li><strong>Keystrokes:</strong> We never log or store your raw keystrokes.</li>
              <li><strong>Passive Input:</strong> We do not analyze any text that is not explicitly sent for translation or analysis.</li>
              <li><strong>Personal Identifiers:</strong> We do not link your translation history to your real-world identity unless you create a Premium account.</li>
            </ul>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">3. Data We Collect & How We Use It</h2>
            <p className="leading-relaxed mb-4">
              To provide our services, we process:
            </p>
            <ul className="list-disc pl-6 space-y-4">
              <li><strong>Triggered AI Actions:</strong> When you tap "Translate" or "Analyze", that specific text snippet is sent to our secure AI processing layer.</li>
              <li><strong>Usage Analytics:</strong> We track counts of AI actions (e.g., "5 translations today") to manage billing and improve service reliability.</li>
              <li><strong>Device Info:</strong> Basic OS version and language settings to ensure the keyboard functions correctly.</li>
            </ul>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">4. Security</h2>
            <p className="leading-relaxed">
              All data transmitted for AI processing is encrypted using industry-standard TLS. Snippets sent for analysis are processed in transient memory and are deleted immediately after the response is generated.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">5. Your Rights</h2>
            <p className="leading-relaxed">
              Under GDPR and CCPA, you have the right to access, export, or delete any data we hold about you. You can manage these settings directly in the FlowLingo companion app.
            </p>
          </section>
        </article>
      </main>
      <Footer />
    </div>
  );
}
