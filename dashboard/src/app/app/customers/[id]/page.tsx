"use client";

import { use, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowRight, Bell } from "lucide-react";
import { api } from "@/lib/api";
import type { UserDetail } from "@/lib/types";
import { orderStatus } from "@/lib/labels";
import { appLabel } from "@/lib/app-labels";
import { errorMessage, formatDate, money } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useAuth } from "@/components/auth-provider";
import { useToast } from "@/components/toast-provider";
import { DataTable, ErrorBox, LoadingBox } from "@/components/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Switch } from "@/components/ui/input";

function Stat({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <GlassCard className="p-4">
      <div className="text-xs text-[var(--muted-foreground)]">{label}</div>
      <div className="mt-1 text-lg font-extrabold">{value}</div>
    </GlassCard>
  );
}

export default function CustomerPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const router = useRouter();
  const toast = useToast();
  const { user: me } = useAuth();
  const { data: u, setData, error, loading, reload } = useLoad(() => api<UserDetail>(`/admin/users/${id}`), [id]);
  const [busy, setBusy] = useState(false);

  const patch = async (body: Partial<UserDetail>, msg: string) => {
    setBusy(true);
    try {
      setData(await api<UserDetail>(`/admin/users/${id}`, { method: "PATCH", json: body }));
      toast.success(msg);
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setBusy(false);
    }
  };

  if (error) return <ErrorBox message={error} onRetry={reload} />;
  if (loading && !u) return <LoadingBox />;
  if (!u) return null;
  const isMe = me?.id === u.id;

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <Link href="/app/customers">
            <Button variant="secondary" size="icon" aria-label="رجوع">
              <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
          <div>
            <h2 className="flex items-center gap-2 text-xl font-bold">
              {u.name || "—"}
              {u.is_admin ? <Badge tone="rose">إدارة</Badge> : null}
              {!u.is_active ? <Badge tone="red">موقوف</Badge> : null}
            </h2>
            <p className="text-xs text-[var(--muted-foreground)]">
              <span dir="ltr">{u.phone}</span> · {appLabel(u.governorate)} · مسجل منذ {formatDate(u.created_at, false)}
            </p>
          </div>
        </div>
        <Button variant="secondary" onClick={() => router.push(`/app/notifications?phone=${encodeURIComponent(u.phone)}`)}>
          <Bell className="h-4 w-4" />
          إرسال إشعار له
        </Button>
      </div>

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Stat label="الطلبات" value={u.orders_count} />
        <Stat label="المشتريات" value={money(u.total_spent)} />
        <Stat label="المفضلة" value={u.favorites_count} />
        <Stat label="التذكيرات" value={u.reminders_count} />
      </div>

      <GlassCard className="grid gap-3 p-4 md:grid-cols-2">
        <Switch
          checked={u.is_active}
          disabled={busy || isMe}
          onChange={(v) => patch({ is_active: v }, v ? "تم تفعيل الحساب" : "تم إيقاف الحساب وتسجيل خروجه")}
          label="الحساب مفعّل"
          description="إيقاف الحساب يمنع تسجيل الدخول ويُخرجه من التطبيق فورًا."
        />
        <Switch
          checked={u.is_admin}
          disabled={busy || isMe}
          onChange={(v) => patch({ is_admin: v }, v ? "أصبح حساب إدارة" : "أُزيلت صلاحية الإدارة")}
          label="صلاحية الإدارة"
          description={isMe ? "لا يمكنك تعديل صلاحيات حسابك." : "يسمح بالدخول إلى لوحة التحكم هذه."}
        />
      </GlassCard>

      <div>
        <h3 className="mb-2 text-sm font-bold">طلبات الزبون</h3>
        {u.orders.length === 0 ? (
          <GlassCard className="p-6 text-center text-sm text-[var(--muted-foreground)]">لا توجد طلبات</GlassCard>
        ) : (
          <DataTable
            rows={u.orders}
            rowKey={(o) => o.id}
            onRowClick={(o) => router.push(`/app/orders/${o.id}`)}
            columns={[
              { key: "code", label: "رقم الطلب", render: (o) => <span dir="ltr" className="font-bold">{o.code}</span> },
              { key: "total", label: "الإجمالي", render: (o) => money(o.total) },
              {
                key: "status",
                label: "الحالة",
                render: (o) => {
                  const s = orderStatus(o.status);
                  return <Badge tone={s.tone}>{s.label}</Badge>;
                },
              },
              { key: "date", label: "التاريخ", render: (o) => <span className="text-xs">{formatDate(o.created_at)}</span> },
            ]}
          />
        )}
      </div>
    </div>
  );
}
