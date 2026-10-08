"use client";

import { useEffect, useState } from "react";
import { Plus, Trash2 } from "lucide-react";
import { api } from "@/lib/api";
import type { Badge as BadgeT, Category, ProductDetail } from "@/lib/types";
import { BADGE_ICONS, BADGE_PRESETS, tagLabel } from "@/lib/labels";
import { appLabel } from "@/lib/app-labels";
import { errorMessage } from "@/lib/utils";
import { useLookups } from "@/hooks/use-lookups";
import { useToast } from "@/components/toast-provider";
import { Modal } from "@/components/ui/modal";
import { Button } from "@/components/ui/button";
import { Field, Input, Select, Switch, Textarea } from "@/components/ui/input";
import { MultiImageUpload } from "@/components/image-upload";
import { ListEditor } from "@/components/list-editor";

type Form = {
  sku: string;
  title_ar: string;
  title_en: string;
  description_ar: string;
  description_en: string;
  price: string;
  rating: string;
  category_id: string;
  person_tag: string;
  occasion_tag: string;
  gift_type_tag: string;
  budget_tag: string;
  delivery_tag: string;
  height_label: string;
  width_label: string;
  care_steps_ar: string[];
  care_steps_en: string[];
  badges: BadgeT[];
  is_latest: boolean;
  is_popular: boolean;
  status: "active" | "hidden";
  images: string[];
};

const EMPTY: Form = {
  sku: "",
  title_ar: "",
  title_en: "",
  description_ar: "",
  description_en: "",
  price: "",
  rating: "4.5",
  category_id: "",
  person_tag: "",
  occasion_tag: "",
  gift_type_tag: "",
  budget_tag: "",
  delivery_tag: "same_day",
  height_label: "",
  width_label: "",
  care_steps_ar: [],
  care_steps_en: [],
  badges: [],
  is_latest: false,
  is_popular: false,
  status: "active",
  images: [],
};

function fromDetail(p: ProductDetail): Form {
  return {
    sku: p.sku,
    title_ar: p.title_ar,
    title_en: p.title_en,
    description_ar: p.description_ar,
    description_en: p.description_en,
    price: String(p.price),
    rating: p.rating,
    category_id: p.category_id ? String(p.category_id) : "",
    person_tag: p.person_tag ?? "",
    occasion_tag: p.occasion_tag ?? "",
    gift_type_tag: p.gift_type_tag ?? "",
    budget_tag: p.budget_tag ?? "",
    delivery_tag: p.delivery_tag ?? "",
    height_label: p.height_label ?? "",
    width_label: p.width_label ?? "",
    care_steps_ar: p.care_steps_ar,
    care_steps_en: p.care_steps_en,
    badges: p.badges,
    is_latest: p.is_latest,
    is_popular: p.is_popular,
    status: p.status,
    images: p.images,
  };
}

/** Same ranges as the backend (taxonomy.BUDGET_RANGES). */
function budgetFor(price: number) {
  if (price < 25_000) return "b1";
  if (price < 50_000) return "b2";
  if (price < 100_000) return "b3";
  return "b4";
}

export function ProductEditor({
  productId,
  open,
  onClose,
  onSaved,
  categories,
}: {
  /** null = create a new gift */
  productId: number | null;
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  categories: Category[];
}) {
  const toast = useToast();
  const tags = useLookups();
  const [form, setForm] = useState<Form>(EMPTY);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [stats, setStats] = useState<{ sold: number; favorites: number } | null>(null);

  useEffect(() => {
    if (!open) return;
    setStats(null);
    if (productId == null) {
      setForm(EMPTY);
      return;
    }
    setLoading(true);
    api<ProductDetail>(`/admin/products/${productId}`)
      .then((p) => {
        setForm(fromDetail(p));
        setStats({ sold: p.sold, favorites: p.favorites });
      })
      .catch((e) => {
        toast.error(errorMessage(e));
        onClose();
      })
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, productId]);

  const set = <K extends keyof Form>(key: K, value: Form[K]) => setForm((f) => ({ ...f, [key]: value }));

  const save = async () => {
    if (!form.title_ar.trim()) return toast.error("أدخل اسم الهدية بالعربي");
    if (!form.sku.trim()) return toast.error("أدخل رمز الهدية (SKU)");
    const price = Number(form.price);
    if (!Number.isInteger(price) || price < 0) return toast.error("أدخل سعرًا صحيحًا بالدينار");
    if (form.images.length === 0) return toast.error("أضف صورة واحدة على الأقل");

    const body = {
      ...form,
      sku: form.sku.trim(),
      title_ar: form.title_ar.trim(),
      title_en: form.title_en.trim(),
      price,
      category_id: form.category_id ? Number(form.category_id) : null,
      person_tag: form.person_tag || null,
      occasion_tag: form.occasion_tag || null,
      gift_type_tag: form.gift_type_tag || null,
      delivery_tag: form.delivery_tag || null,
      height_label: form.height_label.trim() || null,
      width_label: form.width_label.trim() || null,
      badges: form.badges.filter((b) => b.label.trim()),
    };
    setSaving(true);
    try {
      if (productId == null) {
        await api("/admin/products", { method: "POST", json: body });
        toast.success("تمت إضافة الهدية");
      } else {
        await api(`/admin/products/${productId}`, { method: "PATCH", json: body });
        toast.success("تم حفظ التعديلات");
      }
      onSaved();
      onClose();
    } catch (e) {
      toast.error(errorMessage(e, "فشل الحفظ"));
    } finally {
      setSaving(false);
    }
  };

  const tagSelect = (key: "person_tag" | "occasion_tag" | "gift_type_tag" | "delivery_tag", ids: string[] | undefined, label: string, hint?: string) => (
    <Field label={label} hint={hint}>
      <Select value={form[key]} onChange={(e) => set(key, e.target.value)}>
        <option value="">— بدون —</option>
        {(ids ?? []).map((id) => (
          <option key={id} value={id}>
            {tagLabel(id, tags?.labels)}
          </option>
        ))}
        {form[key] && !(ids ?? []).includes(form[key]) ? <option value={form[key]}>{form[key]}</option> : null}
      </Select>
    </Field>
  );

  return (
    <Modal
      open={open}
      onClose={onClose}
      size="xl"
      title={productId == null ? "هدية جديدة" : "تعديل الهدية"}
      subtitle={stats ? `مباع ${stats.sold} قطعة · أُضيفت للمفضلة ${stats.favorites} مرة` : undefined}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            إلغاء
          </Button>
          <Button onClick={save} disabled={saving || loading}>
            {saving ? "جاري الحفظ…" : "حفظ"}
          </Button>
        </>
      }
    >
      {loading ? (
        <div className="py-16 text-center text-sm text-[var(--muted-foreground)]">جاري التحميل…</div>
      ) : (
        <div className="grid gap-6 lg:grid-cols-5">
          <div className="space-y-4 lg:col-span-2">
            <section className="grid gap-2">
              <h4 className="text-sm font-bold">الصور</h4>
              <MultiImageUpload value={form.images} onChange={(v) => set("images", v)} />
            </section>
            <section className="grid gap-2">
              <h4 className="text-sm font-bold">الظهور في الصفحة الرئيسية</h4>
              <Switch
                checked={form.status === "active"}
                onChange={(v) => set("status", v ? "active" : "hidden")}
                label="معروضة في التطبيق"
                description="عند الإخفاء لا تظهر في التطبيق، لكنها تبقى في الطلبات السابقة."
              />
              <Switch
                checked={form.is_latest}
                onChange={(v) => set("is_latest", v)}
                label="تثبيت في «أحدث الهدايا»"
                description="«أحدث الهدايا» تُرتَّب تلقائيًا من الأحدث إضافةً، والمثبّتة تظهر أولًا."
              />
              <Switch
                checked={form.is_popular}
                onChange={(v) => set("is_popular", v)}
                label="تثبيت في «الأكثر شهرة»"
                description="«الأكثر شهرة» تُحسب تلقائيًا من المبيعات الفعلية والمفضلة، والمثبّتة تظهر أولًا."
              />
            </section>
          </div>

          <div className="space-y-5 lg:col-span-3">
            <section className="grid gap-3 sm:grid-cols-2">
              <Field label="اسم الهدية (عربي)" required className="sm:col-span-2">
                <Input value={form.title_ar} onChange={(e) => set("title_ar", e.target.value)} />
              </Field>
              <Field label="اسم الهدية (إنجليزي)" hint="اختياري — يُستخدم العربي إن تُرك فارغًا" className="sm:col-span-2">
                <Input dir="ltr" value={form.title_en} onChange={(e) => set("title_en", e.target.value)} />
              </Field>
              <Field label="السعر (د.ع)" required>
                <Input inputMode="numeric" dir="ltr" value={form.price} onChange={(e) => set("price", e.target.value.replace(/[^0-9]/g, ""))} />
              </Field>
              <Field label="رمز الهدية SKU" required hint="فريد لكل هدية">
                <Input dir="ltr" value={form.sku} onChange={(e) => set("sku", e.target.value)} />
              </Field>
              <Field label="التصنيف" hint="يظهر عند الضغط على التصنيف في الرئيسية">
                <Select value={form.category_id} onChange={(e) => set("category_id", e.target.value)}>
                  <option value="">— بدون تصنيف —</option>
                  {categories.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name_ar}
                      {c.is_active ? "" : " (مخفي)"}
                    </option>
                  ))}
                </Select>
              </Field>
              <Field label="التقييم" hint="من 0 إلى 5">
                <Input dir="ltr" value={form.rating} onChange={(e) => set("rating", e.target.value)} />
              </Field>
            </section>

            <section className="grid gap-3">
              <h4 className="text-sm font-bold">الفلاتر في التطبيق</h4>
              <p className="-mt-2 text-[11px] text-[var(--muted-foreground)]">
                تحدد هذه القيم ظهور الهدية في البحث بالفلاتر وفي «كوّن هديتك».
              </p>
              <div className="grid gap-3 sm:grid-cols-2">
                {tagSelect("person_tag", tags?.lookups.person, "لمن الهدية")}
                {tagSelect("occasion_tag", tags?.lookups.occasion, "المناسبة")}
                {tagSelect("gift_type_tag", tags?.lookups.gift_type, "نوع الهدية")}
                {tagSelect("delivery_tag", tags?.lookups.delivery, "التوصيل")}
                <Field label="فئة الميزانية" hint="تُحسب تلقائيًا من السعر">
                  <Input readOnly value={form.price ? tagLabel(budgetFor(Number(form.price)), tags?.labels) : "—"} />
                </Field>
              </div>
            </section>

            <section className="grid gap-3">
              <Field label="الوصف (عربي)">
                <Textarea value={form.description_ar} onChange={(e) => set("description_ar", e.target.value)} />
              </Field>
              <Field label="الوصف (إنجليزي)">
                <Textarea dir="ltr" value={form.description_en} onChange={(e) => set("description_en", e.target.value)} />
              </Field>
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label="الارتفاع" hint="مثال: 30cm">
                  <Input dir="ltr" value={form.height_label} onChange={(e) => set("height_label", e.target.value)} />
                </Field>
                <Field label="العرض" hint="مثال: 20cm">
                  <Input dir="ltr" value={form.width_label} onChange={(e) => set("width_label", e.target.value)} />
                </Field>
              </div>
            </section>

            <section className="grid gap-3">
              <h4 className="text-sm font-bold">خطوات العناية</h4>
              <Field label="عربي">
                <ListEditor value={form.care_steps_ar} onChange={(v) => set("care_steps_ar", v)} addLabel="إضافة خطوة" />
              </Field>
              <Field label="إنجليزي">
                <ListEditor value={form.care_steps_en} onChange={(v) => set("care_steps_en", v)} addLabel="Add step" />
              </Field>
            </section>

            <section className="grid gap-2">
              <h4 className="text-sm font-bold">الشارات تحت اسم الهدية</h4>
              {form.badges.map((b, i) => (
                <div key={i} className="flex flex-wrap items-center gap-2">
                  <Input
                    className="min-w-[180px] flex-1"
                    list="badge-presets"
                    value={b.label}
                    placeholder="نص الشارة"
                    onChange={(e) => set("badges", form.badges.map((x, k) => (k === i ? { ...x, label: e.target.value } : x)))}
                  />
                  <Select
                    className="w-36"
                    value={b.icon}
                    onChange={(e) => set("badges", form.badges.map((x, k) => (k === i ? { ...x, icon: e.target.value } : x)))}
                  >
                    {BADGE_ICONS.map((ic) => (
                      <option key={ic.id} value={ic.id}>
                        {ic.label}
                      </option>
                    ))}
                  </Select>
                  <span className="text-[11px] text-[var(--muted-foreground)]">{b.label.startsWith("product_badge_") ? appLabel(b.label) : ""}</span>
                  <Button size="icon" variant="ghost" onClick={() => set("badges", form.badges.filter((_, k) => k !== i))} aria-label="حذف">
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              ))}
              <datalist id="badge-presets">
                {BADGE_PRESETS.map((k) => (
                  <option key={k} value={k}>
                    {appLabel(k)}
                  </option>
                ))}
              </datalist>
              <Button size="sm" variant="secondary" className="justify-self-start" onClick={() => set("badges", [...form.badges, { label: "", icon: "truck" }])}>
                <Plus className="h-4 w-4" />
                إضافة شارة
              </Button>
              <p className="text-[11px] text-[var(--muted-foreground)]">
                اكتب نصًا حرًا، أو اختر أحد المفاتيح الجاهزة (تُترجم تلقائيًا للعربي والإنجليزي في التطبيق).
              </p>
            </section>
          </div>
        </div>
      )}
    </Modal>
  );
}
