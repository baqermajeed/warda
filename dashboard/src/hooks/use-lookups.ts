"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import type { Lookups } from "@/lib/types";

type SpecialGiftOptions = Record<"recipients" | "occasions" | "types", { id: string; label_key: string }[]>;

export type TagOptions = {
  lookups: Lookups;
  /** id -> translation key/text, gathered from the app's filters & special-gift options. */
  labels: Record<string, string>;
};

let cache: Promise<TagOptions> | null = null;

async function load(): Promise<TagOptions> {
  const [lookups, sg] = await Promise.all([
    api<Lookups>("/lookups"),
    api<SpecialGiftOptions>("/special-gift/options").catch(() => null),
  ]);
  const labels: Record<string, string> = {};
  for (const group of [sg?.recipients, sg?.occasions, sg?.types]) {
    for (const o of group ?? []) labels[o.id] = o.label_key;
  }
  // Category-screen labels win (they are what the customer sees in filters).
  for (const f of lookups.filters ?? []) {
    for (const o of f.options) labels[o.id] = o.label;
  }
  for (const o of lookups.addon_categories ?? []) labels[o.id] ??= o.label;
  return { lookups, labels };
}

export function useLookups() {
  const [data, setData] = useState<TagOptions | null>(null);
  useEffect(() => {
    let alive = true;
    cache ??= load().catch((e) => {
      cache = null;
      throw e;
    });
    cache.then((d) => alive && setData(d)).catch(() => undefined);
    return () => {
      alive = false;
    };
  }, []);
  return data;
}
