"use client";

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { adminLogin, adminLogout, api, getSession, setSession, type AdminSession } from "@/lib/api";

type AuthCtx = {
  user: AdminSession["user"] | null;
  ready: boolean;
  login: (phone: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
};

const Ctx = createContext<AuthCtx | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AdminSession["user"] | null>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const session = getSession();
      if (!session) {
        setReady(true);
        return;
      }
      try {
        // Confirms the token is still valid and the account is still an admin.
        const me = await api<{ id: number; name: string; phone: string }>("/admin/me");
        const next = { ...session, user: { id: me.id, name: me.name, phone: me.phone } };
        setSession(next);
        if (!cancelled) setUser(next.user);
      } catch {
        setSession(null);
        if (!cancelled) setUser(null);
      } finally {
        if (!cancelled) setReady(true);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const login = useCallback(async (phone: string, password: string) => {
    const session = await adminLogin(phone, password);
    setUser(session.user);
  }, []);

  const logout = useCallback(async () => {
    await adminLogout();
    setUser(null);
  }, []);

  const value = useMemo(() => ({ user, ready, login, logout }), [user, ready, login, logout]);
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAuth() {
  const v = useContext(Ctx);
  if (!v) throw new Error("useAuth outside AuthProvider");
  return v;
}
