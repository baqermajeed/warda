"use client";

import { useState } from "react";
import { ChevronDown, Pencil, Plus, Trash2 } from "lucide-react";
import { api } from "@/lib/api";
import type { FaqCategory, FaqItem } from "@/lib/types";
import { cn, errorMessage } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { EmptyBox, ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input, Select, Textarea } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";

type CatForm = { id: number | null; slug: string; title_ar: string; title_en: string; sort_order: string };
type ItemForm = {
  id: number | null;
  category_id: string;
  question_ar: string;
  question_en: string;
  answer_ar: string;
  answer_en: string;
  sort_order: string;
};

export default function FaqPage() {
  const toast = useToast();
  const { data, error, loading, reload } = useLoad(() => api<FaqCategory[]>("/admin/faq"));
  const [cat, setCat] = useState<CatForm | null>(null);
  const [item, setItem] = useState<ItemForm | null>(null);
  const [openId, setOpenId] = useState<number | null>(null);
  const [saving, setSaving] = useState(false);

  const run = async (fn: () => Promise<unknown>, msg: string, after?: () => void) => {
    setSaving(true);
    try {
      await fn();
      toast.success(msg);
      after?.();
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  const saveCat = () => {
    if (!cat) return;
    if (!cat.title_ar.trim()) return toast.error("أدخل عنوان القسم");
    if (!/^[a-z0-9_-]+$/.test(cat.slug)) return toast.error("المعرّف: أحرف إنجليزية صغيرة وأرقام و _ فقط");
    const body = { slug: cat.slug, title_ar: cat.title_ar.trim(), title_en: cat.title_en.trim(), sort_order: Number(cat.sort_order) || 0 };
    return run(
      () =>
        cat.id == null
          ? api("/admin/faq/categories", { method: "POST", json: body })
          : api(`/admin/faq/categories/${cat.id}`, { method: "PATCH", json: body }),
      "تم حفظ القسم",
      () => setCat(null),
    );
  };

  const saveItem = () => {
    if (!item) return;
    if (!item.question_ar.trim() || !item.answer_ar.trim()) return toast.error("أدخل السؤال والجواب بالعربي");
    const body = {
      category_id: Number(item.category_id),
      question_ar: item.question_ar.trim(),
      question_en: item.question_en.trim(),
      answer_ar: item.answer_ar.trim(),
      answer_en: item.answer_en.trim(),
      sort_order: Number(item.sort_order) || 0,
    };
    return run(
      () =>
        item.id == null
          ? api("/admin/faq/items", { method: "POST", json: body })
          : api(`/admin/faq/items/${item.id}`, { method: "PATCH", json: body }),
      "تم حفظ السؤال",
      () => setItem(null),
    );
  };

  const editItem = (i: FaqItem) =>
    setItem({
      id: i.id,
      category_id: String(i.category_id),
      question_ar: i.question_ar,
      question_en: i.question_en,
      answer_ar: i.answer_ar,
      answer_en: i.answer_en,
      sort_order: String(i.sort_order),
    });

  return (
    <div className="space-y-4">
      <PageHeader
        title="الأسئلة الشائعة"
        subtitle="تظهر في صفحة الحساب ← الأسئلة الشائعة، مقسمة حسب الأقسام"
        onRefresh={reload}
        loading={loading}
        actions={
          <>
            <Button variant="secondary" onClick={() => setCat({ id: null, slug: "", title_ar: "", title_en: "", sort_order: String((data?.length ?? 0) + 1) })}>
              <Plus className="h-4 w-4" /> قسم جديد
            </Button>
            <Button
              disabled={!data?.length}
              onClick={() =>
                setItem({ id: null, category_id: String(data?.[0]?.id ?? ""), question_ar: "", question_en: "", answer_ar: "", answer_en: "", sort_order: "0" })
              }
            >
              <Plus className="h-4 w-4" /> سؤال جديد
            </Button>
          </>
        }
      />
      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {loading && !data ? <LoadingBox /> : null}
      {data && data.length === 0 ? <EmptyBox message="ابدأ بإضافة قسم (مثل: الطلبات، التوصيل، الدفع)، ثم أضف الأسئلة داخله" /> : null}

      <div className="space-y-4">
        {(data ?? []).map((c) => (
          <GlassCard key={c.id} className="p-4">
            <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
              <div>
                <h3 className="font-bold">{c.title_ar}</h3>
                <p className="text-[11px] text-[var(--muted-foreground)]">
                  {c.items.length} سؤال · ترتيب {c.sort_order} · <span dir="ltr">{c.slug}</span>
                </p>
              </div>
              <div className="flex gap-1">
                <Button size="sm" variant="secondary" onClick={() => setItem({ id: null, category_id: String(c.id), question_ar: "", question_en: "", answer_ar: "", answer_en: "", sort_order: String(c.items.length + 1) })}>
                  <Plus className="h-3.5 w-3.5" /> سؤال
                </Button>
                <Button size="sm" variant="ghost" onClick={() => setCat({ id: c.id, slug: c.slug, title_ar: c.title_ar, title_en: c.title_en, sort_order: String(c.sort_order) })}>
                  <Pencil className="h-3.5 w-3.5" />
                </Button>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() =>
                    window.confirm(`حذف القسم «${c.title_ar}» مع ${c.items.length} سؤال؟`) &&
                    run(() => api(`/admin/faq/categories/${c.id}`, { method: "DELETE" }), "تم حذف القسم")
                  }
                >
                  <Trash2 className="h-3.5 w-3.5 text-red-600" />
                </Button>
              </div>
            </div>
            <div className="divide-y divide-[var(--border)] rounded-2xl border border-[var(--border)]">
              {c.items.length === 0 ? <p className="p-4 text-center text-xs text-[var(--muted-foreground)]">لا توجد أسئلة في هذا القسم</p> : null}
              {c.items.map((i) => (
                <div key={i.id}>
                  <button className="flex w-full items-center gap-2 p-3 text-right text-sm font-semibold" onClick={() => setOpenId(openId === i.id ? null : i.id)}>
                    <ChevronDown className={cn("h-4 w-4 shrink-0 transition", openId === i.id && "rotate-180")} />
                    <span className="flex-1">{i.question_ar}</span>
                  </button>
                  {openId === i.id ? (
                    <div className="space-y-2 px-9 pb-3">
                      <p className="whitespace-pre-line text-sm leading-7 text-[var(--muted-foreground)]">{i.answer_ar}</p>
                      <div className="flex gap-1">
                        <Button size="sm" variant="secondary" onClick={() => editItem(i)}>
                          <Pencil className="h-3.5 w-3.5" /> تعديل
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => window.confirm("حذف هذا السؤال؟") && run(() => api(`/admin/faq/items/${i.id}`, { method: "DELETE" }), "تم حذف السؤال")}
                        >
                          <Trash2 className="h-3.5 w-3.5 text-red-600" /> حذف
                        </Button>
                      </div>
                    </div>
                  ) : null}
                </div>
              ))}
            </div>
          </GlassCard>
        ))}
      </div>

      <Modal
        open={!!cat}
        onClose={() => setCat(null)}
        size="sm"
        title={cat?.id == null ? "قسم جديد" : "تعديل القسم"}
        footer={
          <>
            <Button variant="secondary" onClick={() => setCat(null)}>إلغاء</Button>
            <Button onClick={saveCat} disabled={saving}>حفظ</Button>
          </>
        }
      >
        {cat ? (
          <div className="grid gap-3">
            <Field label="العنوان (عربي)" required>
              <Input value={cat.title_ar} onChange={(e) => setCat({ ...cat, title_ar: e.target.value })} />
            </Field>
            <Field label="العنوان (إنجليزي)">
              <Input dir="ltr" value={cat.title_en} onChange={(e) => setCat({ ...cat, title_en: e.target.value })} />
            </Field>
            <div className="grid grid-cols-2 gap-3">
              <Field label="المعرّف" required hint="مثل delivery">
                <Input dir="ltr" value={cat.slug} onChange={(e) => setCat({ ...cat, slug: e.target.value.toLowerCase().replace(/\s+/g, "_") })} />
              </Field>
              <Field label="الترتيب">
                <Input dir="ltr" value={cat.sort_order} onChange={(e) => setCat({ ...cat, sort_order: e.target.value.replace(/[^0-9-]/g, "") })} />
              </Field>
            </div>
          </div>
        ) : null}
      </Modal>

      <Modal
        open={!!item}
        onClose={() => setItem(null)}
        size="lg"
        title={item?.id == null ? "سؤال جديد" : "تعديل السؤال"}
        footer={
          <>
            <Button variant="secondary" onClick={() => setItem(null)}>إلغاء</Button>
            <Button onClick={saveItem} disabled={saving}>حفظ</Button>
          </>
        }
      >
        {item ? (
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="القسم" required>
              <Select value={item.category_id} onChange={(e) => setItem({ ...item, category_id: e.target.value })}>
                {(data ?? []).map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.title_ar}
                  </option>
                ))}
              </Select>
            </Field>
            <Field label="الترتيب">
              <Input dir="ltr" value={item.sort_order} onChange={(e) => setItem({ ...item, sort_order: e.target.value.replace(/[^0-9-]/g, "") })} />
            </Field>
            <Field label="السؤال (عربي)" required className="sm:col-span-2">
              <Input value={item.question_ar} onChange={(e) => setItem({ ...item, question_ar: e.target.value })} />
            </Field>
            <Field label="الجواب (عربي)" required className="sm:col-span-2">
              <Textarea rows={4} value={item.answer_ar} onChange={(e) => setItem({ ...item, answer_ar: e.target.value })} />
            </Field>
            <Field label="السؤال (إنجليزي)" hint="اختياري — يُعرض العربي إن تُرك فارغًا" className="sm:col-span-2">
              <Input dir="ltr" value={item.question_en} onChange={(e) => setItem({ ...item, question_en: e.target.value })} />
            </Field>
            <Field label="الجواب (إنجليزي)" className="sm:col-span-2">
              <Textarea dir="ltr" rows={3} value={item.answer_en} onChange={(e) => setItem({ ...item, answer_en: e.target.value })} />
            </Field>
          </div>
        ) : null}
      </Modal>
    </div>
  );
}
