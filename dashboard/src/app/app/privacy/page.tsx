"use client";

import { useState } from "react";
import { ArrowDown, ArrowUp, Pencil, Plus, Trash2 } from "lucide-react";
import { api } from "@/lib/api";
import type { PrivacySection } from "@/lib/types";
import { errorMessage, formatDate } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { EmptyBox, ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input, Textarea } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";

type Form = { id: number | null; slug: string; title_ar: string; title_en: string; body_ar: string; body_en: string; sort_order: string };

export default function PrivacyPage() {
  const toast = useToast();
  const { data, error, loading, reload } = useLoad(() => api<PrivacySection[]>("/admin/privacy"));
  const [edit, setEdit] = useState<Form | null>(null);
  const [saving, setSaving] = useState(false);

  const save = async () => {
    if (!edit) return;
    if (!edit.title_ar.trim() || !edit.body_ar.trim()) return toast.error("أدخل العنوان والنص بالعربي");
    if (!/^[a-z0-9_-]+$/.test(edit.slug)) return toast.error("المعرّف: أحرف إنجليزية صغيرة وأرقام و _ فقط");
    const { id, ...rest } = edit;
    const body = { ...rest, title_ar: rest.title_ar.trim(), body_ar: rest.body_ar.trim(), sort_order: Number(rest.sort_order) || 0 };
    setSaving(true);
    try {
      if (id == null) await api("/admin/privacy", { method: "POST", json: body });
      else await api(`/admin/privacy/${id}`, { method: "PATCH", json: body });
      toast.success("تم حفظ القسم");
      setEdit(null);
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  const move = async (index: number, dir: -1 | 1) => {
    if (!data) return;
    const j = index + dir;
    if (j < 0 || j >= data.length) return;
    const next = [...data];
    [next[index], next[j]] = [next[j], next[index]];
    try {
      await Promise.all(next.map((s, i) => (s.sort_order !== i + 1 ? api(`/admin/privacy/${s.id}`, { method: "PATCH", json: { sort_order: i + 1 } }) : null)));
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const remove = async (s: PrivacySection) => {
    if (!window.confirm(`حذف القسم «${s.title_ar}»؟`)) return;
    try {
      await api(`/admin/privacy/${s.id}`, { method: "DELETE" });
      toast.success("تم الحذف");
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  return (
    <div className="space-y-4">
      <PageHeader
        title="سياسة الخصوصية"
        subtitle="تظهر في صفحة الحساب ← سياسة الخصوصية، كأقسام قابلة للتوسيع"
        onRefresh={reload}
        loading={loading}
        actions={
          <Button onClick={() => setEdit({ id: null, slug: `section_${(data?.length ?? 0) + 1}`, title_ar: "", title_en: "", body_ar: "", body_en: "", sort_order: String((data?.length ?? 0) + 1) })}>
            <Plus className="h-4 w-4" /> قسم جديد
          </Button>
        }
      />
      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {loading && !data ? <LoadingBox /> : null}
      {data && data.length === 0 ? <EmptyBox message="لا توجد أقسام — صفحة الخصوصية في التطبيق ستكون فارغة" /> : null}

      <div className="space-y-3">
        {(data ?? []).map((s, i) => (
          <GlassCard key={s.id} className="p-4">
            <div className="flex flex-wrap items-start justify-between gap-2">
              <div className="min-w-0 flex-1">
                <h3 className="font-bold">
                  {i + 1}. {s.title_ar}
                </h3>
                <p className="mt-0.5 text-[11px] text-[var(--muted-foreground)]">آخر تعديل {formatDate(s.updated_at)}</p>
              </div>
              <div className="flex gap-1">
                <Button size="icon" variant="ghost" disabled={i === 0} onClick={() => move(i, -1)} aria-label="تقديم">
                  <ArrowUp className="h-4 w-4" />
                </Button>
                <Button size="icon" variant="ghost" disabled={i === data!.length - 1} onClick={() => move(i, 1)} aria-label="تأخير">
                  <ArrowDown className="h-4 w-4" />
                </Button>
                <Button size="icon" variant="ghost" onClick={() => setEdit({ id: s.id, slug: s.slug, title_ar: s.title_ar, title_en: s.title_en, body_ar: s.body_ar, body_en: s.body_en, sort_order: String(s.sort_order) })} aria-label="تعديل">
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button size="icon" variant="ghost" onClick={() => remove(s)} aria-label="حذف">
                  <Trash2 className="h-4 w-4 text-red-600" />
                </Button>
              </div>
            </div>
            <p className="mt-2 line-clamp-3 whitespace-pre-line text-sm leading-7 text-[var(--muted-foreground)]">{s.body_ar}</p>
          </GlassCard>
        ))}
      </div>

      <Modal
        open={!!edit}
        onClose={() => setEdit(null)}
        size="lg"
        title={edit?.id == null ? "قسم جديد" : "تعديل القسم"}
        footer={
          <>
            <Button variant="secondary" onClick={() => setEdit(null)}>إلغاء</Button>
            <Button onClick={save} disabled={saving}>{saving ? "جاري الحفظ…" : "حفظ"}</Button>
          </>
        }
      >
        {edit ? (
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="العنوان (عربي)" required>
              <Input value={edit.title_ar} onChange={(e) => setEdit({ ...edit, title_ar: e.target.value })} />
            </Field>
            <Field label="العنوان (إنجليزي)">
              <Input dir="ltr" value={edit.title_en} onChange={(e) => setEdit({ ...edit, title_en: e.target.value })} />
            </Field>
            <Field label="النص (عربي)" required className="sm:col-span-2">
              <Textarea rows={7} value={edit.body_ar} onChange={(e) => setEdit({ ...edit, body_ar: e.target.value })} />
            </Field>
            <Field label="النص (إنجليزي)" hint="اختياري — يُعرض العربي إن تُرك فارغًا" className="sm:col-span-2">
              <Textarea dir="ltr" rows={5} value={edit.body_en} onChange={(e) => setEdit({ ...edit, body_en: e.target.value })} />
            </Field>
            <Field label="المعرّف" required>
              <Input dir="ltr" value={edit.slug} onChange={(e) => setEdit({ ...edit, slug: e.target.value.toLowerCase().replace(/\s+/g, "_") })} />
            </Field>
            <Field label="الترتيب">
              <Input dir="ltr" value={edit.sort_order} onChange={(e) => setEdit({ ...edit, sort_order: e.target.value.replace(/[^0-9-]/g, "") })} />
            </Field>
          </div>
        ) : null}
      </Modal>
    </div>
  );
}
