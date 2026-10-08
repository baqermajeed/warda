"use client";

import { Suspense, useState } from "react";
import { useSearchParams } from "next/navigation";
import { Bell, Send, Trash2, Users, User } from "lucide-react";
import { api } from "@/lib/api";
import type { Broadcast, Page } from "@/lib/types";
import { APP_LINK_PRESETS, LINK_HELP } from "@/lib/labels";
import { errorMessage, formatDate } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { EmptyBox, ErrorBox, LoadingBox, PageHeader, Pagination } from "@/components/page-header";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input, Select, Textarea } from "@/components/ui/input";

const PAGE_SIZE = 15;

function NotificationsInner() {
  const toast = useToast();
  const params = useSearchParams();
  const presetPhone = params.get("phone") ?? "";
  const [target, setTarget] = useState<"all" | "one">(presetPhone ? "one" : "all");
  const [form, setForm] = useState({ title_ar: "", title_en: "", body_ar: "", body_en: "", link: "", phone: presetPhone });
  const [sending, setSending] = useState(false);
  const [page, setPage] = useState(1);
  const history = useLoad(() => api<Page<Broadcast>>("/admin/notifications", { query: { page, page_size: PAGE_SIZE } }), [page]);

  const set = (k: keyof typeof form, v: string) => setForm((f) => ({ ...f, [k]: v }));

  const send = async () => {
    if (!form.title_ar.trim()) return toast.error("أدخل عنوان الإشعار");
    if (target === "one" && !form.phone.trim()) return toast.error("أدخل رقم هاتف الزبون");
    const who = target === "all" ? "كل الزبائن الذين فعّلوا الإشعارات" : form.phone;
    if (!window.confirm(`إرسال الإشعار إلى: ${who}؟`)) return;
    setSending(true);
    try {
      const res = await api<{ recipients: number }>("/admin/notifications", {
        method: "POST",
        json: {
          ...form,
          link: form.link.trim() || null,
          phone: target === "one" ? form.phone.trim() : null,
        },
      });
      toast.success(`أُرسل الإشعار إلى ${res.recipients} مستخدم`);
      setForm({ title_ar: "", title_en: "", body_ar: "", body_en: "", link: "", phone: "" });
      setPage(1);
      history.reload();
    } catch (e) {
      toast.error(errorMessage(e, "فشل الإرسال"));
    } finally {
      setSending(false);
    }
  };

  const remove = async (b: Broadcast) => {
    if (!window.confirm("حذف هذا الإشعار من صناديق كل المستلمين؟")) return;
    try {
      await api(`/admin/notifications/${encodeURIComponent(b.key)}`, { method: "DELETE" });
      toast.success("تم حذف الإشعار");
      history.reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  return (
    <div className="space-y-4">
      <PageHeader title="الإشعارات" subtitle="إرسال إشعارات تظهر في شاشة الإشعارات (الجرس) داخل التطبيق" />

      <div className="grid gap-4 lg:grid-cols-5">
        <GlassCard className="space-y-3 p-4 lg:col-span-3">
          <h3 className="text-sm font-bold">إشعار جديد</h3>
          <div className="flex gap-2">
            <Button size="sm" variant={target === "all" ? "default" : "secondary"} onClick={() => setTarget("all")}>
              <Users className="h-4 w-4" /> كل الزبائن
            </Button>
            <Button size="sm" variant={target === "one" ? "default" : "secondary"} onClick={() => setTarget("one")}>
              <User className="h-4 w-4" /> زبون محدد
            </Button>
          </div>
          {target === "one" ? (
            <Field label="رقم هاتف الزبون" required>
              <Input dir="ltr" inputMode="tel" placeholder="07XXXXXXXXX" value={form.phone} onChange={(e) => set("phone", e.target.value)} />
            </Field>
          ) : (
            <p className="text-[11px] text-[var(--muted-foreground)]">
              يصل لكل الحسابات المفعّلة التي لم توقف الإشعارات من صفحة الحساب في التطبيق.
            </p>
          )}
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="العنوان (عربي)" required>
              <Input value={form.title_ar} onChange={(e) => set("title_ar", e.target.value)} maxLength={200} />
            </Field>
            <Field label="العنوان (إنجليزي)" hint="اختياري">
              <Input dir="ltr" value={form.title_en} onChange={(e) => set("title_en", e.target.value)} maxLength={200} />
            </Field>
            <Field label="النص (عربي)">
              <Textarea rows={3} value={form.body_ar} onChange={(e) => set("body_ar", e.target.value)} />
            </Field>
            <Field label="النص (إنجليزي)">
              <Textarea dir="ltr" rows={3} value={form.body_en} onChange={(e) => set("body_en", e.target.value)} />
            </Field>
          </div>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="عند الضغط على الإشعار">
              <Select value={APP_LINK_PRESETS.some((p) => p.value === form.link) ? form.link : "__custom"} onChange={(e) => set("link", e.target.value === "__custom" ? "/products/" : e.target.value)}>
                {APP_LINK_PRESETS.map((p) => (
                  <option key={p.value} value={p.value}>
                    {p.label}
                  </option>
                ))}
                <option value="__custom">رابط مخصص…</option>
              </Select>
            </Field>
            <Field label="الرابط" hint={LINK_HELP}>
              <Input dir="ltr" value={form.link} onChange={(e) => set("link", e.target.value)} />
            </Field>
          </div>
          <Button onClick={send} disabled={sending}>
            <Send className="h-4 w-4" />
            {sending ? "جاري الإرسال…" : "إرسال"}
          </Button>
        </GlassCard>

        <GlassCard className="p-4 lg:col-span-2">
          <h3 className="mb-3 text-sm font-bold">معاينة</h3>
          <div className="flex items-start gap-3 rounded-[23px] bg-white p-4 text-[#402628] shadow-[0_0_10px_rgba(77,15,20,0.16)]">
            <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-[#4d0f14]/10">
              <Bell className="h-5 w-5 text-[#4d0f14]" />
            </div>
            <div className="min-w-0 flex-1">
              <div className="font-extrabold">{form.title_ar || "عنوان الإشعار"}</div>
              {form.body_ar ? <div className="mt-1 text-xs text-[#555553]">{form.body_ar}</div> : null}
              <div className="mt-1.5 text-[11px] text-[#555553]/60">الآن</div>
            </div>
            <span className="mt-1.5 h-2 w-2 rounded-full bg-[#ad8a83]" />
          </div>
          <p className="mt-3 text-[11px] leading-5 text-[var(--muted-foreground)]">
            يصل الزبون تلقائيًا أيضًا إشعار عند تغيير حالة طلبه، وعند الرد على رسالته في خدمة العملاء، وقبل مواعيد
            تذكيراته.
          </p>
        </GlassCard>
      </div>

      <h3 className="pt-2 text-sm font-bold">الإشعارات المرسلة</h3>
      {history.error ? <ErrorBox message={history.error} onRetry={history.reload} /> : null}
      {history.loading && !history.data ? <LoadingBox /> : null}
      {history.data && history.data.items.length === 0 ? <EmptyBox message="لم تُرسل إشعارات بعد" /> : null}
      <div className="grid gap-2">
        {(history.data?.items ?? []).map((b) => (
          <GlassCard key={b.key} className="flex flex-wrap items-center gap-3 p-4">
            <div className="min-w-0 flex-1">
              <div className="font-semibold">{b.title_ar}</div>
              {b.body_ar ? <div className="text-xs text-[var(--muted-foreground)]">{b.body_ar}</div> : null}
              <div className="mt-1 text-[11px] text-[var(--muted-foreground)]">
                {formatDate(b.created_at)} · {b.recipients} مستلم · قرأه {b.read}
                {b.link ? (
                  <>
                    {" "}
                    · <span dir="ltr">{b.link}</span>
                  </>
                ) : null}
              </div>
            </div>
            <Button size="sm" variant="ghost" onClick={() => remove(b)}>
              <Trash2 className="h-4 w-4 text-red-600" /> حذف
            </Button>
          </GlassCard>
        ))}
      </div>
      <Pagination page={page} pageSize={PAGE_SIZE} total={history.data?.total ?? 0} onPage={setPage} />
    </div>
  );
}

export default function NotificationsPage() {
  return (
    <Suspense fallback={<LoadingBox />}>
      <NotificationsInner />
    </Suspense>
  );
}
