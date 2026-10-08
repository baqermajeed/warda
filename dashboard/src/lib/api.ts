/** Warda admin API client — FastAPI backend, JWT access + refresh tokens. */

export const API_BASE = (
  process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000"
).replace(/\/$/, "");

const SESSION_KEY = "warda.dash.session";

export type AdminSession = {
  accessToken: string;
  refreshToken: string;
  user: { id: number; name: string; phone: string };
};

export class ApiError extends Error {
  status: number;
  code?: string;
  constructor(status: number, message: string, code?: string) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

/** Arabic messages for the backend error codes the dashboard can hit. */
const CODE_MESSAGES: Record<string, string> = {
  INVALID_CREDENTIALS: "رقم الهاتف أو كلمة المرور غير صحيحة",
  FORBIDDEN: "هذا الحساب ليس حساب إدارة",
  LOGIN_RATE_LIMIT: "محاولات كثيرة، انتظر دقيقة ثم حاول مجددًا",
  DUPLICATE: "القيمة مستخدمة مسبقًا (المعرّف/الكود/SKU يجب أن يكون فريدًا)",
  NOT_FOUND: "العنصر غير موجود (ربما حُذف)",
  INVALID_CATEGORY: "التصنيف المختار غير موجود",
  INVALID_PHONE: "رقم الهاتف غير صالح — الصيغة 07XXXXXXXXX",
  USER_NOT_FOUND: "لا يوجد مستخدم بهذا الرقم",
  SELF_LOCKOUT: "لا يمكنك إزالة صلاحية الإدارة عن حسابك",
  NO_ACCOUNT: "هذه الرسالة أُرسلت بدون حساب — تواصل مع الزبون عبر الهاتف",
  FILE_TOO_LARGE: "حجم الصورة كبير (الحد 3 ميغابايت)",
  INVALID_FILE: "نوع الملف غير مدعوم (jpg, png, webp فقط)",
  INVALID_SETTING: "قيمة غير صالحة — أدخل رقمًا صحيحًا",
  UNKNOWN_SETTING: "إعداد غير معروف",
  VALIDATION_ERROR: "بيانات غير صالحة — راجع الحقول المطلوبة",
  NETWORK_ERROR: "تعذر الاتصال بالخادم — تأكد أن الـ backend يعمل",
};

export function getSession(): AdminSession | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = localStorage.getItem(SESSION_KEY);
    return raw ? (JSON.parse(raw) as AdminSession) : null;
  } catch {
    return null;
  }
}

export function setSession(session: AdminSession | null) {
  if (typeof window === "undefined") return;
  try {
    if (session) localStorage.setItem(SESSION_KEY, JSON.stringify(session));
    else localStorage.removeItem(SESSION_KEY);
  } catch {
    // storage unavailable (private mode) — session lives in memory only
  }
}

/** Absolute URL for an image path returned by the API (`/api/v1/media/..`). */
export function mediaUrl(path: string | null | undefined): string | null {
  if (!path) return null;
  if (/^(https?:|data:|blob:)/i.test(path)) return path;
  return `${API_BASE}${path.startsWith("/") ? path : `/${path}`}`;
}

type Query = Record<string, string | number | boolean | null | undefined>;

function buildUrl(path: string, query?: Query) {
  const url = new URL(`${API_BASE}/api/v1${path}`);
  if (query) {
    for (const [k, v] of Object.entries(query)) {
      if (v !== undefined && v !== null && v !== "") url.searchParams.set(k, String(v));
    }
  }
  return url.toString();
}

async function parseError(res: Response): Promise<ApiError> {
  const body = (await res.json().catch(() => null)) as { detail?: string; code?: string } | null;
  const code = body?.code;
  const message =
    (code && CODE_MESSAGES[code]) || body?.detail || `خطأ من الخادم (${res.status})`;
  return new ApiError(res.status, message, code);
}

let refreshing: Promise<boolean> | null = null;

async function refreshTokens(): Promise<boolean> {
  const session = getSession();
  if (!session?.refreshToken) return false;
  if (!refreshing) {
    refreshing = (async () => {
      try {
        const res = await fetch(buildUrl("/auth/refresh"), {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ refresh_token: session.refreshToken }),
        });
        if (!res.ok) return false;
        const data = await res.json();
        setSession({
          ...session,
          accessToken: data.access_token,
          refreshToken: data.refresh_token,
        });
        return true;
      } catch {
        return false;
      } finally {
        setTimeout(() => (refreshing = null), 0);
      }
    })();
  }
  return refreshing;
}

function expireSession() {
  setSession(null);
  if (typeof window !== "undefined" && !window.location.pathname.startsWith("/login")) {
    window.location.href = "/login";
  }
}

export async function api<T = unknown>(
  path: string,
  init: RequestInit & { query?: Query; json?: unknown } = {},
  retry = true,
): Promise<T> {
  const { query, json, ...rest } = init;
  const headers = new Headers(rest.headers);
  if (json !== undefined) headers.set("Content-Type", "application/json");
  const token = getSession()?.accessToken;
  if (token) headers.set("Authorization", `Bearer ${token}`);

  let res: Response;
  try {
    res = await fetch(buildUrl(path, query), {
      ...rest,
      headers,
      body: json !== undefined ? JSON.stringify(json) : rest.body,
      cache: "no-store",
    });
  } catch {
    throw new ApiError(0, CODE_MESSAGES.NETWORK_ERROR, "NETWORK_ERROR");
  }

  if (res.status === 401 && retry && token) {
    if (await refreshTokens()) return api<T>(path, init, false);
    expireSession();
  }
  if (!res.ok) throw await parseError(res);
  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

export async function adminLogin(phone: string, password: string): Promise<AdminSession> {
  let res: Response;
  try {
    res = await fetch(buildUrl("/admin/login"), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ phone, password }),
    });
  } catch {
    throw new ApiError(0, CODE_MESSAGES.NETWORK_ERROR, "NETWORK_ERROR");
  }
  if (!res.ok) throw await parseError(res);
  const data = await res.json();
  const session: AdminSession = {
    accessToken: data.access_token,
    refreshToken: data.refresh_token,
    user: { id: data.user.id, name: data.user.name, phone: data.user.phone },
  };
  setSession(session);
  return session;
}

export async function adminLogout() {
  const session = getSession();
  if (session) {
    await api("/auth/logout", {
      method: "POST",
      json: { refresh_token: session.refreshToken },
    }).catch(() => undefined);
  }
  setSession(null);
}

export async function uploadImage(file: File): Promise<string> {
  const form = new FormData();
  form.append("file", file);
  const data = await api<{ url: string }>("/uploads/image", { method: "POST", body: form });
  return data.url;
}
