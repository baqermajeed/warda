"use client";

import { useState } from "react";
import Link from "next/link";
import { Plus, ShieldOff } from "lucide-react";
import { api } from "@/lib/api";
import type { Page, UserRow } from "@/lib/types";
import { errorMessage, formatDate } from "@/lib/utils";
import { useLoad } from "@/hooks/use-load";
import { useAuth } from "@/components/auth-provider";
import { useToast } from "@/components/toast-provider";
import { ErrorBox, LoadingBox, PageHeader } from "@/components/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";

export default function AdminsPage() {
  const toast = useToast();
  const { user: me } = useAuth();
  const { data, error, loading, reload } = useLoad(() =>
    api<Page<UserRow>>("/admin/users", { query: { role: "admin", page_size: 100 } }),
  );
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState({ name: "", phone: "", password: "" });
  const [saving, setSaving] = useState(false);

  const create = async () => {
    if (form.name.trim().length < 2) return toast.error("أدخل الاسم");
    if (form.password.length < 6) return toast.error("كلمة المرور 6 أحرف على الأقل");
    setSaving(true);
    try {
      await api("/admin/admins", { method: "POST", json: { ...form, name: form.name.trim(), phone: form.phone.trim() } });
      toast.success("تم إنشاء حساب الإدارة");
      setOpen(false);
      setForm({ name: "", phone: "", password: "" });
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  const revoke = async (u: UserRow) => {
    if (!window.confirm(`إزالة صلاحية الإدارة عن ${u.name}؟ سيبقى حسابه كزبون.`)) return;
    try {
      await api(`/admin/users/${u.id}`, { method: "PATCH", json: { is_admin: false } });
      toast.success("أُزيلت الصلاحية");
      reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  return (
    <div className="space-y-4">
      <PageHeader
        title="حسابات الإدارة"
        subtitle="من يستطيع الدخول إلى لوحة التحكم"
        onRefresh={reload}
        loading={loading}
        actions={
          <Button onClick={() => setOpen(true)}>
            <Plus className="h-4 w-4" />
            حساب إدارة جديد
          </Button>
        }
      />
      {error ? <ErrorBox message={error} onRetry={reload} /> : null}
      {loading && !data ? <LoadingBox /> : null}
      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
        {(data?.items ?? []).map((u) => (
          <GlassCard key={u.id} className="flex items-start justify-between gap-3 p-4">
            <Link href={`/app/customers/${u.id}`} className="min-w-0">
              <div className="flex items-center gap-2 font-semibold">
                {u.name}
                {u.id === me?.id ? <Badge tone="rose">أنت</Badge> : null}
                {!u.is_active ? <Badge tone="red">موقوف</Badge> : null}
              </div>
              <div className="text-xs text-[var(--muted-foreground)]" dir="ltr">
                {u.phone}
              </div>
              <div className="mt-1 text-[11px] text-[var(--muted-foreground)]">منذ {formatDate(u.created_at, false)}</div>
            </Link>
            {u.id !== me?.id ? (
              <Button size="sm" variant="ghost" onClick={() => revoke(u)}>
                <ShieldOff className="h-4 w-4" />
                إزالة
              </Button>
            ) : null}
          </GlassCard>
        ))}
      </div>

      <Modal
        open={open}
        onClose={() => setOpen(false)}
        size="sm"
        title="حساب إدارة جديد"
        subtitle="إن كان الرقم مسجلًا كزبون تُضاف له الصلاحية وتُحدَّث كلمة مروره"
        footer={
          <>
            <Button variant="secondary" onClick={() => setOpen(false)}>
              إلغاء
            </Button>
            <Button onClick={create} disabled={saving}>
              {saving ? "جاري الإنشاء…" : "إنشاء"}
            </Button>
          </>
        }
      >
        <div className="grid gap-3">
          <Field label="الاسم" required>
            <Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
          </Field>
          <Field label="رقم الهاتف" required hint="يُستخدم لتسجيل الدخول">
            <Input dir="ltr" inputMode="tel" placeholder="07XXXXXXXXX" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
          </Field>
          <Field label="كلمة المرور" required>
            <Input type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} />
          </Field>
        </div>
      </Modal>
    </div>
  );
}
