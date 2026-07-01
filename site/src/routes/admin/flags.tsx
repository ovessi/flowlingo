import { createFileRoute } from "@tanstack/react-router";
import { 
  ToggleRight, 
  ToggleLeft, 
  Info,
  Plus
} from "lucide-react";
import { useState } from "react";

export const Route = createFileRoute("/admin/flags")({
  component: AdminFlags,
});

const initialFlags = [
  { id: "f1", key: "enable_gpt4o", description: "Use GPT-4o for all translations", enabled: true, rollout: 100 },
  { id: "f2", key: "ai_suggested_replies", description: "Enable suggested replies in keyboard", enabled: true, rollout: 50 },
  { id: "f3", key: "cultural_context_analysis", description: "Cultures/slang analysis feature", enabled: false, rollout: 0 },
  { id: "f4", key: "offline_packs_beta", description: "Access to offline language packs", enabled: true, rollout: 10 },
  { id: "f5", key: "enterprise_sso", description: "SSO login for enterprise customers", enabled: false, rollout: 0 },
];

function AdminFlags() {
  const [flags, setFlags] = useState(initialFlags);

  const toggleFlag = (id: string) => {
    setFlags(flags.map(f => f.id === id ? { ...f, enabled: !f.enabled } : f));
  };

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Feature Flags</h1>
          <p className="text-neutral-text-low">Enable features globally or for a percentage of users.</p>
        </div>
        <button className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-xl font-bold hover:bg-primary/90 transition-colors">
          <Plus className="w-5 h-5" />
          New Flag
        </button>
      </div>

      <div className="bg-white dark:bg-dark-surface rounded-2xl border border-neutral-text-low/10 divide-y divide-neutral-text-low/10 shadow-sm">
        {flags.map((flag) => (
          <div key={flag.id} className="p-6 flex items-center justify-between hover:bg-neutral-surface/30 transition-colors">
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1">
                <code className="text-sm font-bold bg-neutral-surface dark:bg-dark-bg px-2 py-0.5 rounded text-primary">
                  {flag.key}
                </code>
                {flag.rollout < 100 && flag.rollout > 0 && (
                  <span className="text-[10px] font-bold uppercase tracking-widest bg-amber-500/10 text-amber-500 px-2 py-0.5 rounded">
                    Partial Rollout: {flag.rollout}%
                  </span>
                )}
              </div>
              <p className="text-sm text-neutral-text-low">{flag.description}</p>
            </div>
            <div className="flex items-center gap-8">
              <div className="hidden md:block">
                <div className="text-[10px] text-neutral-text-low uppercase font-bold mb-1">Rollout %</div>
                <input 
                  type="range" 
                  min="0" 
                  max="100" 
                  value={flag.rollout} 
                  className="w-32 h-1.5 bg-neutral-surface dark:bg-dark-bg rounded-lg appearance-none cursor-pointer accent-primary"
                  readOnly
                />
              </div>
              <button 
                onClick={() => toggleFlag(flag.id)}
                className={`transition-colors ${flag.enabled ? 'text-primary' : 'text-neutral-text-low'}`}
              >
                {flag.enabled ? <ToggleRight className="w-12 h-12" /> : <ToggleLeft className="w-12 h-12" />}
              </button>
            </div>
          </div>
        ))}
      </div>

      <div className="p-4 rounded-xl bg-primary/5 border border-primary/10 flex items-start gap-3">
        <Info className="w-5 h-5 text-primary mt-0.5 shrink-0" />
        <div className="text-sm text-neutral-text-high dark:text-dark-text-high">
          <strong>Tip:</strong> Feature flags are cached on the keyboard extension for 5 minutes. Changes might not be immediate for all users.
        </div>
      </div>
    </div>
  );
}
