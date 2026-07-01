import { createFileRoute } from "@tanstack/react-router";
import { 
  TrendingUp, 
  TrendingDown, 
  DollarSign, 
  CreditCard, 
  Users,
  Download
} from "lucide-react";
import { getRevenueData } from "../../admin.functions";
import { 
  PieChart, 
  Pie, 
  Cell, 
  ResponsiveContainer, 
  Tooltip,
  Legend,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid
} from 'recharts';

export const Route = createFileRoute("/admin/revenue")({
  loader: async () => await getRevenueData(),
  component: AdminRevenue,
});

function AdminRevenue() {
  const data = Route.useLoaderData();

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Revenue Dashboard</h1>
          <p className="text-neutral-text-low">Track MRR, churn, and subscription performance.</p>
        </div>
        <button className="flex items-center gap-2 bg-neutral-surface dark:bg-dark-surface border border-neutral-text-low/10 px-4 py-2 rounded-xl font-bold hover:bg-neutral-surface/80 transition-colors">
          <Download className="w-5 h-5" />
          Export Report
        </button>
      </div>

      {/* Revenue Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <RevenueCard 
          title="MRR (Monthly Recurring)" 
          value="$42,890" 
          change="+12% from last month" 
          icon={DollarSign} 
        />
        <RevenueCard 
          title="Avg. Revenue per User" 
          value="$6.42" 
          change="+2% from last month" 
          icon={Users} 
        />
        <RevenueCard 
          title="Churn Rate" 
          value="2.4%" 
          change="-0.5% from last month" 
          icon={TrendingDown} 
          isGood={true}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10 shadow-sm">
          <h3 className="font-bold mb-8">Revenue Growth (10 Months)</h3>
          <div className="h-80 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data.growth}>
                <defs>
                  <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6366f1" stopOpacity={0.1}/>
                    <stop offset="95%" stopColor="#6366f1" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e5e5" />
                <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#888'}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#888'}} />
                <Tooltip />
                <Area type="monotone" dataKey="revenue" stroke="#6366f1" strokeWidth={2} fillOpacity={1} fill="url(#colorRev)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10 shadow-sm">
          <h3 className="font-bold mb-8">Revenue by Plan</h3>
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={data.distribution}
                  innerRadius={60}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="share"
                >
                  {data.distribution.map((entry: any, index: number) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend iconType="circle" wrapperStyle={{ paddingTop: '20px' }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}

function RevenueCard({ title, value, change, icon: Icon, isGood = true }: any) {
  return (
    <div className="bg-white dark:bg-dark-surface p-6 rounded-2xl border border-neutral-text-low/10">
      <div className="flex items-center gap-3 mb-4">
        <div className="p-2 rounded-lg bg-neutral-surface dark:bg-dark-bg">
          <Icon className="w-5 h-5 text-neutral-text-high dark:text-dark-text-high" />
        </div>
        <div className="text-sm text-neutral-text-low">{title}</div>
      </div>
      <div className="text-3xl font-bold mb-2">{value}</div>
      <div className={`text-xs font-medium ${isGood ? "text-green-500" : "text-red-500"}`}>
        {change}
      </div>
    </div>
  );
}
