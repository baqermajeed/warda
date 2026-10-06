"use client";

import { useState } from "react";
import { ArrowDown, ArrowUp, Info, Link2, Pencil, Plus, Trash2 } from "lucide-react";
import { api, mediaUrl } from "@/lib/api";
import type { Banner } from "@/lib/types";
import { APP_LINK_PRESETS, LINK_HELP } from "@/lib/labels";
import { errorMessage } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { EmptyBox, ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { ImageUpload } from "@/components/image-upload";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input, Select, Switch } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";

type Form = {
  title_ar: string;
  title_en: string;
  image: string | null;
  link: string;
  sort_order: string;
  is_active: boolean;
};

export default function BannersPage() {
  const toast = useToast();
  const { data, error, loading, reload } = useLoad(() => api<Banner[]>("/admin/banners"));
  const [edit, setEdit] = useState<{ id: number | null; form: Form } | null>(null);
  const [saving, setSaving] = useState(false);

  const open = (b?: Banner) =>
    setEdit(
      b
        ? {
            id: b.id,
            form: {
              title_ar: b.title_ar,
              title_en: b.title_en,
              image: b.image,
              link: b.link ?? "",
              sort_order: String(b.sort_order),
              is_active: b.is_active,
            },
          }
        : {
            id: null,
            form: { title_ar: "", title_en: "", image: null, link: "", sort_order: String((data?.length ?? 0) + 1), is_active: true },
          },
    );

  const set = <K extends keyof Form>(k: K, v: Form[K]) => setEdit((e) => (e ? { ...e, form: { ...e.form, [k]: v } } : e));

  const save = async () => {
    if (!edit) return;
    if (!edit.form.image) return toast.error("ارفع صورة الإعلان");
    const body = { ...edit.form, link: edit.form.link.trim() || null, sort_order: Number(edit.form.sort_order) || 0 };
    setSaving(true);
    try {
      if (edit.id == null) await api("/admin/banners", { method: "POST", json: body });
      else await api(`/admin/banners/${edit.id}`, { method: "PATCH", json: body });
      toast.success("تم حفظ الإعلان");
      setEdit(null);
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  const patch = async (b: Banner, body: Partial<Banner>) => {
    try {
      await api(`/admin/banners/${b.id}`, { method: "PATCH", json: body });
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  /** Swap order with the neighbour (re-numbers all banners to keep it clean). */
  const move = async (index: number, dir: -1 | 1) => {
    if (!data) return;
    const j = index + dir;
    if (j < 0 || j >= data.length) return;
    const next = [...data];
    [next[index], next[j]] = [next[j], next[index]];
    try {
      await Promise.all(
        next.map((b, i) => (b.sort_order !== i + 1 ? api(`/admin/banners/${b.id}`, { method: "PATCH", json: { sort_order: i + 1 } }) : null)),
      );
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const remove = async (b: Banner) => {
    if (!window.confirm("حذف هذا الإعلان؟")) return;
    try {
      await api(`/admin/banners/${b.id}`, { method: "DELETE" });
      toast.success("تم حذف الإعلان");
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const linkLabel = (link: string | null) => APP_LINK_PRESETS.find((p) => p.value === (link ?? ""))?.label ?? link;

  return (
    <div className="space-y-4">
      <PageHeader
        title="إعلانات الصفحة الرئيسية"
        subtitle="الصور المتحركة أعلى الصفحة الرئيسية في التطبيق"
        onRefresh={reload}
        loading={loading}
        actions={
          <Button onClick={() => open()}>
            <Plus className="h-4 w-4" />
            إعلان جديد
          </Button>
        }
      />
      <GlassCard className="flex gap-2 p-4 text-xs leading-6 text-[var(--muted-foreground)]">
        <Info className="mt-1 h-4 w-4 shrink-0 text-[var(--accent)]" />
        <span>
          تظهر الإعلانات المفعّلة بالترتيب كصور قابلة للسحب، وزر «استكشف» يفتح رابط الإعلان الظاهر. المقاس المناسب: صورة
          عمودية تقريبًا 1080×1100. إذا لم يوجد أي إعلان مفعّل يعرض التطبيق صورته الافتراضية.
        </span>
      </GlassCard>

      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {loading && !data ? <LoadingBox /> : null}
      {data && data.length === 0 ? <EmptyBox message="لا توجد إعلانات — التطبيق يعرض الصورة الافتراضية" /> : null}

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {(data ?? []).map((b, i) => (
          <GlassCard key={b.id} className="overflow-hidden p-0">
            <div className="relative aspect-[390/400] bg-[var(--muted)]">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={mediaUrl(b.image) ?? ""} alt="" className="h-full w-full object-cover" />
              <div className="absolute right-3 top-3 flex gap-1">
                <Badge tone="rose">#{i + 1}</Badge>
                {b.is_active ? <Badge tone="green">مفعّل</Badge> : <Badge tone="gray">متوقف</Badge>}
              </div>
            </div>
            <div className="space-y-2 p-4">
              <div className="font-semibold">{b.title_ar || "بدون عنوان"}</div>
              <div className="flex items-center gap-1 text-[11px] text-[var(--muted-foreground)]">
                <Link2 className="h-3.5 w-3.5" />
                <span dir="ltr" className="truncate">
                  {linkLabel(b.link) || "بدون رابط — «استكشف» يفتح التصنيفات"}
                </span>
              </div>
              <div className="flex flex-wrap gap-1">
                <Button size="sm" variant="secondary" onClick={() => open(b)}>
                  <Pencil className="h-3.5 w-3.5" /> تعديل
                </Button>
                <Button size="sm" variant="ghost" onClick={() => patch(b, { is_active: !b.is_active })}>
                  {b.is_active ? "إيقاف" : "تفعيل"}
                </Button>
                <Button size="icon" variant="ghost" disabled={i === 0} onClick={() => move(i, -1)} aria-label="تقديم">
                  <ArrowUp className="h-4 w-4" />
                </Button>
                <Button size="icon" variant="ghost" disabled={i === data!.length - 1} onClick={() => move(i, 1)} aria-label="تأخير">
                  <ArrowDown className="h-4 w-4" />
                </Button>
                <Button size="icon" variant="ghost" onClick={() => remove(b)} aria-label="حذف">
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
        size="lg"
        title={edit?.id == null ? "إعلان جديد" : "تعديل الإعلان"}
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
          <div className="grid gap-4 sm:grid-cols-[220px_1fr]">
            <Field label="صورة الإعلان" required>
              <ImageUpload value={edit.form.image} onChange={(v) => set("image", v)} aspect="aspect-[390/400]" />
            </Field>
            <div className="grid content-start gap-3">
              <Field label="العنوان (عربي)" hint="للتنظيم داخل اللوحة">
                <Input value={edit.form.title_ar} onChange={(e) => set("title_ar", e.target.value)} />
              </Field>
              <Field label="العنوان (إنجليزي)">
                <Input dir="ltr" value={edit.form.title_en} onChange={(e) => set("title_en", e.target.value)} />
              </Field>
              <Field label="عند الضغط على «استكشف»">
                <Select
                  value={APP_LINK_PRESETS.some((p) => p.value === edit.form.link) ? edit.form.link : "__custom"}
                  onChange={(e) => set("link", e.target.value === "__custom" ? edit.form.link || "/products/" : e.target.value)}
                >
                  {APP_LINK_PRESETS.map((p) => (
                    <option key={p.value} value={p.value}>
                      {p.label}
                    </option>
                  ))}
                  <option value="__custom">رابط مخصص…</option>
                </Select>
              </Field>
              <Field label="الرابط" hint={LINK_HELP}>
                <Input dir="ltr" value={edit.form.link} onChange={(e) => set("link", e.target.value)} placeholder="/products/12" />
              </Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="الترتيب">
                  <Input dir="ltr" inputMode="numeric" value={edit.form.sort_order} onChange={(e) => set("sort_order", e.target.value.replace(/[^0-9-]/g, ""))} />
                </Field>
                <div className="self-end">
                  <Switch checked={edit.form.is_active} onChange={(v) => set("is_active", v)} label="مفعّل" />
                </div>
              </div>
            </div>
          </div>
        ) : null}
      </Modal>
    </div>
  );
}
