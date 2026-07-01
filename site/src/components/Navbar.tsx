import { Link } from "@tanstack/react-router";
import { Globe, Menu, X } from "lucide-react";
import { useState } from "react";

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-neutral-bg/80 dark:bg-dark-bg/80 backdrop-blur-md border-b border-neutral-text-low/10">
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2 group">
          <div className="bg-primary p-1.5 rounded-lg group-hover:scale-105 transition-transform">
            <Globe className="w-6 h-6 text-white" />
          </div>
          <span className="text-xl font-bold tracking-tight">FlowLingo</span>
        </Link>

        {/* Desktop Menu */}
        <div className="hidden md:flex items-center gap-8">
          <Link to="/features" className="text-sm font-medium hover:text-primary transition-colors">Features</Link>
          <Link to="/pricing" className="text-sm font-medium hover:text-primary transition-colors">Pricing</Link>
          <Link to="/docs" className="text-sm font-medium hover:text-primary transition-colors">Docs</Link>
          <Link to="/faq" className="text-sm font-medium hover:text-primary transition-colors">FAQ</Link>
          <a 
            href="/#download" 
            className="rounded-standard bg-primary px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-primary/90 transition-all"
          >
            Download
          </a>
        </div>

        {/* Mobile Toggle */}
        <button 
          className="md:hidden p-2 text-neutral-text-high dark:text-dark-text-high"
          onClick={() => setIsOpen(!isOpen)}
        >
          {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Menu */}
      {isOpen && (
        <div className="md:hidden bg-neutral-bg dark:bg-dark-bg border-b border-neutral-text-low/10 px-6 py-6 flex flex-col gap-4 animate-in slide-in-from-top duration-200">
          <Link to="/features" className="text-lg font-medium hover:text-primary" onClick={() => setIsOpen(false)}>Features</Link>
          <Link to="/pricing" className="text-lg font-medium hover:text-primary" onClick={() => setIsOpen(false)}>Pricing</Link>
          <Link to="/docs" className="text-lg font-medium hover:text-primary" onClick={() => setIsOpen(false)}>Docs</Link>
          <Link to="/faq" className="text-lg font-medium hover:text-primary" onClick={() => setIsOpen(false)}>FAQ</Link>
          <a 
            href="/#download" 
            className="rounded-standard bg-primary px-4 py-3 text-center text-lg font-semibold text-white shadow-sm"
            onClick={() => setIsOpen(false)}
          >
            Download Now
          </a>
        </div>
      )}
    </nav>
  );
}
