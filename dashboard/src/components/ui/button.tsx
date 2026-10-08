import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex cursor-pointer items-center justify-center gap-2 rounded-2xl text-sm font-medium transition duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--ring)] disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "btn-primary-gradient glow-primary min-h-11 px-5",
        secondary:
          "min-h-11 border border-[var(--border)] bg-[var(--card)] px-5 text-[var(--foreground)] hover:bg-[var(--muted)]",
        ghost:
          "min-h-10 px-3 text-[var(--muted-foreground)] hover:bg-[var(--muted)] hover:text-[var(--foreground)]",
        danger: "min-h-11 bg-red-700 px-5 text-white hover:bg-red-800",
        outline:
          "min-h-11 border border-[var(--border)] bg-transparent px-5 text-[var(--foreground)] hover:bg-[var(--muted)]",
      },
      size: {
        default: "",
        icon: "h-10 w-10 min-h-0 shrink-0 rounded-xl p-0",
        sm: "min-h-9 px-3 text-xs",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  },
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, type = "button", ...props }, ref) => (
    <button
      ref={ref}
      type={type}
      className={cn(buttonVariants({ variant, size }), className)}
      {...props}
    />
  ),
);
Button.displayName = "Button";
