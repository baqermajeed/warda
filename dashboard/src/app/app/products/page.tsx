"use client";

import { Suspense, useCallback, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Eye, EyeOff, Pencil, Pin, Plus, Sparkles, Trash2, TrendingUp } from "lucide-react";
import { api } from "@/lib/api";
import type { Category, Page, ProductRow } from "@/lib/types";
import { tagLabel } from "@/lib/labels";
import { cn, errorMessage, money } from "@/lib/utils";
import { useDebounced, useLoad } from "@/hooks/use-load";
import { useLookups } from "@/hooks/use-lookups";
import { useToast } from "@/components/toast-provider";
import {
  DataTable,
  EmptyBox,
  ErrorBox,
  LoadingBox,
  PageHeader,
  Pagination,
  SearchInput,
} from "@/components/page-header";
import { ProductEditor } from "@/components/product-editor";
import { Thumb } from "@/components/image-upload";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { GlassCard } from "@/components/ui/glass-card";
import { Select } from "@/components/ui/input";

const PAGE_SIZE = 20;

function ProductsInner() {
  const toast = useToast();
  const router = useRouter();
  const params = useSearchParams();
  const tags = useLookups();
  const [q, setQ] = useState("");
  const query = useDebounced(q);
  const [status, setStatus] = useState("");
  const [categoryId, setCategoryId] = useState(params.get("category") ?? "");
  const [pinned, setPinned] = useState("");
  const [sort, setSort] = useState("newest");
  const [page, setPage] = useState(1);
  const [editor, setEditor] = useState<{ open: boolean; id: number | null }>({ open: false, id: null });

  const categories = useLoad(() => api<Category[]>("/admin/categories"));
  const list = useLoad(
    () =>
      api<Page<ProductRow>>("/admin/products", {
        query: { q: query, status, category_id: categoryId, pinned, sort, page, page_size: PAGE_SIZE },
      }),
    [query, status, categoryId, pinned, sort, page],
  );

  useEffect(() => setPage(1), [query, status, categoryId, pinned, sort]);

  // Deep link from the overview page: /app/products?edit=12
  useEffect(() => {
    const edit = params.get("edit");
    if (edit) setEditor({ open: true, id: Number(edit) });
  }, [params]);

  const closeEditor = useCallback(() => {
    setEditor({ open: false, id: null });
    if (params.get("edit")) router.replace("/app/products");
  }, [params, router]);

  const patch = async (p: ProductRow, body: Partial<ProductRow>, done: string) => {
    try {
      await api(`/admin/products/${p.id}`, { method: "PATCH", json: body });
      toast.success(done);
      list.reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const remove = async (p: ProductRow) => {
    if (!window.confirm(`حذف «${p.title_ar}» نهائيًا؟\nستُزال من السلات والمفضلة، وتبقى في سجل الطلبات السابقة.\nلإخفائها مؤقتًا استخدم زر الإخفاء بدل الحذف.`)) return;
    try {
      await api(`/admin/products/${p.id}`, { method: "DELETE" });
      toast.success("تم حذف الهدية");
      list.reload();
    } catch (e) {
      toast.error(errorMessage(e));
    }
  };

  const rows = list.data?.items ?? [];

  return (
    <div className="space-y-4">
      <PageHeader
        title="الهدايا"
        subtitle="كل الهدايا في التطبيق — الصور والأسعار والفلاتر و«أحدث الهدايا» و«الأكثر شهرة»"
        onRefresh={list.reload}
        loading={list.loading}
        actions={
          <Button onClick={() => setEditor({ open: true, id: null })}>
            <Plus className="h-4 w-4" />
            هدية جديدة
          </Button>
        }
      />

      <GlassCard className="grid gap-3 p-4 text-xs leading-6 text-[var(--muted-foreground)] md:grid-cols-2">
        <div className="flex gap-2">
          <Sparkles className="mt-1 h-4 w-4 shrink-0 text-[var(--accent)]" />
          <span>
            <b className="text-[var(--foreground)]">أحدث الهدايا:</b> تلقائيًا حسب تاريخ الإضافة (الأحدث أولًا). اضغط
            التثبيت لإبقاء هدية في أول القائمة.
          </span>
        </div>
        <div className="flex gap-2">
          <TrendingUp className="mt-1 h-4 w-4 shrink-0 text-[var(--accent)]" />
          <span>
            <b className="text-[var(--foreground)]">الأكثر شهرة:</b> تلقائيًا = (القطع المباعة × 2) + مرات الإضافة
            للمفضلة، بدون الطلبات الملغاة. التثبيت يقدّم الهدية على الترتيب التلقائي.
          </span>
        </div>
      </GlassCard>

      <GlassCard className="flex flex-wrap gap-2 p-3">
        <SearchInput value={q} onChange={setQ} placeholder="بحث بالاسم أو SKU…" />
        <Select className="w-auto" value={status} onChange={(e) => setStatus(e.target.value)}>
          <option value="">كل الحالات</option>
          <option value="active">معروضة</option>
          <option value="hidden">مخفية</option>
        </Select>
        <Select className="w-auto" value={categoryId} onChange={(e) => setCategoryId(e.target.value)}>
          <option value="">كل التصنيفات</option>
          {(categories.data ?? []).map((c) => (
            <option key={c.id} value={c.id}>
              {c.name_ar}
            </option>
          ))}
        </Select>
        <Select className="w-auto" value={pinned} onChange={(e) => setPinned(e.target.value)}>
          <option value="">بدون تثبيت محدد</option>
          <option value="latest">المثبّتة في الأحدث</option>
          <option value="popular">المثبّتة في الأكثر شهرة</option>
        </Select>
        <Select className="w-auto" value={sort} onChange={(e) => setSort(e.target.value)}>
          <option value="newest">الأحدث إضافة</option>
          <option value="popular">الأكثر شهرة</option>
          <option value="priceAsc">السعر: من الأقل</option>
          <option value="priceDesc">السعر: من الأعلى</option>
        </Select>
      </GlassCard>

      {list.error ? <ErrorBox message={list.error} onRetry={list.reload} /> : null}
      {list.loading && !list.data ? <LoadingBox /> : null}
      {list.data && rows.length === 0 ? (
        <EmptyBox message="لا توجد هدايا مطابقة">
          <Button onClick={() => setEditor({ open: true, id: null })}>
            <Plus className="h-4 w-4" />
            أضف أول هدية
          </Button>
        </EmptyBox>
      ) : null}

      {rows.length > 0 ? (
        <>
          <DataTable
            rows={rows}
            rowKey={(p) => p.id}
            columns={[
              {
                key: "title",
                label: "الهدية",
                render: (p) => (
                  <div className="flex min-w-[220px] items-center gap-3">
                    <Thumb src={p.cover_image} className="h-12 w-12" />
                    <div className="min-w-0">
                      <div className="truncate font-semibold">{p.title_ar}</div>
                      <div className="text-[11px] text-[var(--muted-foreground)]" dir="ltr">
                        {p.sku}
                      </div>
                    </div>
                  </div>
                ),
              },
              { key: "price", label: "السعر", render: (p) => <span className="whitespace-nowrap font-semibold">{money(p.price)}</span> },
              {
                key: "category",
                label: "التصنيف / النوع",
                render: (p) => (
                  <div className="grid gap-0.5 text-xs">
                    <span>{p.category_name ?? "—"}</span>
                    <span className="text-[var(--muted-foreground)]">{tagLabel(p.gift_type_tag, tags?.labels)}</span>
                  </div>
                ),
              },
              {
                key: "stats",
                label: "مباع / مفضلة",
                render: (p) => (
                  <span className="whitespace-nowrap text-xs">
                    {p.sold} / {p.favorites}
                  </span>
                ),
              },
              {
                key: "pins",
                label: "التثبيت",
                render: (p) => (
                  <div className="flex gap-1">
                    <button
                      title="تثبيت في أحدث الهدايا"
                      onClick={() => patch(p, { is_latest: !p.is_latest }, p.is_latest ? "أُلغي التثبيت من الأحدث" : "ثُبّتت في أحدث الهدايا")}
                      className={cn(
                        "flex items-center gap-1 rounded-full border px-2 py-1 text-[11px]",
                        p.is_latest ? "border-transparent bg-[var(--primary)] text-white" : "border-[var(--border)] text-[var(--muted-foreground)]",
                      )}
                    >
                      <Pin className="h-3 w-3" /> الأحدث
                    </button>
                    <button
                      title="تثبيت في الأكثر شهرة"
                      onClick={() => patch(p, { is_popular: !p.is_popular }, p.is_popular ? "أُلغي التثبيت من الأكثر شهرة" : "ثُبّتت في الأكثر شهرة")}
                      className={cn(
                        "flex items-center gap-1 rounded-full border px-2 py-1 text-[11px]",
                        p.is_popular ? "border-transparent bg-[var(--primary)] text-white" : "border-[var(--border)] text-[var(--muted-foreground)]",
                      )}
                    >
                      <Pin className="h-3 w-3" /> الشهرة
                    </button>
                  </div>
                ),
              },
              {
                key: "status",
                label: "الحالة",
                render: (p) => (p.status === "active" ? <Badge tone="green">معروضة</Badge> : <Badge tone="gray">مخفية</Badge>),
              },
              {
                key: "actions",
                label: "",
                render: (p) => (
                  <div className="flex justify-end gap-1">
                    <Button size="icon" variant="ghost" title="تعديل" onClick={() => setEditor({ open: true, id: p.id })}>
                      <Pencil className="h-4 w-4" />
                    </Button>
                    <Button
                      size="icon"
                      variant="ghost"
                      title={p.status === "active" ? "إخفاء من التطبيق" : "إظهار في التطبيق"}
                      onClick={() =>
                        patch(p, { status: p.status === "active" ? "hidden" : "active" }, p.status === "active" ? "أُخفيت الهدية" : "أصبحت الهدية معروضة")
                      }
                    >
                      {p.status === "active" ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </Button>
                    <Button size="icon" variant="ghost" title="حذف" onClick={() => remove(p)}>
                      <Trash2 className="h-4 w-4 text-red-600" />
                    </Button>
                  </div>
                ),
              },
            ]}
          />
          <Pagination page={page} pageSize={PAGE_SIZE} total={list.data?.total ?? 0} onPage={setPage} />
        </>
      ) : null}

      <ProductEditor
        open={editor.open}
        productId={editor.id}
        onClose={closeEditor}
        onSaved={list.reload}
        categories={categories.data ?? []}
      />
    </div>
  );
}

export default function ProductsPage() {
  return (
    <Suspense fallback={<LoadingBox />}>
      <ProductsInner />
    </Suspense>
  );
}
