"use client";

import { useRef, useState } from "react";
import { ArrowLeft, ArrowRight, ImagePlus, Loader2, Star, Trash2 } from "lucide-react";
import { mediaUrl, uploadImage } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/toast-provider";
import { cn, errorMessage } from "@/lib/utils";

const ACCEPT = "image/jpeg,image/png,image/webp";

export function Thumb({
  src,
  className,
  alt = "",
}: {
  src: string | null | undefined;
  className?: string;
  alt?: string;
}) {
  const url = mediaUrl(src);
  const [failed, setFailed] = useState(false);
  return (
    <div
      className={cn(
        "flex shrink-0 items-center justify-center overflow-hidden rounded-xl bg-[var(--muted)] text-[var(--muted-foreground)]",
        className ?? "h-12 w-12",
      )}
    >
      {url && !failed ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={url} alt={alt} className="h-full w-full object-cover" onError={() => setFailed(true)} />
      ) : (
        <ImagePlus className="h-4 w-4 opacity-50" />
      )}
    </div>
  );
}

/** Single image: upload to the API or paste a URL. */
export function ImageUpload({
  value,
  onChange,
  aspect = "aspect-square",
}: {
  value: string | null | undefined;
  onChange: (url: string | null) => void;
  aspect?: string;
}) {
  const input = useRef<HTMLInputElement>(null);
  const [busy, setBusy] = useState(false);
  const toast = useToast();

  const pick = async (file: File | undefined) => {
    if (!file) return;
    setBusy(true);
    try {
      onChange(await uploadImage(file));
    } catch (e) {
      toast.error(errorMessage(e, "فشل رفع الصورة"));
    } finally {
      setBusy(false);
      if (input.current) input.current.value = "";
    }
  };

  return (
    <div className="grid gap-2">
      <button
        type="button"
        onClick={() => input.current?.click()}
        className={cn(
          "relative flex w-full items-center justify-center overflow-hidden rounded-2xl border-2 border-dashed border-[var(--border)] bg-[var(--muted)]/50 text-[var(--muted-foreground)] transition hover:border-[var(--accent)]",
          aspect,
        )}
      >
        {value ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={mediaUrl(value) ?? ""} alt="" className="absolute inset-0 h-full w-full object-cover" />
        ) : (
          <span className="flex flex-col items-center gap-1 text-xs">
            <ImagePlus className="h-6 w-6" />
            اضغط لرفع صورة
          </span>
        )}
        {busy ? (
          <span className="absolute inset-0 flex items-center justify-center bg-black/40 text-white">
            <Loader2 className="h-6 w-6 animate-spin" />
          </span>
        ) : null}
      </button>
      <input ref={input} type="file" accept={ACCEPT} hidden onChange={(e) => pick(e.target.files?.[0])} />
      {value ? (
        <div className="flex gap-2">
          <Button size="sm" variant="secondary" onClick={() => input.current?.click()} disabled={busy}>
            تغيير
          </Button>
          <Button size="sm" variant="ghost" onClick={() => onChange(null)} disabled={busy}>
            <Trash2 className="h-4 w-4" />
            إزالة
          </Button>
        </div>
      ) : null}
    </div>
  );
}

/** Ordered gallery — the first image is the cover shown in lists. */
export function MultiImageUpload({
  value,
  onChange,
  max = 12,
}: {
  value: string[];
  onChange: (urls: string[]) => void;
  max?: number;
}) {
  const input = useRef<HTMLInputElement>(null);
  const [busy, setBusy] = useState(false);
  const toast = useToast();

  const pick = async (files: FileList | null) => {
    if (!files?.length) return;
    setBusy(true);
    const urls = [...value];
    try {
      for (const file of Array.from(files).slice(0, max - urls.length)) {
        urls.push(await uploadImage(file));
      }
    } catch (e) {
      toast.error(errorMessage(e, "فشل رفع الصورة"));
    } finally {
      onChange(urls);
      setBusy(false);
      if (input.current) input.current.value = "";
    }
  };

  const move = (i: number, dir: -1 | 1) => {
    const j = i + dir;
    if (j < 0 || j >= value.length) return;
    const next = [...value];
    [next[i], next[j]] = [next[j], next[i]];
    onChange(next);
  };

  return (
    <div className="grid gap-2">
      <div className="grid grid-cols-3 gap-2 sm:grid-cols-4">
        {value.map((url, i) => (
          <div key={`${url}-${i}`} className="group relative aspect-square overflow-hidden rounded-2xl border border-[var(--border)]">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={mediaUrl(url) ?? ""} alt="" className="h-full w-full object-cover" />
            {i === 0 ? (
              <span className="absolute right-1.5 top-1.5 flex items-center gap-1 rounded-full bg-[var(--primary)] px-2 py-0.5 text-[10px] font-bold text-white">
                <Star className="h-3 w-3" /> الغلاف
              </span>
            ) : null}
            <div className="absolute inset-x-0 bottom-0 flex justify-between bg-black/55 p-1 opacity-100 transition sm:opacity-0 sm:group-hover:opacity-100">
              <button type="button" className="rounded-lg p-1 text-white hover:bg-white/20" onClick={() => move(i, -1)} aria-label="تقديم">
                <ArrowRight className="h-4 w-4" />
              </button>
              <button
                type="button"
                className="rounded-lg p-1 text-white hover:bg-white/20"
                onClick={() => onChange(value.filter((_, k) => k !== i))}
                aria-label="حذف"
              >
                <Trash2 className="h-4 w-4" />
              </button>
              <button type="button" className="rounded-lg p-1 text-white hover:bg-white/20" onClick={() => move(i, 1)} aria-label="تأخير">
                <ArrowLeft className="h-4 w-4" />
              </button>
            </div>
          </div>
        ))}
        {value.length < max ? (
          <button
            type="button"
            onClick={() => input.current?.click()}
            disabled={busy}
            className="flex aspect-square flex-col items-center justify-center gap-1 rounded-2xl border-2 border-dashed border-[var(--border)] text-xs text-[var(--muted-foreground)] hover:border-[var(--accent)]"
          >
            {busy ? <Loader2 className="h-5 w-5 animate-spin" /> : <ImagePlus className="h-5 w-5" />}
            إضافة صور
          </button>
        ) : null}
      </div>
      <input ref={input} type="file" accept={ACCEPT} multiple hidden onChange={(e) => pick(e.target.files)} />
      <p className="text-[11px] text-[var(--muted-foreground)]">
        الصورة الأولى هي صورة الغلاف في التطبيق. يمكن ترتيب الصور بالأسهم. (jpg / png / webp — حتى 3MB)
      </p>
    </div>
  );
}
