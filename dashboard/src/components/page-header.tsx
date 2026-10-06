"use client";

import { ChevronLeft, ChevronRight, RefreshCw, Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Input } from "@/components/ui/input";

export function PageHeader({
  title,
  subtitle,
  onRefresh,
  loading,
  actions,
}: {
  title: string;
  subtitle?: React.ReactNode;
  onRefresh?: () => void;
  loading?: boolean;
  actions?: React.ReactNode;
}) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-3">
      <div>
        <h2 className="text-xl font-bold text-[var(--foreground)]">{title}</h2>
        {subtitle ? <div className="mt-1 text-xs text-[var(--muted-foreground)]">{subtitle}</div> : null}
      </div>
      <div className="flex flex-wrap items-center gap-2">
        {onRefresh ? (
          <Button variant="secondary" onClick={onRefresh} disabled={loading}>
            <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
            تحديث
          </Button>
        ) : null}
        {actions}
      </div>
    </div>
  );
}

export function ErrorBox({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-2 rounded-2xl border border-red-300/60 bg-red-50 px-4 py-3 text-sm text-red-800 dark:bg-red-500/10 dark:text-red-300">
      {message}
      {onRetry ? (
        <Button size="sm" variant="secondary" onClick={onRetry}>
          إعادة المحاولة
        </Button>
      ) : null}
    </div>
  );
}

export function EmptyBox({ message = "لا توجد بيانات", children }: { message?: string; children?: React.ReactNode }) {
  return (
    <GlassCard className="px-4 py-12 text-center text-sm text-[var(--muted-foreground)]">
      {message}
      {children ? <div className="mt-4 flex justify-center">{children}</div> : null}
    </GlassCard>
  );
}

export function LoadingBox() {
  return (
    <div className="grid gap-3">
      {[0, 1, 2].map((i) => (
        <div key={i} className="h-16 animate-pulse rounded-2xl bg-[var(--muted)]/70" />
      ))}
    </div>
  );
}

export function SearchInput({
  value,
  onChange,
  placeholder = "بحث…",
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
}) {
  return (
    <div className="relative min-w-[220px] flex-1">
      <Search className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[var(--muted-foreground)]" />
      <Input value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} className="pr-9" />
    </div>
  );
}

export function Pagination({
  page,
  pageSize,
  total,
  onPage,
}: {
  page: number;
  pageSize: number;
  total: number;
  onPage: (p: number) => void;
}) {
  const pages = Math.max(1, Math.ceil(total / pageSize));
  if (total === 0) return null;
  return (
    <div className="flex items-center justify-between gap-2 text-xs text-[var(--muted-foreground)]">
      <span>
        {total} سجل · صفحة {page} من {pages}
      </span>
      <div className="flex gap-1">
        <Button size="icon" variant="secondary" disabled={page <= 1} onClick={() => onPage(page - 1)} aria-label="السابق">
          <ChevronRight className="h-4 w-4" />
        </Button>
        <Button size="icon" variant="secondary" disabled={page >= pages} onClick={() => onPage(page + 1)} aria-label="التالي">
          <ChevronLeft className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}

export type Column<T> = {
  key: string;
  label: string;
  className?: string;
  render: (row: T) => React.ReactNode;
};

export function DataTable<T>({
  columns,
  rows,
  rowKey,
  onRowClick,
}: {
  columns: Column<T>[];
  rows: T[];
  rowKey: (row: T) => string | number;
  onRowClick?: (row: T) => void;
}) {
  return (
    <GlassCard className="overflow-hidden p-0">
      <div className="table-scroll">
        <table className="min-w-full text-sm">
          <thead className="bg-[var(--muted)]/60 text-[var(--muted-foreground)]">
            <tr>
              {columns.map((c) => (
                <th key={c.key} className={`whitespace-nowrap px-4 py-3 text-right text-xs font-semibold ${c.className ?? ""}`}>
                  {c.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr
                key={rowKey(row)}
                onClick={onRowClick ? () => onRowClick(row) : undefined}
                className={`border-t border-[var(--border)] transition hover:bg-[var(--muted)]/40 ${onRowClick ? "cursor-pointer" : ""}`}
              >
                {columns.map((c) => (
                  <td key={c.key} className={`px-4 py-3 align-middle text-[var(--foreground)] ${c.className ?? ""}`}>
                    {c.render(row)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </GlassCard>
  );
}
