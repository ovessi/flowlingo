import { createFileRoute } from "@tanstack/react-router";
import { LegalLayout } from "../components/LegalLayout";

export const Route = createFileRoute("/accessibility")({
  component: AccessibilityPage,
});

function AccessibilityPage() {
  return (
    <LegalLayout title="Accessibility Statement" lastUpdated="June 29, 2026">
      <p>
        FlowLingo is committed to ensuring digital accessibility for people with disabilities. 
        We are continually improving the user experience for everyone and applying the relevant 
        accessibility standards.
      </p>

      <h2>Conformance Status</h2>
      <p>
        The Web Content Accessibility Guidelines (WCAG) defines requirements for designers and developers 
        to improve accessibility for people with disabilities. FlowLingo aims to be conformant with 
        <strong>WCAG 2.1 level AA</strong>.
      </p>

      <h2>Keyboard Experience</h2>
      <p>
        Our keyboard extension supports native OS accessibility features, including Screen Readers 
        (VoiceOver on iOS, TalkBack on Android), High Contrast modes, and dynamic text sizing.
      </p>

      <h2>Feedback</h2>
      <p>
        We welcome your feedback on the accessibility of FlowLingo. Please let us know if you encounter 
        accessibility barriers by contacting us at <strong>accessibility@flowlingo.ai</strong>. 
        We try to respond to feedback within 5 business days.
      </p>

      <h2>Technical Specifications</h2>
      <p>
        Accessibility of FlowLingo relies on the following technologies to work with the particular 
        combination of web browser and any assistive technologies or plugins installed on your computer:
      </p>
      <ul>
        <li>HTML</li>
        <li>WAI-ARIA</li>
        <li>CSS</li>
        <li>JavaScript</li>
      </ul>
    </LegalLayout>
  );
}
