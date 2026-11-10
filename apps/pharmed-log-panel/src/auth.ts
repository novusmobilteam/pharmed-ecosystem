// Panel oturumu: /api/Login/login ile alınan Bearer token tarayıcıda saklanır.
// Log servisleri "aktif yönetici" ister — yönetici olmayan hesapla giriş
// yapılınca panel açılmaz. Token süresi dolunca ya da backend 401 dönünce
// oturum kapanır ve giriş ekranı gelir.

import { useSyncExternalStore } from 'react';

const KEY = 'pharmed-log-panel:token';

export interface Session {
  token: string;
  userId?: number;
  email?: string;
  isAdmin: boolean;
  /** ms */
  expiresAt?: number;
}

function decode(token: string): Session | null {
  try {
    const part = token.split('.')[1];
    const json = JSON.parse(decodeURIComponent(escape(atob(part.replace(/-/g, '+').replace(/_/g, '/')))));
    return {
      token,
      userId: json.nameid ? Number(json.nameid) : undefined,
      email: json.email,
      isAdmin: String(json.IsAdmin).toLowerCase() === 'true',
      expiresAt: typeof json.exp === 'number' ? json.exp * 1000 : undefined,
    };
  } catch {
    return null;
  }
}

const listeners = new Set<() => void>();
let current: Session | null = read();

function read(): Session | null {
  try {
    const t = localStorage.getItem(KEY);
    const s = t ? decode(t) : null;
    return s && (!s.expiresAt || s.expiresAt > Date.now()) ? s : null;
  } catch {
    return null;
  }
}

function emit(next: Session | null) {
  current = next;
  try {
    if (next) localStorage.setItem(KEY, next.token);
    else localStorage.removeItem(KEY);
  } catch {
    // depolama yoksa oturum yalnızca bu sekmede yaşar
  }
  listeners.forEach((l) => l());
}

export function getToken(): string | null {
  if (current?.expiresAt && current.expiresAt <= Date.now()) emit(null);
  return current?.token ?? null;
}

export function logout() {
  emit(null);
}

export function useSession(): Session | null {
  return useSyncExternalStore(
    (l) => {
      listeners.add(l);
      return () => listeners.delete(l);
    },
    () => current,
  );
}

/** Backend'in hata metninden `PN-E0475 : ` gibi kod önekini atar. */
export function cleanError(message: string): string {
  return message.replace(/^[A-Z]{2}-[A-Z]\d+\s*:\s*/, '');
}

export async function login(baseUrl: string, email: string, password: string): Promise<Session> {
  let res: Response;
  try {
    res = await fetch(`${baseUrl.replace(/\/$/, '')}/api/Login/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
  } catch {
    throw new Error('Sunucuya ulaşılamadı. Bağlantıyı kontrol edin.');
  }
  let body: { isSuccess?: boolean; data?: unknown; error?: string; message?: string } = {};
  try {
    body = await res.json();
  } catch {
    // gövde yok
  }
  if (!res.ok || body.isSuccess === false || typeof body.data !== 'string') {
    if (res.status === 401) throw new Error('Kullanıcı adı ya da şifre hatalı.');
    throw new Error(cleanError(body.error ?? body.message ?? `Giriş yapılamadı (${res.status}).`));
  }
  const session = decode(body.data);
  if (!session) throw new Error('Sunucu geçersiz bir oturum bilgisi döndü.');
  if (!session.isAdmin) throw new Error('Log paneli yalnızca yönetici hesaplarıyla açılabilir.');
  emit(session);
  return session;
}
