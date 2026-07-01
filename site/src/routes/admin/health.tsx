import { createFileRoute } from "@tanstack/react-router";
import { 
  ShieldCheck, 
  ShieldAlert, 
  Activity, 
  Server,
  Database,
  Cloud,
  RefreshCw
} from "lucide-react";
import { getSystemHealth } from "../../admin.functions";

export const Route = createFileRoute("/admin/health")({
  loader: async () => await getSystemHealth(),
  component: AdminHealth,
});

function AdminHealth() {
  const { services, logs } = Route.useLoaderData();

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">System Health</h1>
          <p className="text-neutral-text-low">Real-time status of services and infrastructure.</p>
        </div>
        <button className="flex items-center gap-2 bg-neutral-surface dark:bg-dark-surface border border-neutral-text-low/10 px-4 py-2 rounded-xl font-bold hover:bg-neutral-surface/80 transition-colors">
          <RefreshCw className="w-4 h-4" />
          Refresh
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {services.map((svc: any) => (
          <HealthCard 
            key={svc.name}
            title={svc.name} 
            status={svc.status} 
            uptime={svc.uptime} 
            latency={svc.latency} 
            icon={svc.name.includes("API") ? Server : svc.name.includes("DB") ? Database : Cloud} 
            isDegraded={svc.isDegraded} 
          />
        ))}
      </div>

      <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10">
        <h3 className="font-bold mb-6">Service Logs</h3>
        <div className="space-y-2 font-mono text-[11px]">
          {logs.map((log: any, i: number) => (
            <div key={i} className="flex gap-4 p-2 rounded hover:bg-neutral-surface dark:hover:bg-dark-bg transition-colors">
              <span className="text-neutral-text-low">{log.time}</span>
              <span className={`font-bold w-12 ${log.level === 'WARN' ? 'text-amber-500' : 'text-primary'}`}>{log.level}</span>
              <span className="text-neutral-text-high dark:text-dark-text-high">{log.msg}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function HealthCard({ title, status, uptime, latency, icon: Icon, isDegraded = false }: any) {
  return (
    <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10">
      <div className="flex items-center justify-between mb-6">
        <div className="p-2 rounded-lg bg-neutral-surface dark:bg-dark-bg">
          <Icon className="w-6 h-6 text-neutral-text-high dark:text-dark-text-high" />
        </div>
        <div className={`flex items-center gap-1.5 text-xs font-bold ${isDegraded ? 'text-amber-500' : 'text-green-500'}`}>
          {isDegraded ? <ShieldAlert className="w-4 h-4" /> : <ShieldCheck className="w-4 h-4" />}
          {status}
        </div>
      </div>
      <h3 className="font-bold text-lg mb-4">{title}</h3>
      <div className="grid grid-cols-2 gap-4 border-t border-neutral-text-low/5 pt-4">
        <div>
          <div className="text-[10px] text-neutral-text-low uppercase font-bold">Uptime</div>
          <div className="text-sm font-bold">{uptime}</div>
        </div>
        <div>
          <div className="text-[10px] text-neutral-text-low uppercase font-bold">Latency</div>
          <div className="text-sm font-bold">{latency}</div>
        </div>
      </div>
    </div>
  );
}
