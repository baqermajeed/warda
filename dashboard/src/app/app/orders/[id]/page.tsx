"use client";

import { use, useState } from "react";
import Link from "next/link";
import { ArrowRight, Gift, MapPin, Phone, User } from "lucide-react";
import { api } from "@/lib/api";
import type { OrderDetail } from "@/lib/types";
import { ORDER_STATUSES, orderStatus, paymentLabel } from "@/lib/labels";
import { appLabel } from "@/lib/app-labels";
import { cn, errorMessage, formatDate, money } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { ErrorBox, LoadingBox } from "@/components/page-header";
import { Thumb } from "@/components/image-upload";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";

function Row({ label, value, strong }: { label: string; value: React.ReactNode; strong?: boolean }) {
  return (
    <div className={cn("flex justify-between gap-3 py-1.5 text-sm", strong && "border-t border-[var(--border)] pt-3 text-base font-extrabold")}>
      <span className={strong ? "" : "text-[var(--muted-foreground)]"}>{label}</span>
      <span>{value}</span>
    </div>
  );
}

export default function OrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const toast = useToast();
  const { data: order, setData, error, loading, reload } = useLoad(() => api<OrderDetail>(`/admin/orders/${id}`), [id]);
  const [saving, setSaving] = useState("");

  const setStatus = async (status: string) => {
    if (!order || status === order.status) return;
    const label = orderStatus(status).label;
    if (!window.confirm(`تغيير حالة الطلب إلى «${label}»؟ سيصل للزبون إشعار بذلك.`)) return;
    setSaving(status);
    try {
      setData(await api<OrderDetail>(`/admin/orders/${id}/status`, { method: "PATCH", json: { status } }));
      toast.success(`أصبحت الحالة «${label}» وأُرسل إشعار للزبون`);
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving("");
    }
  };

  if (error) return <ErrorBox message={error} onRetry={reload} />;
  if (loading && !order) return <LoadingBox />;
  if (!order) return null;

  const st = orderStatus(order.status);
  const extras = [
    order.gift_card ? { kind: "بطاقة إهداء", ...order.gift_card } : null,
    order.wrap ? { kind: "تغليف", ...order.wrap } : null,
    ...order.addons.map((a) => ({ kind: "إضافة", ...a })),
  ].filter(Boolean) as { kind: string; title_ar?: string; price?: number; image?: string }[];

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <Link href="/app/orders">
            <Button variant="secondary" size="icon" aria-label="رجوع">
              <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
          <div>
            <h2 className="flex items-center gap-2 text-xl font-bold">
              طلب <span dir="ltr">{order.code}</span>
              <Badge tone={st.tone}>{st.label}</Badge>
            </h2>
            <p className="text-xs text-[var(--muted-foreground)]">
              {formatDate(order.created_at)} · {paymentLabel(order.payment_method)}
            </p>
          </div>
        </div>
      </div>

      <GlassCard className="p-4">
        <h3 className="mb-3 text-sm font-bold">حالة الطلب</h3>
        <div className="flex flex-wrap gap-2">
          {ORDER_STATUSES.map((s) => (
            <Button
              key={s.id}
              size="sm"
              variant={order.status === s.id ? "default" : "secondary"}
              disabled={!!saving}
              onClick={() => setStatus(s.id)}
            >
              {saving === s.id ? "…" : s.label}
            </Button>
          ))}
        </div>
        <p className="mt-2 text-[11px] text-[var(--muted-foreground)]">
          كل تغيير يُرسل إشعارًا للزبون داخل التطبيق. الطلبات الملغاة لا تُحسب في المبيعات ولا في «الأكثر شهرة».
        </p>
      </GlassCard>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-4 lg:col-span-2">
          <GlassCard className="p-4">
            <h3 className="mb-3 text-sm font-bold">المنتجات</h3>
            <div className="divide-y divide-[var(--border)]">
              {order.items.map((it, i) => (
                <div key={i} className="flex items-center gap-3 py-2.5">
                  <Thumb src={it.image} className="h-14 w-14" />
                  <div className="min-w-0 flex-1">
                    <div className="font-semibold">
                      {it.product_id ? (
                        <Link href={`/app/products?edit=${it.product_id}`} className="hover:underline">
                          {it.title_ar}
                        </Link>
                      ) : (
                        it.title_ar
                      )}
                    </div>
                    <div className="text-xs text-[var(--muted-foreground)]">
                      {money(it.unit_price)} × {it.qty}
                      {it.product_id ? "" : " · (هدية محذوفة)"}
                    </div>
                  </div>
                  <div className="font-bold">{money(it.line_total)}</div>
                </div>
              ))}
              {extras.map((x, i) => (
                <div key={`x-${i}`} className="flex items-center gap-3 py-2.5">
                  <Thumb src={x.image} className="h-14 w-14" />
                  <div className="min-w-0 flex-1">
                    <div className="font-semibold">{x.title_ar}</div>
                    <div className="text-xs text-[var(--muted-foreground)]">{x.kind}</div>
                  </div>
                  <div className="font-bold">{money(x.price)}</div>
                </div>
              ))}
            </div>
          </GlassCard>

          {order.gift_from || order.gift_to || order.gift_message ? (
            <GlassCard className="p-4">
              <h3 className="mb-2 flex items-center gap-2 text-sm font-bold">
                <Gift className="h-4 w-4 text-[var(--accent)]" /> رسالة البطاقة
              </h3>
              <div className="grid gap-1 text-sm">
                {order.gift_from ? <div>من: {order.gift_from}</div> : null}
                {order.gift_to ? <div>إلى: {order.gift_to}</div> : null}
                {order.gift_message ? (
                  <p className="mt-1 rounded-2xl bg-[var(--muted)] p-3 leading-7">{order.gift_message}</p>
                ) : null}
              </div>
            </GlassCard>
          ) : null}
        </div>

        <div className="space-y-4">
          <GlassCard className="p-4">
            <h3 className="mb-3 text-sm font-bold">التوصيل</h3>
            <div className="grid gap-2 text-sm">
              <div className="flex items-center gap-2">
                <User className="h-4 w-4 text-[var(--muted-foreground)]" />
                {order.recipient_name}
              </div>
              <a href={`tel:${order.recipient_phone}`} className="flex items-center gap-2 hover:underline" dir="ltr">
                <Phone className="h-4 w-4 text-[var(--muted-foreground)]" />
                {order.recipient_phone}
              </a>
              <div className="flex items-start gap-2">
                <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-[var(--muted-foreground)]" />
                {order.unknown_address ? (
                  <span>العنوان غير معروف — يُتصل بالمستلم لتحديده</span>
                ) : (
                  <span>
                    {appLabel(order.governorate)}
                    {order.landmark ? ` · ${order.landmark}` : ""}
                  </span>
                )}
              </div>
            </div>
          </GlassCard>

          {order.customer ? (
            <GlassCard className="p-4">
              <h3 className="mb-2 text-sm font-bold">الزبون</h3>
              <Link href={`/app/customers/${order.customer.id}`} className="grid gap-0.5 text-sm hover:underline">
                <span>{order.customer.name}</span>
                <span className="text-xs text-[var(--muted-foreground)]" dir="ltr">
                  {order.customer.phone}
                </span>
              </Link>
            </GlassCard>
          ) : null}

          <GlassCard className="p-4">
            <h3 className="mb-2 text-sm font-bold">الحساب</h3>
            <Row label="المنتجات" value={money(order.subtotal)} />
            <Row label="التغليف" value={money(order.wrap_price)} />
            <Row label="الإضافات" value={money(order.addons_price)} />
            <Row label="البطاقة" value={money(order.card_price)} />
            <Row label="التوصيل" value={order.delivery_price ? money(order.delivery_price) : "مجاني"} />
            <Row label="الإجمالي" value={money(order.total)} strong />
          </GlassCard>
        </div>
      </div>
    </div>
  );
}
