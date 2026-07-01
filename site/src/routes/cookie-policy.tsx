import { createFileRoute } from "@tanstack/react-router";
import { LegalLayout } from "../components/LegalLayout";

export const Route = createFileRoute("/cookie-policy")({
  component: CookiePolicyPage,
});

function CookiePolicyPage() {
  return (
    <LegalLayout title="Cookie Policy" lastUpdated="June 29, 2026">
      <p>
        FlowLingo uses cookies and similar technologies to provide, protect, and improve our services. 
        This policy explains how and why we use these technologies.
      </p>

      <h2>What are cookies?</h2>
      <p>
        Cookies are small text files that are stored on your device when you visit a website. 
        They help us remember your preferences and understand how you interact with our site.
      </p>

      <h2>How we use cookies</h2>
      <ul>
        <li><strong>Essential cookies:</strong> Required for the website to function correctly (e.g., authentication, security).</li>
        <li><strong>Performance cookies:</strong> Help us understand how visitors use the site so we can improve it.</li>
        <li><strong>Functional cookies:</strong> Remember your settings and preferences.</li>
        <li><strong>Analytics cookies:</strong> Used to track site usage and performance via anonymous data.</li>
      </ul>

      <h2>Managing your preferences</h2>
      <p>
        You can control or reset your cookies through your web browser settings. 
        Note that disabling certain cookies may affect the functionality of our website.
      </p>

      <h2>Changes to this policy</h2>
      <p>
        We may update this Cookie Policy from time to time. Any changes will be posted on this page 
        with an updated "Last Updated" date.
      </p>
    </LegalLayout>
  );
}
