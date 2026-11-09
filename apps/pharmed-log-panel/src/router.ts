// Basit hash yönlendirici: #/logs?level=ERROR&range=24h
// Filtreler URL'de durur — bağlantı paylaşılınca aynı görünüm açılır.

import { useEffect, useState } from 'react';

export interface Route {
  path: string;
  params: URLSearchParams;
}

function parse(): Route {
  const raw = window.location.hash.replace(/^#/, '') || '/';
  const [path, query = ''] = raw.split('?');
  return { path: path || '/', params: new URLSearchParams(query) };
}

export function href(path: string, params?: Record<string, string | number | undefined | null | string[]>) {
  const sp = new URLSearchParams();
  for (const [k, v] of Object.entries(params ?? {})) {
    if (v === undefined || v === null || v === '') continue;
    if (Array.isArray(v)) {
      if (v.length) sp.set(k, v.join(','));
    } else sp.set(k, String(v));
  }
  const q = sp.toString();
  return `#${path}${q ? `?${q}` : ''}`;
}

export function navigate(path: string, params?: Parameters<typeof href>[1], replace = false) {
  const next = href(path, params);
  if (replace) window.history.replaceState(null, '', next);
  else window.location.hash = next;
  if (replace) window.dispatchEvent(new HashChangeEvent('hashchange'));
}

/** Mevcut parametreleri koruyarak bazılarını değiştirir. */
export function updateParams(route: Route, patch: Record<string, string | undefined | null | string[]>) {
  const merged: Record<string, string | string[] | undefined | null> = Object.fromEntries(route.params.entries());
  for (const [k, v] of Object.entries(patch)) merged[k] = v;
  navigate(route.path, merged, true);
}

export function useRoute(): Route {
  const [route, setRoute] = useState(parse);
  useEffect(() => {
    const onChange = () => setRoute(parse());
    window.addEventListener('hashchange', onChange);
    return () => window.removeEventListener('hashchange', onChange);
  }, []);
  return route;
}

export const list = (params: URLSearchParams, key: string) => (params.get(key) ?? '').split(',').filter(Boolean);
