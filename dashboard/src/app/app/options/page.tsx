"use client";

import { useState } from "react";
import { CreditCard, Package2, Pencil, Plus, Sparkles, Trash2 } from "lucide-react";
import { api } from "@/lib/api";
import type { BasketOption, OptionKind } from "@/lib/types";
import { appLabel } from "@/lib/app-labels";
import { errorMessage, money } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useLookups } from "@/hooks/use-lookups";
import { useToast } from "@/components/toast-provider";
import { EmptyBox, ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { ImageUpload, Thumb } from "@/components/image-upload";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input, Select, Switch } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";

const TABS: { id: OptionKind; label: string; hint: string; icon: typeof CreditCard }[] = [
  { id: "gift-cards", label: "بطاقات الإهداء", hint: "شاشة «تخصيص بطاقة الإهداء» في السلة", icon: CreditCard },
  { id: "wraps", label: "أوراق التغليف", hint: "شاشة «التغليف» في السلة", icon: Package2 },
  { id: "addons", label: "الإضافات", hint: "شاشة «الإضافات» في السلة (شوكولاتة، شموع…)", icon: Sparkles },
];

type Form = {
  code: string;
  title_ar: string;
  title_en: string;
  price: string;
  image: string | null;
  category: string;
  is_active: boolean;
};

export default function OptionsPage() {
  const toast = useToast();
  const tags = useLookups();
  const [kind, setKind] = useState<OptionKind>("gift-cards");
  const { data, error, loading, reload } = useLoad(() => api<BasketOption[]>(`/admin/options/${kind}`), [kind]);
  const [edit, setEdit] = useState<{ id: number | null; form: Form } | null>(null);
  const [saving, setSaving] = useState(false);
  const tab = TABS.find((t) => t.id === kind)!;
  const addonCategories = (tags?.lookups.addon_categories ?? []).filter((c) => c.id !== "all");

  const open = (o?: BasketOption) =>
    setEdit(
      o
        ? {
            id: o.id,
            form: {
              code: o.code,
              title_ar: o.title_ar,
              title_en: o.title_en,
              price: String(o.price),
              image: o.image,
              category: o.category ?? "",
              is_active: o.is_active,
            },
          }
        : {
            id: null,
            form: {
              code: `${kind === "gift-cards" ? "card" : kind === "wraps" ? "wrap" : "addon"}_${Date.now().toString(36)}`,
              title_ar: "",
              title_en: "",
              price: "",
              image: null,
              category: addonCategories[0]?.id ?? "",
              is_active: true,
            },
          },
    );

  const set = <K extends keyof Form>(k: K, v: Form[K]) => setEdit((e) => (e ? { ...e, form: { ...e.form, [k]: v } } : e));

  const save = async () => {
    if (!edit) return;
    const f = edit.form;
    if (!f.title_ar.trim()) return toast.error("أدخل الاسم");
    if (!f.image) return toast.error("ارفع صورة");
    if (f.price === "" || Number.isNaN(Number(f.price))) return toast.error("أدخل السعر");
    const body = { ...f, title_ar: f.title_ar.trim(), price: Number(f.price), category: kind === "addons" ? f.category : null };
    setSaving(true);
    try {
      if (edit.id == null) await api(`/admin/options/${kind}`, { method: "POST", json: body });
      else await api(`/admin/options/${kind}/${edit.id}`, { method: "PATCH", json: body });
      toast.success("تم الحفظ");
      setEdit(null);
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  const toggle = async (o: BasketOption) => {
    try {
      await api(`/admin/options/${kind}/${o.id}`, { method: "PATCH", json: { is_active: !o.is_active } });
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const remove = async (o: BasketOption) => {
    if (!window.confirm(`حذف «${o.title_ar}»؟ الطلبات السابقة تحتفظ بنسختها.`)) return;
    try {
      await api(`/admin/options/${kind}/${o.id}`, { method: "DELETE" });
      toast.success("تم الحذف");
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  return (
    <div className="space-y-4">
      <PageHeader
        title="البطاقات والتغليف والإضافات"
        subtitle="الخيارات التي يضيفها الزبون لطلبه من شاشة السلة"
        onRefresh={reload}
        loading={loading}
        actions={
          <Button onClick={() => open()}>
            <Plus className="h-4 w-4" />
            إضافة
          </Button>
        }
      />
      <div className="flex flex-wrap gap-2">
        {TABS.map(({ id, label, icon: Icon }) => (
          <Button key={id} size="sm" variant={kind === id ? "default" : "secondary"} onClick={() => setKind(id)}>
            <Icon className="h-4 w-4" />
            {label}
          </Button>
        ))}
      </div>
      <p className="text-xs text-[var(--muted-foreground)]">{tab.hint}</p>

      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {loading && !data ? <LoadingBox /> : null}
      {data && data.length === 0 ? <EmptyBox message="لا توجد عناصر — لن تظهر هذه الشاشة بخيارات في التطبيق" /> : null}

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        {(data ?? []).map((o) => (
          <GlassCard key={o.id} className="overflow-hidden p-0">
            <Thumb src={o.image} className="aspect-[4/3] h-auto w-full rounded-none" />
            <div className="space-y-1.5 p-3">
              <div className="flex items-center justify-between gap-2">
                <span className="truncate font-semibold">{o.title_ar}</span>
                {o.is_active ? <Badge tone="green">ظاهر</Badge> : <Badge tone="gray">مخفي</Badge>}
              </div>
              <div className="text-sm font-bold text-[var(--primary)]">{money(o.price)}</div>
              {kind === "addons" ? (
                <div className="text-[11px] text-[var(--muted-foreground)]">
                  التصنيف: {appLabel(tags?.labels[o.category ?? ""] ?? o.category)}
                </div>
              ) : null}
              <div className="flex flex-wrap gap-1 pt-1">
                <Button size="sm" variant="secondary" onClick={() => open(o)}>
                  <Pencil className="h-3.5 w-3.5" /> تعديل
                </Button>
                <Button size="sm" variant="ghost" onClick={() => toggle(o)}>
                  {o.is_active ? "إخفاء" : "إظهار"}
                </Button>
                <Button size="icon" variant="ghost" onClick={() => remove(o)} aria-label="حذف">
                  <Trash2 className="h-4 w-4 text-red-600" />
                </Button>
              </div>
            </div>
          </GlassCard>
        ))}
      </div>

      <Modal
        open={!!edit}
        onClose={() => setEdit(null)}
        title={`${edit?.id == null ? "إضافة" : "تعديل"} — ${tab.label}`}
        footer={
          <>
            <Button variant="secondary" onClick={() => setEdit(null)}>
              إلغاء
            </Button>
            <Button onClick={save} disabled={saving}>
              {saving ? "جاري الحفظ…" : "حفظ"}
            </Button>
          </>
        }
      >
        {edit ? (
          <div className="grid gap-4 sm:grid-cols-[170px_1fr]">
            <Field label="الصورة" required>
              <ImageUpload value={edit.form.image} onChange={(v) => set("image", v)} />
            </Field>
            <div className="grid content-start gap-3">
              <Field label="الاسم (عربي)" required>
                <Input value={edit.form.title_ar} onChange={(e) => set("title_ar", e.target.value)} />
              </Field>
              <Field label="الاسم (إنجليزي)">
                <Input dir="ltr" value={edit.form.title_en} onChange={(e) => set("title_en", e.target.value)} />
              </Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="السعر (د.ع)" required>
                  <Input dir="ltr" inputMode="numeric" value={edit.form.price} onChange={(e) => set("price", e.target.value.replace(/[^0-9]/g, ""))} />
                </Field>
                <Field label="الكود" hint="فريد">
                  <Input dir="ltr" value={edit.form.code} onChange={(e) => set("code", e.target.value)} />
                </Field>
              </div>
              {kind === "addons" ? (
                <Field label="تصنيف الإضافة" hint="يحدد التبويب الذي تظهر فيه داخل شاشة الإضافات">
                  <Select value={edit.form.category} onChange={(e) => set("category", e.target.value)}>
                    {addonCategories.map((c) => (
                      <option key={c.id} value={c.id}>
                        {appLabel(c.label)}
                      </option>
                    ))}
                    {edit.form.category && !addonCategories.some((c) => c.id === edit.form.category) ? (
                      <option value={edit.form.category}>{edit.form.category}</option>
                    ) : null}
                  </Select>
                </Field>
              ) : null}
              <Switch checked={edit.form.is_active} onChange={(v) => set("is_active", v)} label="ظاهر في التطبيق" />
            </div>
          </div>
        ) : null}
      </Modal>
    </div>
  );
}
