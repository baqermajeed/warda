"use client";

import Link from "next/link";
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import {
  Clock,
  Gift,
  Heart,
  MessageSquare,
  Package,
  TrendingUp,
  Users,
  Wallet,
  type LucideIcon,
} from "lucide-react";
import { api } from "@/lib/api";
import type { Stats } from "@/lib/types";
import { orderStatus } from "@/lib/labels";
import { formatDate, money } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { GlassCard } from "@/components/ui/glass-card";
import { Badge } from "@/components/ui/badge";
import { Thumb } from "@/components/image-upload";

function Kpi({
  icon: Icon,
  label,
  value,
  hint,
  href,
}: {
  icon: LucideIcon;
  label: string;
  value: React.ReactNode;
  hint?: string;
  href?: string;
}) {
  const body = (
    <GlassCard className="flex h-full items-start gap-3 p-4 transition hover:-translate-y-0.5">
      <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-[var(--muted)] text-[var(--primary)]">
        <Icon className="h-5 w-5" />
      </div>
      <div className="min-w-0">
        <div className="text-xs text-[var(--muted-foreground)]">{label}</div>
        <div className="mt-1 text-xl font-extrabold">{value}</div>
        {hint ? <div className="mt-0.5 text-[11px] text-[var(--muted-foreground)]">{hint}</div> : null}
      </div>
    </GlassCard>
  );
  return href ? <Link href={href}>{body}</Link> : body;
}

export default function OverviewPage() {
  const { data, error, loading, reload } = useLoad(() => api<Stats>("/admin/stats"));

  return (
    <div className="space-y-5">
      <PageHeader title="نظرة عامة" subtitle="ملخص المتجر اليوم" onRefresh={reload} loading={loading} />
      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {!data && loading ? <LoadingBox /> : null}
      {data ? (
        <>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <Kpi icon={Package} label="طلبات اليوم" value={data.orders_today} hint={`الإجمالي ${data.orders_total}`} href="/app/orders" />
            <Kpi icon={Clock} label="بانتظار المراجعة" value={data.orders_pending} hint="طلبات حالتها «قيد المراجعة»" href="/app/orders?status=pending" />
            <Kpi icon={Wallet} label="مبيعات اليوم" value={money(data.revenue_today)} hint={`الإجمالي ${money(data.revenue_total)}`} />
            <Kpi icon={Users} label="الزبائن" value={data.customers_total} hint={`+${data.customers_new_week} هذا الأسبوع`} href="/app/customers" />
            <Kpi icon={Gift} label="الهدايا المعروضة" value={data.products_active} hint={`من أصل ${data.products_total}`} href="/app/products" />
            <Kpi icon={Heart} label="مرات الإضافة للمفضلة" value={data.favorites_total} />
            <Kpi icon={MessageSquare} label="رسائل دعم مفتوحة" value={data.tickets_open} href="/app/support" />
            <Kpi icon={TrendingUp} label="تذكيرات المناسبات" value={data.reminders_total} hint="أنشأها الزبائن" />
          </div>

          <GlassCard className="p-4">
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-sm font-bold">الطلبات والمبيعات — آخر 14 يومًا</h3>
              <span className="text-[11px] text-[var(--muted-foreground)]">بدون الطلبات الملغاة</span>
            </div>
            <div className="h-64" dir="ltr">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={data.series} margin={{ left: 0, right: 8, top: 8 }}>
                  <defs>
                    <linearGradient id="rev" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#ad8a83" stopOpacity={0.5} />
                      <stop offset="100%" stopColor="#ad8a83" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                  <XAxis dataKey="date" tickFormatter={(d: string) => d.slice(5)} fontSize={11} stroke="var(--muted-foreground)" />
                  <YAxis yAxisId="o" allowDecimals={false} fontSize={11} width={32} stroke="var(--muted-foreground)" />
                  <YAxis yAxisId="r" orientation="right" fontSize={11} width={64} stroke="var(--muted-foreground)" tickFormatter={(v: number) => v.toLocaleString("en-US")} />
                  <Tooltip
                    contentStyle={{ borderRadius: 14, border: "1px solid var(--border)", background: "var(--card)", direction: "rtl" }}
                    formatter={(value: number, name: string) =>
                      name === "revenue" ? [money(value), "المبيعات"] : [value, "الطلبات"]
                    }
                  />
                  <Area yAxisId="r" type="monotone" dataKey="revenue" stroke="#ad8a83" fill="url(#rev)" strokeWidth={2} />
                  <Area yAxisId="o" type="monotone" dataKey="orders" stroke="#4d0f14" fill="transparent" strokeWidth={2} />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </GlassCard>

          <div className="grid gap-4 lg:grid-cols-5">
            <GlassCard className="p-4 lg:col-span-3">
              <div className="mb-3 flex items-center justify-between">
                <h3 className="text-sm font-bold">أحدث الطلبات</h3>
                <Link href="/app/orders" className="text-xs text-[var(--accent)] hover:underline">
                  عرض الكل
                </Link>
              </div>
              {data.recent_orders.length === 0 ? (
                <p className="py-8 text-center text-sm text-[var(--muted-foreground)]">لا توجد طلبات بعد</p>
              ) : (
                <div className="divide-y divide-[var(--border)]">
                  {data.recent_orders.map((o) => {
                    const st = orderStatus(o.status);
                    return (
                      <Link key={o.id} href={`/app/orders/${o.id}`} className="flex items-center gap-3 py-2.5 hover:opacity-80">
                        <div className="min-w-0 flex-1">
                          <div className="text-sm font-semibold">
                            {o.code} · {o.recipient_name}
                          </div>
                          <div className="text-[11px] text-[var(--muted-foreground)]">{formatDate(o.created_at)}</div>
                        </div>
                        <Badge tone={st.tone}>{st.label}</Badge>
                        <div className="w-28 text-left text-sm font-bold">{money(o.total)}</div>
                      </Link>
                    );
                  })}
                </div>
              )}
            </GlassCard>

            <GlassCard className="p-4 lg:col-span-2">
              <h3 className="text-sm font-bold">الأكثر شهرة الآن</h3>
              <p className="mb-3 mt-1 text-[11px] leading-5 text-[var(--muted-foreground)]">
                الترتيب = (القطع المباعة × 2) + مرات الإضافة للمفضلة. الهدايا المثبّتة يدويًا تظهر أولًا.
              </p>
              <div className="space-y-2">
                {data.top_products.map((p, i) => (
                  <Link key={p.id} href={`/app/products?edit=${p.id}`} className="flex items-center gap-3 rounded-2xl p-1.5 hover:bg-[var(--muted)]/60">
                    <span className="w-5 text-center text-xs font-bold text-[var(--muted-foreground)]">{i + 1}</span>
                    <Thumb src={p.cover_image} className="h-10 w-10" />
                    <div className="min-w-0 flex-1">
                      <div className="truncate text-sm font-semibold">{p.title_ar}</div>
                      <div className="text-[11px] text-[var(--muted-foreground)]">
                        مباع {p.sold} · مفضلة {p.favorites}
                      </div>
                    </div>
                    <span className="text-xs font-bold">{money(p.price)}</span>
                  </Link>
                ))}
              </div>
            </GlassCard>
          </div>
        </>
      ) : null}
    </div>
  );
}
