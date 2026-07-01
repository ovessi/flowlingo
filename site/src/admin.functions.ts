import { createServerFn } from "@tanstack/react-start";
import { redirect } from "@tanstack/react-router";

export const checkAdminAuth = createServerFn("GET", async () => {
  // Mock auth check
  const isAdmin = true; 
  if (!isAdmin) {
    throw redirect({ to: "/" });
  }
  return { authenticated: true };
});

// Mock data
const mockUsers = [
  { id: "u1", name: "Alex Johnson", email: "alex@example.com", tier: "Premium", status: "Active", joined: "2026-05-12" },
  { id: "u2", name: "Maria Garcia", email: "maria@example.com", tier: "Free", status: "Active", joined: "2026-06-01" },
  { id: "u3", name: "David Kim", email: "david@example.com", tier: "Premium", status: "Active", joined: "2026-06-15" },
  { id: "u4", name: "Emma Wilson", email: "emma@example.com", tier: "Family", status: "Active", joined: "2026-06-20" },
  { id: "u5", name: "James Brown", email: "james@example.com", tier: "Free", status: "Suspended", joined: "2026-04-10" },
];

export const getAdminStats = createServerFn("GET", async () => {
  return {
    totalUsers: "12,482",
    monthlyRevenue: "$48,290",
    aiActions: "842,019",
    latency: "248ms",
  };
});

export const getAdminUsers = createServerFn("GET", async () => {
  return mockUsers;
});

export const getRevenueData = createServerFn("GET", async () => {
  return {
    distribution: [
      { name: "Premium Monthly", share: 66, color: "#6366f1" },
      { name: "Premium Annual", share: 19, color: "#10b981" },
      { name: "Family Plan", share: 15, color: "#f59e0b" },
    ],
    growth: [
      { month: "Jan", revenue: 4000 },
      { month: "Feb", revenue: 5500 },
      { month: "Mar", revenue: 4800 },
      { month: "Apr", revenue: 6500 },
      { month: "May", revenue: 7800 },
      { month: "Jun", revenue: 7200 },
      { month: "Jul", revenue: 8500 },
      { month: "Aug", revenue: 9000 },
      { month: "Sep", revenue: 8800 },
      { month: "Oct", revenue: 10000 },
    ]
  };
});

export const getAIUsageData = createServerFn("GET", async () => {
  return {
    requests: "84,201",
    latency: "248ms",
    successRate: "99.98%",
    languages: [
      { pair: "EN -> ES", count: 24812, pct: 45 },
      { pair: "EN -> FR", count: 12402, pct: 22 },
      { pair: "ZH -> EN", count: 8291, pct: 15 },
      { pair: "JP -> EN", count: 6102, pct: 11 },
      { pair: "DE -> EN", count: 3821, pct: 7 },
    ],
    dailyUsage: [
      { day: "Mon", count: 4200 },
      { day: "Tue", count: 5100 },
      { day: "Wed", count: 4800 },
      { day: "Thu", count: 5800 },
      { day: "Fri", count: 6200 },
      { day: "Sat", count: 3500 },
      { day: "Sun", count: 2900 },
    ]
  };
});

export const suspendUser = createServerFn("POST", async (userId: string) => {
  console.log(`Suspending user: ${userId}`);
  return { success: true };
});

export const getSystemHealth = createServerFn("GET", async () => {
  return {
    services: [
      { name: "API Backend", status: "Operational", uptime: "99.99%", latency: "42ms", isDegraded: false },
      { name: "Turso Database", status: "Operational", uptime: "100%", latency: "18ms", isDegraded: false },
      { name: "AI Providers", status: "Degraded", uptime: "98.5%", latency: "842ms", isDegraded: true },
    ],
    logs: [
      { time: "23:59:12", service: "API", msg: "v1/ai/translate - 200 OK - 245ms", level: "INFO" },
      { time: "23:58:45", service: "AUTH", msg: "JWT verification successful for user_482", level: "INFO" },
      { time: "23:58:02", service: "AI", msg: "OpenAI timeout, failing over to Anthropic...", level: "WARN" },
      { time: "23:57:31", service: "DB", msg: "Connection pool healthy (12/20 active)", level: "INFO" },
      { time: "23:56:15", service: "API", msg: "v1/user/profile - 200 OK - 12ms", level: "INFO" },
      { time: "23:55:00", service: "SYS", msg: "Log rotation completed", level: "INFO" },
    ]
  };
});
