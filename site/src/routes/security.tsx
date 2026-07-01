import { createFileRoute } from "@tanstack/react-router";
import { LegalLayout } from "../components/LegalLayout";

export const Route = createFileRoute("/security")({
  component: SecurityPage,
});

function SecurityPage() {
  return (
    <LegalLayout title="Security Architecture" lastUpdated="June 29, 2026">
      <p>
        Security is at the core of FlowLingo. We protect your communication with enterprise-grade 
        standards and privacy-first engineering.
      </p>

      <h2>Encryption</h2>
      <p>
        All data transmitted between our keyboard extension and our servers is encrypted using 
        industry-standard TLS 1.3. At rest, sensitive data is encrypted using AES-256.
      </p>

      <h2>On-Device Processing</h2>
      <p>
        Whenever possible, we perform processing directly on your device to minimize data exposure. 
        Basic translations and local dictionary lookups never leave your phone.
      </p>

      <h2>Infrastructure</h2>
      <p>
        Our infrastructure is hosted on secure, SOC 2 Type II compliant cloud providers. 
        We use strict access controls, regular security audits, and automated vulnerability scanning.
      </p>

      <h2>AI Safety</h2>
      <p>
        Our AI models are designed to respect privacy. We do not use your personal conversations 
        to train our base models. Your "AI Memory" is your own and is never shared with other users.
      </p>

      <h2>Reporting Vulnerabilities</h2>
      <p>
        We value the contributions of the security community. If you believe you've found a security 
        vulnerability in FlowLingo, please report it to <strong>security@flowlingo.ai</strong>.
      </p>
    </LegalLayout>
  );
}
