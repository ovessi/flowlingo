import { createFileRoute } from "@tanstack/react-router";
import { 
  Users, 
  CreditCard, 
  Zap, 
  ArrowUpRight, 
  ArrowDownRight,
  Activity,
  BarChart3
} from "lucide-react";
import { getAdminStats, getRevenueData } from "../../admin.functions";
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  Cell
} from 'recharts';

export const Route = createFileRoute("/admin/")({
  loader: async () => {
    const [stats, revenue] = await Promise.all([
      getAdminStats(),
      getRevenueData()
    ]);
    return { stats, revenue };
  },
  component: AdminOverview,
});

function AdminOverview() {
  const { stats, revenue } = Route.useLoaderData();

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold tracking-tight mb-2">Dashboard Overview</h1>
        <p className="text-neutral-text-low">Welcome back, Admin. Here's what's happening today.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard 
          title="Total Users" 
          value={stats.totalUsers} 
          change="+12.5%" 
          trend="up" 
          icon={Users} 
        />
        <StatCard 
          title="Monthly Revenue" 
          value={stats.monthlyRevenue} 
          change="+8.2%" 
          trend="up" 
          icon={CreditCard} 
        />
        <StatCard 
          title="AI Actions" 
          value={stats.aiActions} 
          change="+24.1%" 
          trend="up" 
          icon={Zap} 
        />
        <StatCard 
          title="Avg. Latency" 
          value={stats.latency} 
          change="-4.3%" 
          trend="up" 
          icon={Activity} 
          inverseColor
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10 shadow-sm">
          <div className="flex items-center justify-between mb-8">
            <h3 className="font-bold">Revenue Growth</h3>
            <select className="bg-neutral-surface dark:bg-dark-bg text-sm px-3 py-1 rounded-lg outline-none border border-neutral-text-low/10">
              <option>Last 10 Months</option>
            </select>
          </div>
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={revenue.growth}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e5e5" />
                <XAxis 
                  dataKey="month" 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{ fontSize: 12, fill: '#888' }}
                  dy={10}
                />
                <YAxis hide />
                <Tooltip 
                  cursor={{ fill: 'rgba(99, 102, 241, 0.05)' }}
                  contentStyle={{ 
                    borderRadius: '12px', 
                    border: 'none', 
                    boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)' 
                  }}
                />
                <Bar dataKey="revenue" fill="#6366f1" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10">
          <h3 className="font-bold mb-6">Recent AI Actions</h3>
          <div className="space-y-4">
            {[
              { user: "user_482", action: "Translate (EN -> ES)", status: "Success", time: "2m ago" },
              { user: "user_912", action: "Analyze (Slang)", status: "Success", time: "5m ago" },
              { user: "user_103", action: "Suggest Reply", status: "Success", time: "8m ago" },
              { user: "user_552", action: "Translate (FR -> EN)", status: "Failed", time: "12m ago" },
              { user: "user_218", action: "Translate (JP -> EN)", status: "Success", time: "15m ago" },
            ].map((item, i) => (
              <div key={i} className="flex items-center justify-between p-3 rounded-xl hover:bg-neutral-surface dark:hover:bg-dark-bg transition-colors">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-neutral-surface dark:bg-dark-bg flex items-center justify-center text-xs font-medium">
                    {item.user.slice(-2)}
                  </div>
                  <div>
                    <div className="text-sm font-medium">{item.action}</div>
                    <div className="text-xs text-neutral-text-low">{item.user}</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className={`text-xs font-medium ${item.status === "Failed" ? "text-red-500" : "text-green-500"}`}>
                    {item.status}
                  </div>
                  <div className="text-[10px] text-neutral-text-low">{item.time}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ title, value, change, trend, icon: Icon, inverseColor = false }: any) {
  const isUp = trend === "up";
  const colorClass = inverseColor 
    ? (isUp ? "text-red-500" : "text-green-500")
    : (isUp ? "text-green-500" : "text-red-500");

  return (
    <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10 shadow-sm">
      <div className="flex items-center justify-between mb-4">
        <div className="p-2 rounded-lg bg-neutral-surface dark:bg-dark-bg">
          <Icon className="w-5 h-5 text-neutral-text-high dark:text-dark-text-high" />
        </div>
        <div className={`flex items-center text-xs font-bold ${colorClass}`}>
          {change}
          {isUp ? <ArrowUpRight className="w-3 h-3 ml-0.5" /> : <ArrowDownRight className="w-3 h-3 ml-0.5" />}
        </div>
      </div>
      <div>
        <div className="text-2xl font-bold tracking-tight">{value}</div>
        <div className="text-sm text-neutral-text-low mt-1">{title}</div>
      </div>
    </div>
  );
}
