import { createFileRoute } from "@tanstack/react-router";
import { LegalLayout } from "../components/LegalLayout";

export const Route = createFileRoute("/gdpr")({
  component: GDPRPage,
});

function GDPRPage() {
  return (
    <LegalLayout title="GDPR Compliance" lastUpdated="June 29, 2026">
      <p>
        At FlowLingo, we are committed to protecting the privacy and personal data of our users in the European Union 
        in accordance with the General Data Protection Regulation (GDPR).
      </p>

      <h2>Your Data Rights</h2>
      <p>Under GDPR, you have the following rights regarding your personal data:</p>
      <ul>
        <li><strong>Right of Access:</strong> You can request a copy of the personal data we hold about you.</li>
        <li><strong>Right to Rectification:</strong> You can ask us to correct inaccurate or incomplete data.</li>
        <li><strong>Right to Erasure:</strong> You can request that we delete your personal data under certain conditions.</li>
        <li><strong>Right to Restriction:</strong> You can ask us to limit how we process your data.</li>
        <li><strong>Right to Data Portability:</strong> You can request your data in a structured, machine-readable format.</li>
        <li><strong>Right to Object:</strong> You can object to the processing of your data for specific purposes.</li>
      </ul>

      <h2>Data Processing</h2>
      <p>
        We only process data when we have a legal basis to do so, such as fulfilling a contract, 
        complying with legal obligations, or with your explicit consent.
      </p>

      <h2>International Transfers</h2>
      <p>
        When data is transferred outside the EEA, we ensure appropriate safeguards are in place 
        (e.g., Standard Contractual Clauses) to maintain a high level of protection.
      </p>

      <h2>Contact Our DPO</h2>
      <p>
        If you have questions about your data or wish to exercise your rights, please contact our 
        Data Protection Officer at <strong>privacy@flowlingo.ai</strong>.
      </p>
    </LegalLayout>
  );
}
