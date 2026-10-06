"use client";

import { useEffect, useState } from "react";
import { Headphones, Save, Share2, Truck } from "lucide-react";
import { api } from "@/lib/api";
import { errorMessage, money } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input, Textarea } from "@/components/ui/input";

type Settings = Record<string, string>;

const SECTIONS: {
  title: string;
  hint: string;
  icon: typeof Truck;
  fields: { key: string; label: string; hint?: string; ltr?: boolean; numeric?: boolean; multiline?: boolean }[];
}[] = [
  {
    title: "التوصيل",
    hint: "تُطبَّق فورًا على السلة والطلبات الجديدة في التطبيق",
    icon: Truck,
    fields: [
      { key: "pricing.delivery_fee", label: "رسوم التوصيل (د.ع)", numeric: true, ltr: true },
      { key: "pricing.free_delivery_threshold", label: "توصيل مجاني للطلبات من (د.ع)", hint: "إذا بلغ مجموع المنتجات هذا المبلغ يصبح التوصيل مجانيًا", numeric: true, ltr: true },
    ],
  },
  {
    title: "خدمة العملاء",
    hint: "تظهر في صفحة الحساب ← خدمة العملاء",
    icon: Headphones,
    fields: [
      { key: "support.phone", label: "رقم الهاتف", ltr: true },
      { key: "support.whatsapp", label: "رقم واتساب", ltr: true },
      { key: "support.email", label: "البريد الإلكتروني", ltr: true },
      { key: "support.hours_ar", label: "أوقات العمل (عربي)" },
      { key: "support.hours_en", label: "أوقات العمل (إنجليزي)", ltr: true },
    ],
  },
  {
    title: "مشاركة التطبيق",
    hint: "صفحة الحساب ← مشاركة التطبيق، وزر المشاركة في صفحة الهدية",
    icon: Share2,
    fields: [
      { key: "share.url", label: "رابط تحميل التطبيق", ltr: true },
      { key: "share.message_ar", label: "رسالة المشاركة (عربي)", multiline: true },
      { key: "share.message_en", label: "رسالة المشاركة (إنجليزي)", multiline: true, ltr: true },
      { key: "share.product_url", label: "رابط صفحات الهدايا", hint: "يُضاف إليه رقم الهدية عند مشاركتها، مثال: https://warda.app/p/12", ltr: true },
    ],
  },
];

export default function SettingsPage() {
  const toast = useToast();
  const { data, error, loading, reload } = useLoad(() => api<Settings>("/admin/settings"));
  const [form, setForm] = useState<Settings>({});
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (data) setForm(data);
  }, [data]);

  const dirty = data ? Object.keys(form).some((k) => form[k] !== data[k]) : false;

  const save = async () => {
    for (const s of SECTIONS) {
      for (const f of s.fields) {
        if (f.numeric && !/^\d+$/.test(form[f.key] ?? "")) return toast.error(`«${f.label}» يجب أن يكون رقمًا`);
      }
    }
    setSaving(true);
    try {
      const changed = Object.fromEntries(Object.entries(form).filter(([k, v]) => v !== data?.[k]));
      setForm(await api<Settings>("/admin/settings", { method: "PUT", json: { values: changed } }));
      toast.success("تم حفظ الإعدادات — ظهرت في التطبيق مباشرة");
      reload();
    } catch (e) {
      toast.error(errorMessage(e, "فشل الحفظ"));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-4">
      <PageHeader
        title="الإعدادات"
        subtitle="بيانات التواصل والمشاركة ورسوم التوصيل"
        onRefresh={reload}
        loading={loading}
        actions={
          <Button onClick={save} disabled={saving || !dirty}>
            <Save className="h-4 w-4" />
            {saving ? "جاري الحفظ…" : "حفظ التغييرات"}
          </Button>
        }
      />
      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {loading && !data ? <LoadingBox /> : null}
      {data ? (
        <div className="grid gap-4 xl:grid-cols-2">
          {SECTIONS.map(({ title, hint, icon: Icon, fields }) => (
            <GlassCard key={title} className="space-y-3 p-5">
              <div className="flex items-center gap-2">
                <Icon className="h-5 w-5 text-[var(--accent)]" />
                <div>
                  <h3 className="font-bold">{title}</h3>
                  <p className="text-[11px] text-[var(--muted-foreground)]">{hint}</p>
                </div>
              </div>
              {fields.map((f) => (
                <Field
                  key={f.key}
                  label={f.label}
                  hint={f.numeric && form[f.key] && /^\d+$/.test(form[f.key]) ? `${f.hint ? `${f.hint} · ` : ""}${money(form[f.key])}` : f.hint}
                >
                  {f.multiline ? (
                    <Textarea rows={2} dir={f.ltr ? "ltr" : undefined} value={form[f.key] ?? ""} onChange={(e) => setForm({ ...form, [f.key]: e.target.value })} />
                  ) : (
                    <Input
                      dir={f.ltr ? "ltr" : undefined}
                      inputMode={f.numeric ? "numeric" : undefined}
                      value={form[f.key] ?? ""}
                      onChange={(e) => setForm({ ...form, [f.key]: f.numeric ? e.target.value.replace(/[^0-9]/g, "") : e.target.value })}
                    />
                  )}
                </Field>
              ))}
            </GlassCard>
          ))}
        </div>
      ) : null}
    </div>
  );
}
