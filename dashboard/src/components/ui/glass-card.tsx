import { cn } from "@/lib/utils";

export function GlassCard({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      className={cn("glass-panel rounded-[24px] text-[var(--card-foreground)]", className)}
      {...props}
    />
  );
}
