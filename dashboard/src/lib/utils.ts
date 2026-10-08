import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function money(n: number | string | null | undefined) {
  const v = Number(n ?? 0);
  if (Number.isNaN(v)) return "—";
  return `${v.toLocaleString("en-US")} د.ع`;
}

export function formatDate(iso: string | null | undefined, withTime = true) {
  if (!iso) return "—";
  // The API returns naive UTC timestamps.
  const d = new Date(iso.endsWith("Z") || iso.includes("+") ? iso : `${iso}Z`);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleString("ar-IQ-u-nu-latn", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    ...(withTime ? { hour: "2-digit", minute: "2-digit" } : {}),
  });
}

export function errorMessage(e: unknown, fallback = "حدث خطأ غير متوقع") {
  return e instanceof Error && e.message ? e.message : fallback;
}
