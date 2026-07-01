import { Globe, MessageCircle } from "lucide-react";
import { Link } from "@tanstack/react-router";

export function Footer() {
  return (
    <footer className="bg-neutral-bg dark:bg-dark-bg border-t border-neutral-text-low/10 pt-20 pb-12 px-6">
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-16">
        <div className="flex flex-col gap-6">
          <div className="flex items-center gap-2">
            <div className="bg-primary p-1.5 rounded-lg">
              <Globe className="w-6 h-6 text-white" />
            </div>
            <span className="text-xl font-bold tracking-tight">FlowLingo</span>
          </div>
          <p className="text-neutral-text-low dark:text-dark-text-low text-sm leading-relaxed max-w-xs">
            The intelligent keyboard that removes language barriers. Type naturally, speak globally.
          </p>
          <div className="flex gap-4">
            <a href="#" className="p-2 rounded-full bg-neutral-surface dark:bg-dark-surface hover:text-primary transition-colors">
              <MessageCircle className="w-5 h-5" />
            </a>
            <a href="#" className="p-2 rounded-full bg-neutral-surface dark:bg-dark-surface hover:text-primary transition-colors">
              <Globe className="w-5 h-5" />
            </a>
          </div>
        </div>

        <div>
          <h4 className="font-bold mb-6 text-neutral-text-high dark:text-dark-text-high">Product</h4>
          <ul className="flex flex-col gap-4 text-sm text-neutral-text-low dark:text-dark-text-low">
            <li><Link to="/features" className="hover:text-primary transition-colors">Features</Link></li>
            <li><Link to="/pricing" className="hover:text-primary transition-colors">Pricing</Link></li>
            <li><a href="#" className="hover:text-primary transition-colors">Enterprise</a></li>
            <li><a href="/#download" className="hover:text-primary transition-colors">Download</a></li>
          </ul>
        </div>

        <div>
          <h4 className="font-bold mb-6 text-neutral-text-high dark:text-dark-text-high">Company</h4>
          <ul className="flex flex-col gap-4 text-sm text-neutral-text-low dark:text-dark-text-low">
            <li><a href="#" className="hover:text-primary transition-colors">About Us</a></li>
            <li><a href="#" className="hover:text-primary transition-colors">Careers</a></li>
            <li><Link to="/blog" className="hover:text-primary transition-colors">Blog</Link></li>
            <li><Link to="/faq" className="hover:text-primary transition-colors">FAQ</Link></li>
          </ul>
        </div>

        <div>
          <h4 className="font-bold mb-6 text-neutral-text-high dark:text-dark-text-high">Legal</h4>
          <ul className="flex flex-col gap-4 text-sm text-neutral-text-low dark:text-dark-text-low">
            <li><Link to="/privacy" className="hover:text-primary transition-colors">Privacy Policy</Link></li>
            <li><Link to="/terms" className="hover:text-primary transition-colors">Terms of Service</Link></li>
            <li><Link to="/cookie-policy" className="hover:text-primary transition-colors">Cookie Policy</Link></li>
            <li><Link to="/security" className="hover:text-primary transition-colors">Security</Link></li>
            <li><Link to="/gdpr" className="hover:text-primary transition-colors">GDPR</Link></li>
            <li><Link to="/ccpa" className="hover:text-primary transition-colors">CCPA</Link></li>
            <li><Link to="/accessibility" className="hover:text-primary transition-colors">Accessibility</Link></li>
          </ul>
        </div>
      </div>

      <div className="max-w-7xl mx-auto pt-8 border-t border-neutral-text-low/10 flex flex-col md:flex-row justify-between items-center gap-6 text-xs text-neutral-text-low dark:text-dark-text-low font-medium uppercase tracking-widest">
        <p>© 2026 FlowLingo. All rights reserved.</p>
        <p>Built with ❤️ for a borderless world.</p>
      </div>
    </footer>
  );
}
