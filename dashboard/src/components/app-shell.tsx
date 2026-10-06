"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import {
  Bell,
  FolderTree,
  Gift,
  HelpCircle,
  Image as ImageIcon,
  LayoutDashboard,
  LogOut,
  Menu,
  MessageSquare,
  Package,
  PackagePlus,
  Settings,
  Shield,
  ShieldCheck,
  Users,
  X,
} from "lucide-react";
import { BrandWordmark, Logo } from "@/components/logo";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";
import { useAuth } from "@/components/auth-provider";
import { api } from "@/lib/api";
import { cn } from "@/lib/utils";

type NavItem = {
  href: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  badge?: "orders" | "tickets";
};

const NAV: { title: string; items: NavItem[] }[] = [
  {
    title: "عام",
    items: [
      { href: "/app", label: "الرئيسية", icon: LayoutDashboard },
      { href: "/app/orders", label: "الطلبات", icon: Package, badge: "orders" },
      { href: "/app/customers", label: "الزبائن", icon: Users },
    ],
  },
  {
    title: "المتجر",
    items: [
      { href: "/app/products", label: "الهدايا", icon: Gift },
      { href: "/app/categories", label: "التصنيفات", icon: FolderTree },
      { href: "/app/banners", label: "إعلانات الرئيسية", icon: ImageIcon },
      { href: "/app/options", label: "البطاقات والتغليف والإضافات", icon: PackagePlus },
    ],
  },
  {
    title: "صفحة الحساب في التطبيق",
    items: [
      { href: "/app/notifications", label: "الإشعارات", icon: Bell },
      { href: "/app/support", label: "خدمة العملاء", icon: MessageSquare, badge: "tickets" },
      { href: "/app/faq", label: "الأسئلة الشائعة", icon: HelpCircle },
      { href: "/app/privacy", label: "سياسة الخصوصية", icon: ShieldCheck },
    ],
  },
  {
    title: "النظام",
    items: [
      { href: "/app/settings", label: "الإعدادات", icon: Settings },
      { href: "/app/admins", label: "حسابات الإدارة", icon: Shield },
    ],
  },
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const { user, logout, ready } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [menuOpen, setMenuOpen] = useState(false);
  const [counts, setCounts] = useState({ orders: 0, tickets: 0 });

  useEffect(() => {
    if (ready && !user) router.replace("/login");
  }, [ready, user, router]);

  useEffect(() => setMenuOpen(false), [pathname]);

  const loadCounts = useCallback(async () => {
    try {
      const s = await api<{ orders_pending: number; tickets_open: number }>("/admin/stats");
      setCounts({ orders: s.orders_pending, tickets: s.tickets_open });
    } catch {
      // badges are optional
    }
  }, []);

  useEffect(() => {
    if (!user) return;
    loadCounts();
    const t = window.setInterval(loadCounts, 60_000);
    return () => window.clearInterval(t);
  }, [user, loadCounts, pathname]);

  if (!ready || !user) {
    return (
      <div className="dash-canvas flex min-h-screen items-center justify-center text-[var(--muted-foreground)]">
        جاري التحميل…
      </div>
    );
  }

  const nav = (
    <>
      <div className="flex items-center justify-between gap-2 px-4 py-5">
        <div className="flex items-center gap-3">
          <Logo />
          <BrandWordmark inverted />
        </div>
        <Button
          variant="ghost"
          size="icon"
          className="text-rose-100 hover:bg-white/10 hover:text-white md:hidden"
          aria-label="إغلاق القائمة"
          onClick={() => setMenuOpen(false)}
        >
          <X className="h-5 w-5" />
        </Button>
      </div>
      <nav className="flex-1 space-y-4 overflow-y-auto px-2 pb-4">
        {NAV.map((sec) => (
          <div key={sec.title}>
            <div className="mb-1 px-3 text-[10px] font-semibold tracking-wide text-rose-200/50">{sec.title}</div>
            <div className="space-y-0.5">
              {sec.items.map((item) => {
                const Icon = item.icon;
                const active = item.href === "/app" ? pathname === "/app" : pathname.startsWith(item.href);
                const badge = item.badge ? counts[item.badge] : 0;
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={cn(
                      "flex min-h-11 items-center gap-2.5 rounded-xl px-3 py-2.5 text-sm text-rose-100/80 transition hover:bg-white/10 hover:text-white",
                      active && "bg-gradient-to-l from-[#7a2a31] to-[#ad8a83] text-white shadow-[0_8px_24px_rgba(77,15,20,0.45)]",
                    )}
                  >
                    <Icon className="h-4 w-4 shrink-0" />
                    <span className="flex-1">{item.label}</span>
                    {badge > 0 ? (
                      <span className="min-w-[1.4rem] rounded-full bg-rose-500 px-1.5 py-0.5 text-center text-[10px] font-bold text-white">
                        {badge > 99 ? "99+" : badge}
                      </span>
                    ) : null}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>
      <div className="border-t border-white/10 p-3">
        <div className="mb-2 px-1 text-xs text-rose-100/80">
          {user.name}
          <div className="mt-0.5 text-[11px] text-rose-200/50" dir="ltr">
            {user.phone}
          </div>
        </div>
        <Button
          variant="secondary"
          className="w-full justify-start border-white/10 bg-white/5 text-white hover:bg-white/10"
          onClick={async () => {
            await logout();
            router.push("/login");
          }}
        >
          <LogOut className="h-4 w-4" />
          تسجيل الخروج
        </Button>
      </div>
    </>
  );

  return (
    <div className="dash-canvas flex min-h-screen" dir="rtl">
      <aside className="sticky top-0 hidden h-screen w-72 shrink-0 flex-col bg-[var(--sidebar)] md:flex">{nav}</aside>
      {menuOpen ? (
        <div className="fixed inset-0 z-50 md:hidden">
          <button className="absolute inset-0 bg-black/45 backdrop-blur-sm" aria-label="إغلاق" onClick={() => setMenuOpen(false)} />
          <aside className="absolute inset-y-0 right-0 flex w-[84%] max-w-xs flex-col bg-[var(--sidebar)] shadow-2xl">{nav}</aside>
        </div>
      ) : null}
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-20 flex items-center gap-3 border-b border-[var(--border)]/80 bg-[var(--card)]/80 px-4 py-3 backdrop-blur-xl">
          <Button variant="ghost" size="icon" className="md:hidden" aria-label="القائمة" onClick={() => setMenuOpen(true)}>
            <Menu className="h-5 w-5" />
          </Button>
          <div className="min-w-0 flex-1">
            <h1 className="truncate text-sm font-semibold text-[var(--foreground)] md:text-base">لوحة تحكم وردة</h1>
            <p className="truncate text-[11px] text-[var(--muted-foreground)]">كل ما يظهر في التطبيق يُدار من هنا</p>
          </div>
          <ThemeToggle />
        </header>
        <main className="flex-1 p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
