"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { Bell, Gift, Image as ImageIcon, Lock, Package } from "lucide-react";
import { BrandWordmark, Logo } from "@/components/logo";
import { useAuth } from "@/components/auth-provider";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Field, Input } from "@/components/ui/input";
import { ThemeToggle } from "@/components/theme-toggle";
import { errorMessage } from "@/lib/utils";

const FEATURES = [
  { icon: Gift, text: "إدارة الهدايا والتصنيفات" },
  { icon: ImageIcon, text: "إعلانات الصفحة الرئيسية" },
  { icon: Package, text: "متابعة الطلبات وحالاتها" },
  { icon: Bell, text: "إشعارات وخدمة العملاء" },
];

export default function LoginPage() {
  const { login, user, ready } = useAuth();
  const router = useRouter();
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (ready && user) router.replace("/app");
  }, [ready, user, router]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError("");
    try {
      await login(phone.trim(), password);
      router.push("/app");
    } catch (err) {
      setError(errorMessage(err, "فشل تسجيل الدخول"));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="dash-canvas relative min-h-screen" dir="rtl">
      <div className="absolute left-4 top-4 z-10">
        <ThemeToggle />
      </div>
      <div className="mx-auto grid max-w-5xl gap-8 px-4 py-10 lg:grid-cols-2 lg:items-center lg:py-20">
        <div className="relative hidden overflow-hidden rounded-[32px] bg-gradient-to-br from-[#4d0f14] via-[#6e2a31] to-[#ad8a83] p-10 text-white lg:block">
          <div className="absolute -left-16 -top-16 h-64 w-64 rounded-full bg-white/10 blur-2xl" />
          <div className="absolute -bottom-20 -right-10 h-72 w-72 rounded-full bg-[#c7a49d]/30 blur-3xl" />
          <div className="relative">
            <div className="mb-6 flex items-center gap-3">
              <Logo className="h-12 w-12 bg-none bg-white/15" />
              <BrandWordmark inverted />
            </div>
            <h2 className="text-3xl font-extrabold leading-snug">كل ما يراه زبائنك في التطبيق، تتحكم به من هنا</h2>
            <p className="mt-3 text-sm text-rose-100/80">هدايا · تصنيفات · إعلانات · طلبات · إشعارات</p>
            <div className="mt-8 grid grid-cols-2 gap-3">
              {FEATURES.map(({ icon: Icon, text }) => (
                <div key={text} className="flex items-start gap-2 rounded-2xl bg-black/20 p-3 text-xs backdrop-blur">
                  <Icon className="mt-0.5 h-4 w-4 shrink-0 text-rose-200" />
                  {text}
                </div>
              ))}
            </div>
          </div>
        </div>

        <GlassCard className="mx-auto w-full max-w-md p-6 sm:p-8">
          <div className="mb-6 flex items-center gap-3 lg:hidden">
            <Logo />
            <BrandWordmark />
          </div>
          <form onSubmit={onSubmit} className="space-y-4">
            <div>
              <p className="text-xs font-medium text-[var(--accent)]">مرحباً بعودتك</p>
              <h1 className="mt-1 text-2xl font-bold">دخول لوحة التحكم</h1>
              <p className="mt-1 text-sm text-[var(--muted-foreground)]">لحسابات الإدارة فقط</p>
            </div>
            <Field label="رقم الهاتف">
              <Input
                autoComplete="username"
                inputMode="tel"
                dir="ltr"
                className="text-right"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                required
                placeholder="07XXXXXXXXX"
              />
            </Field>
            <Field label="كلمة المرور">
              <Input
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </Field>
            {error ? (
              <p className="rounded-xl bg-red-500/10 px-3 py-2 text-sm text-red-700 dark:text-red-300">{error}</p>
            ) : null}
            <Button type="submit" className="w-full" disabled={busy}>
              {busy ? "جاري الدخول…" : "تسجيل الدخول"}
            </Button>
            <p className="flex items-center gap-2 text-[11px] text-[var(--muted-foreground)]">
              <Lock className="h-3.5 w-3.5" />
              اتصال آمن بالـ API · جلسة تتجدد تلقائيًا
            </p>
          </form>
        </GlassCard>
      </div>
    </div>
  );
}
