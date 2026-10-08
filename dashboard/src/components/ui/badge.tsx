import type { Tone } from "@/lib/labels";
import { cn } from "@/lib/utils";

const TONES: Record<Tone, string> = {
  amber: "bg-amber-100 text-amber-800 dark:bg-amber-500/15 dark:text-amber-300",
  sky: "bg-sky-100 text-sky-800 dark:bg-sky-500/15 dark:text-sky-300",
  violet: "bg-violet-100 text-violet-800 dark:bg-violet-500/15 dark:text-violet-300",
  green: "bg-emerald-100 text-emerald-800 dark:bg-emerald-500/15 dark:text-emerald-300",
  red: "bg-red-100 text-red-800 dark:bg-red-500/15 dark:text-red-300",
  gray: "bg-slate-100 text-slate-700 dark:bg-slate-500/15 dark:text-slate-300",
  rose: "bg-[#f6e3e0] text-[#4d0f14] dark:bg-[#b8505a]/20 dark:text-[#f0c9c4]",
};

export function Badge({
  tone = "gray",
  className,
  children,
}: {
  tone?: Tone;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 whitespace-nowrap rounded-full px-2.5 py-1 text-[11px] font-semibold",
        TONES[tone],
        className,
      )}
    >
      {children}
    </span>
  );
}
