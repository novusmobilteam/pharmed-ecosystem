// Sözleşmedeki fingerprint kuralının panel tarafındaki kopyası — yalnızca
// sahte veri katmanı kullanır; gerçek ortamda fingerprint'i backend üretir.

import type { LogEntry } from './types';

const GUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi;
const GUID_SEGMENT = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** `/Prescription/detail/812/refundControl` → `/Prescription/detail/{id}/refundControl` */
export function normalizePath(path: string): string {
  return path
    .split('?')[0]
    .split('/')
    .map((seg) => (/^\d+$/.test(seg) || GUID_SEGMENT.test(seg) ? '{id}' : seg))
    .join('/');
}

export function normalizeMessage(message: string): string {
  return message.replace(GUID, '*').replace(/\d+/g, '#');
}

/** SHA-1 yerine kısa, deterministik bir özet — sahte veri için yeterli. */
function hash(input: string): string {
  let h1 = 0x811c9dc5;
  let h2 = 0x01000193;
  for (let i = 0; i < input.length; i++) {
    const c = input.charCodeAt(i);
    h1 = Math.imul(h1 ^ c, 16777619);
    h2 = Math.imul(h2 ^ c, 2246822519);
  }
  return ((h1 >>> 0).toString(16).padStart(8, '0') + (h2 >>> 0).toString(16).padStart(8, '0')).slice(0, 16);
}

export function fingerprintOf(e: LogEntry): string | undefined {
  if (e.level === 'INFO') return undefined;
  const parts = [
    e.level,
    e.unit,
    e.rule ?? e.errorType ?? '',
    e.http ? `${e.http.method} ${normalizePath(e.http.path)}` : '',
    !e.rule && !e.http ? normalizeMessage(e.message) : '',
  ];
  return hash(parts.join('|'));
}
