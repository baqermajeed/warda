"use client";

import { Plus, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

/** Editable list of short texts (e.g. care steps). */
export function ListEditor({
  value,
  onChange,
  placeholder,
  addLabel = "إضافة",
}: {
  value: string[];
  onChange: (v: string[]) => void;
  placeholder?: string;
  addLabel?: string;
}) {
  return (
    <div className="grid gap-2">
      {value.map((item, i) => (
        <div key={i} className="flex items-center gap-2">
          <span className="w-5 text-center text-xs text-[var(--muted-foreground)]">{i + 1}</span>
          <Input
            value={item}
            placeholder={placeholder}
            onChange={(e) => onChange(value.map((v, k) => (k === i ? e.target.value : v)))}
          />
          <Button size="icon" variant="ghost" onClick={() => onChange(value.filter((_, k) => k !== i))} aria-label="حذف">
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      ))}
      <Button size="sm" variant="secondary" className="justify-self-start" onClick={() => onChange([...value, ""])}>
        <Plus className="h-4 w-4" />
        {addLabel}
      </Button>
    </div>
  );
}
