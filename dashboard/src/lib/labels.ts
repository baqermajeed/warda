import { appLabel } from "@/lib/app-labels";

export const ORDER_STATUSES = [
  { id: "pending", label: "قيد المراجعة", tone: "amber" },
  { id: "confirmed", label: "مؤكد", tone: "sky" },
  { id: "shipping", label: "قيد التوصيل", tone: "violet" },
  { id: "delivered", label: "تم التوصيل", tone: "green" },
  { id: "cancelled", label: "ملغي", tone: "red" },
] as const;

export const TICKET_STATUSES = [
  { id: "open", label: "جديدة", tone: "amber" },
  { id: "in_progress", label: "قيد المتابعة", tone: "sky" },
  { id: "closed", label: "مغلقة", tone: "green" },
] as const;

export type Tone = "amber" | "sky" | "violet" | "green" | "red" | "gray" | "rose";

export function orderStatus(id: string) {
  return ORDER_STATUSES.find((s) => s.id === id) ?? { id, label: id, tone: "gray" as const };
}

export function ticketStatus(id: string) {
  return TICKET_STATUSES.find((s) => s.id === id) ?? { id, label: id, tone: "gray" as const };
}

export function paymentLabel(method: string) {
  return method === "card" ? "بطاقة" : "الدفع عند الاستلام";
}

/** Badge icons the Flutter app can render (assets/icons/product/*.svg). */
export const BADGE_ICONS = [
  { id: "truck", label: "شاحنة" },
  { id: "map", label: "خريطة" },
  { id: "card", label: "بطاقة" },
  { id: "star", label: "نجمة" },
  { id: "heart", label: "قلب" },
];

/** Preset badge texts already translated in the app (free text is also allowed). */
export const BADGE_PRESETS = [
  "product_badge_natural",
  "product_badge_free_delivery",
  "product_badge_fast",
  "product_badge_mastercard",
];

/** Slugs that open the matching filter in the app's categories tab (not a product list). */
export const FILTER_SLUGS: Record<string, string> = {
  person: "يفتح فلتر «لمن الهدية» في التطبيق",
  occasion: "يفتح فلتر «المناسبة» في التطبيق",
  gift_type: "يفتح فلتر «نوع الهدية» في التطبيق",
};

/** Label for a stored product tag (person/occasion/gift type/...). */
export function tagLabel(id: string | null | undefined, extra: Record<string, string> = {}) {
  if (!id) return "—";
  if (extra[id]) return appLabel(extra[id]);
  const direct = appLabel(`opt_${id}`);
  if (direct !== `opt_${id}`) return direct;
  const sg = appLabel(`sg_opt_${id}`);
  if (sg !== `sg_opt_${id}`) return sg;
  const fav = appLabel(`fav_cat_${id}`);
  if (fav !== `fav_cat_${id}`) return fav;
  return id;
}

/** Internal links the app understands (banners & notifications). */
export const APP_LINK_PRESETS = [
  { value: "", label: "بدون رابط" },
  { value: "/special-gift", label: "تدفق «كوّن هديتك»" },
  { value: "/search?delivery=same_day", label: "نتائج: توصيل اليوم" },
  { value: "/search?gift_type=flowers", label: "نتائج: باقات ورد" },
  { value: "/favorites", label: "المفضلة" },
  { value: "/orders", label: "طلباتي" },
  { value: "/reminders", label: "التذكيرات" },
  { value: "/support", label: "خدمة العملاء" },
];

export const LINK_HELP =
  "صيغ مدعومة: /products/{رقم الهدية} · /categories/{رقم التصنيف} · /search?gift_type=flowers&occasion=birthday · /special-gift · /orders · https://... (يُنسخ في التطبيق)";
