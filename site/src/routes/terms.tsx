import { createFileRoute } from "@tanstack/react-router";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";

export const Route = createFileRoute("/terms")({
  head: () => ({
    meta: [
      { title: "Terms of Service — FlowLingo" },
      { name: "description", content: "FlowLingo's terms of service govern your use of the AI keyboard platform, including subscription terms, acceptable use, and limitations of liability." },
    ],
  }),
  component: TermsPage,
});

function TermsPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-32 pb-24 px-6">
        <article className="max-w-3xl mx-auto prose dark:prose-invert prose-neutral prose-headings:italic prose-headings:font-bold prose-p:text-neutral-text-low prose-li:text-neutral-text-low">
          <h1 className="text-4xl sm:text-5xl font-bold mb-8 italic">Terms of Service</h1>
          <p className="text-sm opacity-50 mb-12 uppercase tracking-widest font-bold">Last Updated: June 20, 2026</p>
          
          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">1. Acceptance of Terms</h2>
            <p className="leading-relaxed">
              By installing the FlowLingo smart keyboard and using our services, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">2. Use of AI Services</h2>
            <p className="leading-relaxed mb-4">
              FlowLingo provides AI-powered communication tools. You understand that:
            </p>
            <ul className="list-disc pl-6 space-y-4">
              <li>AI outputs may occasionally contain errors, inaccuracies, or culturally insensitive phrasing.</li>
              <li>The service depends on third-party AI providers (e.g., OpenAI, Anthropic).</li>
              <li>You are responsible for the content you transmit using our keyboard.</li>
            </ul>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">3. Subscription & Billing</h2>
            <p className="leading-relaxed mb-4">
              Premium services are billed on a monthly or annual basis.
            </p>
            <ul className="list-disc pl-6 space-y-4">
              <li>Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.</li>
              <li>Payments are processed via Apple IAP, Google Play, or Stripe.</li>
              <li>Refunds are subject to the policies of the respective payment gateway.</li>
            </ul>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">4. Acceptable Use</h2>
            <p className="leading-relaxed">
              You agree not to use FlowLingo for any illegal activities, to transmit malware, or to harass others. We reserve the right to suspend accounts that violate our community standards or abuse the AI processing limits.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6 italic">5. Limitation of Liability</h2>
            <p className="leading-relaxed">
              FlowLingo is provided "as is". We are not liable for any damages arising from the use of our keyboard, including but not limited to communication errors, data loss, or service interruptions.
            </p>
          </section>
        </article>
      </main>
      <Footer />
    </div>
  );
}
