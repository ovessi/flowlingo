import { createFileRoute } from "@tanstack/react-router";
import { 
  Zap, 
  Clock, 
  Globe, 
  AlertCircle,
  Cpu
} from "lucide-react";
import { getAIUsageData } from "../../admin.functions";
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend
} from 'recharts';

export const Route = createFileRoute("/admin/ai")({
  loader: async () => await getAIUsageData(),
  component: AdminAI,
});

function AdminAI() {
  const data = Route.useLoaderData();

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold tracking-tight mb-2">AI Usage Analytics</h1>
        <p className="text-neutral-text-low">Monitor AI performance, costs, and language popularity.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <AICard title="Total Requests" value={data.requests} sub="Last 24h" icon={Zap} />
        <AICard title="Avg. Response" value={data.latency} sub="Global Avg" icon={Clock} />
        <AICard title="Success Rate" value={data.successRate} sub="High Reliability" icon={Cpu} />
        <AICard title="Active Models" value="4" sub="OpenAI, Anthropic..." icon={Globe} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10 shadow-sm">
          <h3 className="font-bold mb-8">Daily Request Volume</h3>
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.dailyUsage}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e5e5" />
                <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#888'}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#888'}} />
                <Tooltip cursor={{fill: 'rgba(99, 102, 241, 0.05)'}} />
                <Bar dataKey="count" fill="#6366f1" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10 shadow-sm">
          <h3 className="font-bold mb-6">Popular Language Pairs</h3>
          <div className="space-y-4">
            {data.languages.map((lang: any) => (
              <div key={lang.pair} className="flex items-center gap-4">
                <div className="w-16 text-sm font-bold">{lang.pair}</div>
                <div className="flex-1 h-2 bg-neutral-surface dark:bg-dark-bg rounded-full overflow-hidden">
                  <div className="h-full bg-primary" style={{ width: `${lang.pct}%` }} />
                </div>
                <div className="w-16 text-right text-xs text-neutral-text-low">{lang.count.toLocaleString()}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10 shadow-sm">
          <h3 className="font-bold mb-6">Provider Failovers (7d)</h3>
          <div className="h-48 flex items-end justify-between px-2">
            {[2, 0, 1, 5, 0, 0, 1].map((count, i) => (
              <div key={i} className="w-8 flex flex-col items-center gap-2">
                <div 
                  className={`w-full rounded-t-sm transition-all ${count > 2 ? 'bg-red-500' : 'bg-primary/40'}`} 
                  style={{ height: `${count * 20 + 5}px` }}
                />
                <span className="text-[10px] text-neutral-text-low">Day {i+1}</span>
              </div>
            ))}
          </div>
          <div className="mt-6 flex items-center gap-2 text-xs text-neutral-text-low">
            <AlertCircle className="w-4 h-4 text-amber-500" />
            Most failovers caused by OpenAI latency spikes on Day 4.
          </div>
        </div>
      </div>
    </div>
  );
}

function AICard({ title, value, sub, icon: Icon }: any) {
  return (
    <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10">
      <Icon className="w-5 h-5 text-primary mb-4" />
      <div className="text-2xl font-bold">{value}</div>
      <div className="text-xs font-medium text-neutral-text-high dark:text-dark-text-high mt-1">{title}</div>
      <div className="text-[10px] text-neutral-text-low">{sub}</div>
    </div>
  );
}
