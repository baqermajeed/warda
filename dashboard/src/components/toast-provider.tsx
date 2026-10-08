"use client";

import { createContext, useCallback, useContext, useMemo, useState } from "react";
import { CheckCircle2, AlertTriangle } from "lucide-react";
import { cn } from "@/lib/utils";

type Toast = { id: number; tone: "success" | "error"; text: string };

type ToastCtx = {
  success: (text: string) => void;
  error: (text: string) => void;
};

const Ctx = createContext<ToastCtx | null>(null);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const push = useCallback((tone: Toast["tone"], text: string) => {
    const id = Date.now() + Math.random();
    setToasts((t) => [...t, { id, tone, text }]);
    window.setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 4500);
  }, []);

  const value = useMemo(
    () => ({
      success: (text: string) => push("success", text),
      error: (text: string) => push("error", text),
    }),
    [push],
  );

  return (
    <Ctx.Provider value={value}>
      {children}
      <div
        className="pointer-events-none fixed inset-x-0 bottom-4 z-[60] flex flex-col items-center gap-2 px-4"
        dir="rtl"
        aria-live="polite"
      >
        {toasts.map((t) => (
          <div
            key={t.id}
            className={cn(
              "pointer-events-auto flex max-w-md items-center gap-2 rounded-2xl px-4 py-3 text-sm font-medium text-white shadow-xl",
              t.tone === "success" ? "bg-emerald-700" : "bg-red-700",
            )}
          >
            {t.tone === "success" ? (
              <CheckCircle2 className="h-4 w-4 shrink-0" />
            ) : (
              <AlertTriangle className="h-4 w-4 shrink-0" />
            )}
            {t.text}
          </div>
        ))}
      </div>
    </Ctx.Provider>
  );
}

export function useToast() {
  const v = useContext(Ctx);
  if (!v) throw new Error("useToast outside ToastProvider");
  return v;
}
