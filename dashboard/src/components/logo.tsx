import { cn } from "@/lib/utils";

/** Rose mark — Warda brand monogram. */
export function Logo({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-[#4d0f14] to-[#ad8a83] shadow-[0_8px_24px_rgba(77,15,20,0.35)]",
        className,
      )}
      aria-hidden
    >
      <svg viewBox="0 0 48 48" className="h-6 w-6 text-white" fill="currentColor">
        <path d="M24 8c-3 3-9 4-9 11 0 5 4 9 9 9s9-4 9-9c0-7-6-8-9-11Zm0 5c2 2 5 3 5 6.5a5 5 0 0 1-10 0C19 16 22 15 24 13Z" />
        <path d="M23 28h2v12h-2z" />
        <path d="M25 34c3-4 7-5 10-4-1 4-5 6-10 6v-2Zm-2 0c-3-4-7-5-10-4 1 4 5 6 10 6v-2Z" />
      </svg>
    </div>
  );
}

export function BrandWordmark({ inverted }: { inverted?: boolean }) {
  return (
    <div className="leading-tight">
      <div className={cn("text-base font-bold", inverted ? "text-white" : "text-[var(--foreground)]")}>
        وردة
      </div>
      <div className={cn("text-[11px]", inverted ? "text-rose-200/70" : "text-[var(--muted-foreground)]")}>
        لوحة التحكم
      </div>
    </div>
  );
}
