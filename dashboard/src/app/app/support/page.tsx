"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { MessageSquareReply, Phone, Settings, Trash2 } from "lucide-react";
import { api } from "@/lib/api";
import type { Page, Ticket } from "@/lib/types";
import { TICKET_STATUSES, ticketStatus } from "@/lib/labels";
import { appLabel } from "@/lib/app-labels";
import { errorMessage, formatDate } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useToast } from "@/components/toast-provider";
import { EmptyBox, ErrorBox, LoadingBox, PageHeader, Pagination } from "@/components/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Select, Textarea } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";

const PAGE_SIZE = 20;

export default function SupportPage() {
  const toast = useToast();
  const [status, setStatus] = useState("open");
  const [page, setPage] = useState(1);
  const list = useLoad(() => api<Page<Ticket>>("/admin/support/tickets", { query: { status, page, page_size: PAGE_SIZE } }), [status, page]);
  useEffect(() => setPage(1), [status]);
  const [reply, setReply] = useState<{ ticket: Ticket; text: string; status: string } | null>(null);
  const [saving, setSaving] = useState(false);

  const update = async (t: Ticket, body: { status?: string; reply?: string }, msg: string) => {
    setSaving(true);
    try {
      await api(`/admin/support/tickets/${t.id}`, { method: "PATCH", json: body });
      toast.success(msg);
      setReply(null);
      list.reload();
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  const remove = async (t: Ticket) => {
    if (!window.confirm("حذف هذه الرسالة نهائيًا؟")) return;
    try {
      await api(`/admin/support/tickets/${t.id}`, { method: "DELETE" });
      toast.success("تم الحذف");
      list.reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const rows = list.data?.items ?? [];
  const subject = (s: string) => (s.startsWith("support_subject_") ? appLabel(s) : s);

  return (
    <div className="space-y-4">
      <PageHeader
        title="خدمة العملاء"
        subtitle="الرسائل المرسلة من صفحة الحساب ← خدمة العملاء في التطبيق"
        onRefresh={list.reload}
        loading={list.loading}
        actions={
          <Link href="/app/settings">
            <Button variant="secondary">
              <Settings className="h-4 w-4" />
              أرقام التواصل وأوقات العمل
            </Button>
          </Link>
        }
      />
      <div className="flex flex-wrap gap-1">
        {TICKET_STATUSES.map((s) => (
          <Button key={s.id} size="sm" variant={status === s.id ? "default" : "secondary"} onClick={() => setStatus(s.id)}>
            {s.label}
          </Button>
        ))}
        <Button size="sm" variant={status === "" ? "default" : "secondary"} onClick={() => setStatus("")}>
          الكل
        </Button>
      </div>

      {list.error ? <ErrorBox message={list.error} onRetry={list.reload} /> : null}
      {list.loading && !list.data ? <LoadingBox /> : null}
      {list.data && rows.length === 0 ? <EmptyBox message="لا توجد رسائل" /> : null}

      <div className="grid gap-3">
        {rows.map((t) => {
          const st = ticketStatus(t.status);
          return (
            <GlassCard key={t.id} className="p-4">
              <div className="flex flex-wrap items-start justify-between gap-2">
                <div className="min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-bold">{subject(t.subject)}</span>
                    <Badge tone={st.tone}>{st.label}</Badge>
                    {!t.user_id ? <Badge tone="gray">زائر بدون حساب</Badge> : null}
                  </div>
                  <div className="mt-1 text-[11px] text-[var(--muted-foreground)]">
                    {t.user_id ? (
                      <Link href={`/app/customers/${t.user_id}`} className="hover:underline">
                        {t.name || t.user_name || "زبون"}
                      </Link>
                    ) : (
                      t.name || "بدون اسم"
                    )}
                    {t.phone ? (
                      <>
                        {" · "}
                        <a href={`tel:${t.phone}`} dir="ltr" className="hover:underline">
                          {t.phone}
                        </a>
                      </>
                    ) : null}
                    {" · "}
                    {formatDate(t.created_at)}
                  </div>
                </div>
                <div className="flex flex-wrap gap-1">
                  <Button size="sm" onClick={() => setReply({ ticket: t, text: "", status: t.status === "open" ? "in_progress" : t.status })}>
                    <MessageSquareReply className="h-4 w-4" /> رد / تغيير الحالة
                  </Button>
                  {t.phone ? (
                    <a href={`tel:${t.phone}`}>
                      <Button size="sm" variant="secondary">
                        <Phone className="h-4 w-4" /> اتصال
                      </Button>
                    </a>
                  ) : null}
                  <Button size="icon" variant="ghost" onClick={() => remove(t)} aria-label="حذف">
                    <Trash2 className="h-4 w-4 text-red-600" />
                  </Button>
                </div>
              </div>
              <p className="mt-3 whitespace-pre-line rounded-2xl bg-[var(--muted)]/70 p-3 text-sm leading-7">{t.message}</p>
            </GlassCard>
          );
        })}
      </div>
      <Pagination page={page} pageSize={PAGE_SIZE} total={list.data?.total ?? 0} onPage={setPage} />

      <Modal
        open={!!reply}
        onClose={() => setReply(null)}
        title="الرد على الرسالة"
        subtitle={reply ? subject(reply.ticket.subject) : undefined}
        footer={
          <>
            <Button variant="secondary" onClick={() => setReply(null)}>
              إلغاء
            </Button>
            <Button
              disabled={saving}
              onClick={() =>
                reply &&
                update(
                  reply.ticket,
                  { status: reply.status, ...(reply.text.trim() ? { reply: reply.text.trim() } : {}) },
                  reply.text.trim() ? "أُرسل الرد كإشعار للزبون" : "تم تحديث الحالة",
                )
              }
            >
              {saving ? "جاري الحفظ…" : "حفظ"}
            </Button>
          </>
        }
      >
        {reply ? (
          <div className="grid gap-3">
            <p className="whitespace-pre-line rounded-2xl bg-[var(--muted)]/70 p-3 text-sm leading-7">{reply.ticket.message}</p>
            <Field
              label="الرد"
              hint={
                reply.ticket.user_id
                  ? "يصل الرد للزبون كإشعار داخل التطبيق."
                  : "الرسالة من زائر بدون حساب — لا يمكن إرسال رد داخل التطبيق، تواصل معه عبر الهاتف."
              }
            >
              <Textarea rows={4} disabled={!reply.ticket.user_id} value={reply.text} onChange={(e) => setReply({ ...reply, text: e.target.value })} />
            </Field>
            <Field label="الحالة">
              <Select value={reply.status} onChange={(e) => setReply({ ...reply, status: e.target.value })}>
                {TICKET_STATUSES.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.label}
                  </option>
                ))}
              </Select>
            </Field>
          </div>
        ) : null}
      </Modal>
    </div>
  );
}
