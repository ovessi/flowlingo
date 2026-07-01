import { createFileRoute } from "@tanstack/react-router";
import { 
  Search, 
  Filter, 
  MoreVertical, 
  UserPlus,
  Shield,
  ShieldAlert,
  Ban,
  Trash2
} from "lucide-react";
import { useState } from "react";
import { getAdminUsers, suspendUser } from "../../admin.functions";

export const Route = createFileRoute("/admin/users")({
  loader: async () => await getAdminUsers(),
  component: AdminUsers,
});

function AdminUsers() {
  const initialUsers = Route.useLoaderData();
  const [users, setUsers] = useState(initialUsers);
  const [search, setSearch] = useState("");

  const handleSuspend = async (userId: string) => {
    if (confirm("Are you sure you want to suspend this user?")) {
      await suspendUser(userId);
      setUsers(users.map(u => u.id === userId ? { ...u, status: "Suspended" } : u));
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">User Management</h1>
          <p className="text-neutral-text-low">Manage your users, their tiers, and account status.</p>
        </div>
        <button className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-xl font-bold hover:bg-primary/90 transition-colors">
          <UserPlus className="w-5 h-5" />
          Add User
        </button>
      </div>

      <div className="bg-white dark:bg-dark-surface rounded-2xl border border-neutral-text-low/10 overflow-hidden shadow-sm">
        {/* Filters */}
        <div className="p-4 border-b border-neutral-text-low/10 flex flex-col md:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-text-low" />
            <input 
              type="text" 
              placeholder="Search users..." 
              className="w-full pl-10 pr-4 py-2 bg-neutral-surface dark:bg-dark-bg rounded-xl outline-none border border-neutral-text-low/5 focus:border-primary transition-colors"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <div className="flex gap-2">
            <button className="flex items-center gap-2 px-4 py-2 bg-neutral-surface dark:bg-dark-bg rounded-xl text-sm font-medium border border-neutral-text-low/5">
              <Filter className="w-4 h-4" />
              Filter
            </button>
            <select className="px-4 py-2 bg-neutral-surface dark:bg-dark-bg rounded-xl text-sm font-medium border border-neutral-text-low/5 outline-none">
              <option>All Tiers</option>
              <option>Premium</option>
              <option>Family</option>
              <option>Free</option>
            </select>
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-neutral-surface dark:bg-dark-bg/50 text-xs font-bold uppercase tracking-widest text-neutral-text-low border-b border-neutral-text-low/10">
                <th className="px-6 py-4">User</th>
                <th className="px-6 py-4">Tier</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4">Joined</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-neutral-text-low/10">
              {users.map((user: any) => (
                <tr key={user.id} className="hover:bg-neutral-surface/50 dark:hover:bg-dark-bg/30 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold">
                        {user.name.split(" ").map(n => n[0]).join("")}
                      </div>
                      <div>
                        <div className="font-bold text-sm">{user.name}</div>
                        <div className="text-xs text-neutral-text-low">{user.email}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm font-medium">
                    <span className={`px-2 py-1 rounded-full text-[10px] uppercase tracking-wider ${
                      user.tier === "Premium" ? "bg-primary/10 text-primary" : 
                      user.tier === "Family" ? "bg-emerald-500/10 text-emerald-500" : 
                      "bg-neutral-surface text-neutral-text-low"
                    }`}>
                      {user.tier}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm">
                    <div className="flex items-center gap-1.5">
                      <div className={`w-1.5 h-1.5 rounded-full ${user.status === "Active" ? "bg-green-500" : "bg-red-500"}`} />
                      {user.status}
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm text-neutral-text-low">{user.joined}</td>
                  <td className="px-6 py-4 text-right relative group/actions">
                    <button className="p-2 hover:bg-neutral-surface dark:hover:bg-dark-bg rounded-lg transition-colors">
                      <MoreVertical className="w-5 h-5 text-neutral-text-low" />
                    </button>
                    <div className="absolute right-0 top-12 z-20 hidden group-focus-within/actions:block bg-white dark:bg-dark-surface border border-neutral-text-low/10 shadow-xl rounded-xl p-1 min-w-[140px]">
                      <button 
                        onClick={() => handleSuspend(user.id)}
                        className="w-full flex items-center gap-2 px-3 py-2 text-sm text-red-500 hover:bg-red-50 dark:hover:bg-red-900/10 rounded-lg transition-colors"
                      >
                        <Ban className="w-4 h-4" />
                        Suspend
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="p-4 border-t border-neutral-text-low/10 flex items-center justify-between text-sm text-neutral-text-low">
          <span>Showing 1 to 8 of 12,482 users</span>
          <div className="flex gap-2">
            <button className="px-3 py-1 rounded-lg border border-neutral-text-low/10 hover:bg-neutral-surface disabled:opacity-50" disabled>Previous</button>
            <button className="px-3 py-1 rounded-lg border border-neutral-text-low/10 hover:bg-neutral-surface">Next</button>
          </div>
        </div>
      </div>
    </div>
  );
}
