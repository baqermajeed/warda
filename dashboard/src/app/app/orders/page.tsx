"use client";

import { Suspense, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { api } from "@/lib/api";
import type { OrderRow, Page } from "@/lib/types";
import { ORDER_STATUSES, orderStatus, paymentLabel } from "@/lib/labels";
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
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";

const PAGE_SIZE = 20;

function OrdersInner() {
  const router = useRouter();
  const params = useSearchParams();
  const [status, setStatus] = useState(params.get("status") ?? "");
  const [q, setQ] = useState("");
  const query = useDebounced(q);
  const [page, setPage] = useState(1);

  const list = useLoad(
    () => api<Page<OrderRow>>("/admin/orders", { query: { status, q: query, page, page_size: PAGE_SIZE } }),
    [status, query, page],
  );
  useEffect(() => setPage(1), [status, query]);

  const rows = list.data?.items ?? [];

  return (
    <div className="space-y-4">
      <PageHeader title="الطلبات" subtitle="كل طلبات التطبيق — اضغط على الطلب لعرض التفاصيل وتغيير الحالة" onRefresh={list.reload} loading={list.loading} />

      <GlassCard className="flex flex-wrap items-center gap-2 p-3">
        <SearchInput value={q} onChange={setQ} placeholder="رقم الطلب، اسم أو هاتف المستلم/الزبون…" />
        <div className="flex flex-wrap gap-1">
          <Button size="sm" variant={status === "" ? "default" : "secondary"} onClick={() => setStatus("")}>
            الكل
          </Button>
          {ORDER_STATUSES.map((s) => (
            <Button key={s.id} size="sm" variant={status === s.id ? "default" : "secondary"} onClick={() => setStatus(s.id)}>
              {s.label}
            </Button>
          ))}
        </div>
      </GlassCard>

      {list.error ? <ErrorBox message={list.error} onRetry={list.reload} /> : null}
      {list.loading && !list.data ? <LoadingBox /> : null}
      {list.data && rows.length === 0 ? <EmptyBox message="لا توجد طلبات مطابقة" /> : null}

      {rows.length > 0 ? (
        <>
          <DataTable
            rows={rows}
            rowKey={(o) => o.id}
            onRowClick={(o) => router.push(`/app/orders/${o.id}`)}
            columns={[
              { key: "code", label: "رقم الطلب", render: (o) => <span className="font-bold" dir="ltr">{o.code}</span> },
              {
                key: "recipient",
                label: "المستلم",
                render: (o) => (
                  <div className="grid gap-0.5">
                    <span>{o.recipient_name}</span>
                    <span className="text-[11px] text-[var(--muted-foreground)]" dir="ltr">
                      {o.recipient_phone}
                    </span>
                  </div>
                ),
              },
              { key: "gov", label: "المحافظة", render: (o) => (o.governorate ? appLabel(o.governorate) : "عنوان غير معروف") },
              { key: "items", label: "القطع", render: (o) => o.items_count },
              { key: "pay", label: "الدفع", render: (o) => <span className="text-xs">{paymentLabel(o.payment_method)}</span> },
              { key: "total", label: "الإجمالي", render: (o) => <span className="whitespace-nowrap font-semibold">{money(o.total)}</span> },
              {
                key: "status",
                label: "الحالة",
                render: (o) => {
                  const s = orderStatus(o.status);
                  return <Badge tone={s.tone}>{s.label}</Badge>;
                },
              },
              { key: "date", label: "التاريخ", render: (o) => <span className="whitespace-nowrap text-xs">{formatDate(o.created_at)}</span> },
            ]}
          />
          <Pagination page={page} pageSize={PAGE_SIZE} total={list.data?.total ?? 0} onPage={setPage} />
        </>
      ) : null}
    </div>
  );
}

export default function OrdersPage() {
  return (
    <Suspense fallback={<LoadingBox />}>
      <OrdersInner />
    </Suspense>
  );
}
