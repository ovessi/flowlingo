import { createFileRoute } from "@tanstack/react-router";
import { LegalLayout } from "../components/LegalLayout";

export const Route = createFileRoute("/ccpa")({
  component: CCPAPage,
});

function CCPAPage() {
  return (
    <LegalLayout title="California Privacy Rights (CCPA)" lastUpdated="June 29, 2026">
      <p>
        The California Consumer Privacy Act (CCPA) provides California residents with specific rights 
        regarding their personal information. This page explains those rights and how FlowLingo complies.
      </p>

      <h2>Information We Collect</h2>
      <p>
        In the past 12 months, we have collected categories of information such as identifiers, 
        commercial information, and internet activity as described in our Privacy Policy.
      </p>

      <h2>Your Rights</h2>
      <ul>
        <li><strong>Right to Know:</strong> You can request disclosure of the personal information we collect and use.</li>
        <li><strong>Right to Delete:</strong> You can request the deletion of your personal information.</li>
        <li><strong>Right to Opt-Out:</strong> You have the right to opt-out of the "sale" of your personal information (FlowLingo does not sell your personal data).</li>
        <li><strong>Right to Non-Discrimination:</strong> We will not discriminate against you for exercising your CCPA rights.</li>
      </ul>

      <h2>Exercising Your Rights</h2>
      <p>
        To exercise your rights, please submit a request to <strong>privacy@flowlingo.ai</strong>. 
        We will verify your identity before processing the request.
      </p>

      <h2>Authorized Agents</h2>
      <p>
        You may designate an authorized agent to make a request on your behalf. We will require 
        proof of authorization and verification of your identity.
      </p>
    </LegalLayout>
  );
}
