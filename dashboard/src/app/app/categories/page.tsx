"use client";

import { useState } from "react";
import Link from "next/link";
import { Info, Pencil, Plus, Trash2 } from "lucide-react";
import { api } from "@/lib/api";
import type { Category } from "@/lib/types";
import { FILTER_SLUGS } from "@/lib/labels";
import { errorMessage } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { EmptyBox, ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { ImageUpload, Thumb } from "@/components/image-upload";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input, Switch } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";

type Form = {
  slug: string;
  name_ar: string;
  name_en: string;
  image: string | null;
  sort_order: string;
  is_active: boolean;
};

const EMPTY: Form = { slug: "", name_ar: "", name_en: "", image: null, sort_order: "0", is_active: true };

export default function CategoriesPage() {
  const toast = useToast();
  const { data, error, loading, reload } = useLoad(() => api<Category[]>("/admin/categories"));
  const [edit, setEdit] = useState<{ id: number | null; form: Form } | null>(null);
  const [saving, setSaving] = useState(false);

  const open = (c?: Category) =>
    setEdit(
      c
        ? {
            id: c.id,
            form: {
              slug: c.slug,
              name_ar: c.name_ar,
              name_en: c.name_en,
              image: c.image,
              sort_order: String(c.sort_order),
              is_active: c.is_active,
            },
          }
        : { id: null, form: { ...EMPTY, sort_order: String((data?.length ?? 0) + 1) } },
    );

  const set = <K extends keyof Form>(k: K, v: Form[K]) =>
    setEdit((e) => (e ? { ...e, form: { ...e.form, [k]: v } } : e));

  const save = async () => {
    if (!edit) return;
    const f = edit.form;
    if (!f.name_ar.trim()) return toast.error("أدخل اسم التصنيف");
    if (!/^[a-z0-9_-]+$/.test(f.slug)) return toast.error("المعرّف: أحرف إنجليزية صغيرة وأرقام و _ فقط");
    const body = { ...f, name_ar: f.name_ar.trim(), name_en: f.name_en.trim(), sort_order: Number(f.sort_order) || 0 };
    setSaving(true);
    try {
      if (edit.id == null) await api("/admin/categories", { method: "POST", json: body });
      else await api(`/admin/categories/${edit.id}`, { method: "PATCH", json: body });
      toast.success(edit.id == null ? "تمت إضافة التصنيف" : "تم حفظ التصنيف");
      setEdit(null);
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  const toggle = async (c: Category) => {
    try {
      await api(`/admin/categories/${c.id}`, { method: "PATCH", json: { is_active: !c.is_active } });
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const remove = async (c: Category) => {
    const extra = c.product_count ? `\n${c.product_count} هدية ستبقى في المتجر بدون تصنيف.` : "";
    if (!window.confirm(`حذف التصنيف «${c.name_ar}»؟${extra}`)) return;
    try {
      await api(`/admin/categories/${c.id}`, { method: "DELETE" });
      toast.success("تم حذف التصنيف");
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  return (
    <div className="space-y-4">
      <PageHeader
        title="التصنيفات"
        subtitle="تظهر في قسم «اختر حسب» بالصفحة الرئيسية للتطبيق، بنفس الترتيب"
        onRefresh={reload}
        loading={loading}
        actions={
          <Button onClick={() => open()}>
            <Plus className="h-4 w-4" />
            تصنيف جديد
          </Button>
        }
      />
      <GlassCard className="flex gap-2 p-4 text-xs leading-6 text-[var(--muted-foreground)]">
        <Info className="mt-1 h-4 w-4 shrink-0 text-[var(--accent)]" />
        <span>
          الضغط على تصنيف في التطبيق يعرض الهدايا المرتبطة به (تربط الهدية بالتصنيف من صفحة الهدايا). المعرّفات الخاصة{" "}
          <code dir="ltr">person</code> و<code dir="ltr">occasion</code> و<code dir="ltr">gift_type</code> تفتح الفلتر
          المقابل في تبويب التصنيفات بدل قائمة الهدايا.
        </span>
      </GlassCard>

      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {loading && !data ? <LoadingBox /> : null}
      {data && data.length === 0 ? <EmptyBox message="لا توجد تصنيفات بعد" /> : null}

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
        {(data ?? []).map((c) => (
          <GlassCard key={c.id} className="flex gap-3 p-4">
            <Thumb src={c.image} className="h-16 w-16 rounded-full" />
            <div className="min-w-0 flex-1">
              <div className="flex flex-wrap items-center gap-2">
                <span className="font-bold">{c.name_ar}</span>
                {c.is_active ? <Badge tone="green">ظاهر</Badge> : <Badge tone="gray">مخفي</Badge>}
              </div>
              <div className="mt-0.5 text-[11px] text-[var(--muted-foreground)]">
                <span dir="ltr">{c.slug}</span> · ترتيب {c.sort_order}
              </div>
              <div className="mt-1 text-xs">
                {FILTER_SLUGS[c.slug] ? (
                  <span className="text-[var(--accent)]">{FILTER_SLUGS[c.slug]}</span>
                ) : (
                  <Link href={`/app/products?category=${c.id}`} className="text-[var(--muted-foreground)]">
                    {c.product_count} هدية
                  </Link>
                )}
              </div>
              <div className="mt-3 flex flex-wrap gap-1">
                <Button size="sm" variant="secondary" onClick={() => open(c)}>
                  <Pencil className="h-3.5 w-3.5" /> تعديل
                </Button>
                <Button size="sm" variant="ghost" onClick={() => toggle(c)}>
                  {c.is_active ? "إخفاء" : "إظهار"}
                </Button>
                <Button size="sm" variant="ghost" onClick={() => remove(c)}>
                  <Trash2 className="h-3.5 w-3.5 text-red-600" /> حذف
                </Button>
              </div>
            </div>
          </GlassCard>
        ))}
      </div>

      <Modal
        open={!!edit}
        onClose={() => setEdit(null)}
        title={edit?.id == null ? "تصنيف جديد" : "تعديل التصنيف"}
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
          <div className="grid gap-4 sm:grid-cols-[160px_1fr]">
            <Field label="الصورة" hint="تظهر داخل دائرة">
              <ImageUpload value={edit.form.image} onChange={(v) => set("image", v)} />
            </Field>
            <div className="grid content-start gap-3">
              <Field label="الاسم (عربي)" required>
                <Input value={edit.form.name_ar} onChange={(e) => set("name_ar", e.target.value)} />
              </Field>
              <Field label="الاسم (إنجليزي)" hint="يظهر عندما تكون لغة التطبيق إنجليزية">
                <Input dir="ltr" value={edit.form.name_en} onChange={(e) => set("name_en", e.target.value)} />
              </Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="المعرّف (slug)" required hint="إنجليزي صغير، مثل roses">
                  <Input
                    dir="ltr"
                    value={edit.form.slug}
                    onChange={(e) => set("slug", e.target.value.toLowerCase().replace(/\s+/g, "_"))}
                  />
                </Field>
                <Field label="الترتيب" hint="الأصغر يظهر أولًا">
                  <Input dir="ltr" inputMode="numeric" value={edit.form.sort_order} onChange={(e) => set("sort_order", e.target.value.replace(/[^0-9-]/g, ""))} />
                </Field>
              </div>
              <Switch checked={edit.form.is_active} onChange={(v) => set("is_active", v)} label="ظاهر في التطبيق" />
            </div>
          </div>
        ) : null}
      </Modal>
    </div>
  );
}
