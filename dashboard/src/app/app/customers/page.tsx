"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import type { Page, UserRow } from "@/lib/types";
import { appLabel } from "@/lib/app-labels";
import { formatDate, money } from "@/lib/utils";
import { useDebounced, useLoad } from "@/hooks/use-load";
import {
  DataTable,
  EmptyBox,
  ErrorBox,
  LoadingBox,
  PageHeader,
  Pagination,
  SearchInput,
} from "@/components/page-header";
import { Badge } from "@/components/ui/badge";
import { GlassCard } from "@/components/ui/glass-card";
import { Select } from "@/components/ui/input";

const PAGE_SIZE = 20;

export default function CustomersPage() {
  const router = useRouter();
  const [q, setQ] = useState("");
  const query = useDebounced(q);
  const [role, setRole] = useState("");
  const [page, setPage] = useState(1);
  const list = useLoad(
    () => api<Page<UserRow>>("/admin/users", { query: { q: query, role, page, page_size: PAGE_SIZE } }),
    [query, role, page],
  );
  useEffect(() => setPage(1), [query, role]);
  const rows = list.data?.items ?? [];

  return (
    <div className="space-y-4">
      <PageHeader title="الزبائن" subtitle="حسابات التطبيق — اضغط على الزبون لعرض طلباته وإدارة حسابه" onRefresh={list.reload} loading={list.loading} />
      <GlassCard className="flex flex-wrap gap-2 p-3">
        <SearchInput value={q} onChange={setQ} placeholder="بحث بالاسم أو الهاتف…" />
        <Select className="w-auto" value={role} onChange={(e) => setRole(e.target.value)}>
          <option value="">الكل</option>
          <option value="customer">الزبائن</option>
          <option value="admin">حسابات الإدارة</option>
          <option value="inactive">الموقوفة</option>
        </Select>
      </GlassCard>

      {list.error ? <ErrorBox message={list.error} onRetry={list.reload} /> : null}
      {list.loading && !list.data ? <LoadingBox /> : null}
      {list.data && rows.length === 0 ? <EmptyBox message="لا توجد حسابات مطابقة" /> : null}

      {rows.length > 0 ? (
        <>
          <DataTable
            rows={rows}
            rowKey={(u) => u.id}
            onRowClick={(u) => router.push(`/app/customers/${u.id}`)}
            columns={[
              {
                key: "name",
                label: "الاسم",
                render: (u) => (
                  <div className="flex items-center gap-2">
                    <span className="font-semibold">{u.name || "—"}</span>
                    {u.is_admin ? <Badge tone="rose">إدارة</Badge> : null}
                    {!u.is_active ? <Badge tone="red">موقوف</Badge> : null}
                  </div>
                ),
              },
              { key: "phone", label: "الهاتف", render: (u) => <span dir="ltr">{u.phone}</span> },
              { key: "gov", label: "المحافظة", render: (u) => appLabel(u.governorate) },
              { key: "orders", label: "الطلبات", render: (u) => u.orders_count },
              { key: "spent", label: "المشتريات", render: (u) => <span className="whitespace-nowrap">{money(u.total_spent)}</span> },
              { key: "notif", label: "الإشعارات", render: (u) => (u.notifications_enabled ? "مفعّلة" : "متوقفة") },
              { key: "date", label: "التسجيل", render: (u) => <span className="whitespace-nowrap text-xs">{formatDate(u.created_at, false)}</span> },
            ]}
          />
          <Pagination page={page} pageSize={PAGE_SIZE} total={list.data?.total ?? 0} onPage={setPage} />
        </>
      ) : null}
    </div>
  );
}
