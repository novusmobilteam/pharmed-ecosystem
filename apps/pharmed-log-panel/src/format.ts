// Tarih, süre ve zaman aralığı yardımcıları.

export const RANGES = [
  { key: '15m', label: 'Son 15 dk', ms: 15 * 60_000, interval: '1m' },
  { key: '1h', label: 'Son 1 saat', ms: 60 * 60_000, interval: '5m' },
  { key: '6h', label: 'Son 6 saat', ms: 6 * 60 * 60_000, interval: '15m' },
  { key: '24h', label: 'Son 24 saat', ms: 24 * 60 * 60_000, interval: '1h' },
  { key: '7d', label: 'Son 7 gün', ms: 7 * 24 * 60 * 60_000, interval: '6h' },
] as const;

export type RangeKey = (typeof RANGES)[number]['key'];

export function rangeOf(key: string | null | undefined) {
  return RANGES.find((r) => r.key === key) ?? RANGES[3];
}

export function rangeBounds(key: string | null | undefined, now = Date.now()) {
  const r = rangeOf(key);
  return { from: new Date(now - r.ms).toISOString(), to: new Date(now).toISOString(), interval: r.interval };
}

const dtf = new Intl.DateTimeFormat('tr-TR', {
  day: '2-digit',
  month: 'short',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
});
const tf = new Intl.DateTimeFormat('tr-TR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
const df = new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });

export const fmtDateTime = (iso?: string) => (iso ? dtf.format(new Date(iso)) : '—');
export const fmtTime = (iso?: string) => (iso ? tf.format(new Date(iso)) : '—');
export const fmtShort = (iso?: string) => (iso ? df.format(new Date(iso)) : '—');

export function fmtMillis(iso?: string) {
  if (!iso) return '';
  return String(new Date(iso).getMilliseconds()).padStart(3, '0');
}

export function fmtAgo(iso?: string, now = Date.now()) {
  if (!iso) return '—';
  const s = Math.max(0, Math.round((now - Date.parse(iso)) / 1000));
  if (s < 60) return `${s} sn önce`;
  const m = Math.round(s / 60);
  if (m < 60) return `${m} dk önce`;
  const h = Math.round(m / 60);
  if (h < 48) return `${h} sa önce`;
  return `${Math.round(h / 24)} gün önce`;
}

export function fmtMs(ms?: number) {
  if (ms === undefined) return '—';
  return ms >= 1000 ? `${(ms / 1000).toFixed(ms >= 10_000 ? 0 : 1)} sn` : `${ms} ms`;
}

export const fmtCount = (n: number) => new Intl.NumberFormat('tr-TR').format(n);

/** `System.ArgumentException` → `ArgumentException` */
export const shortType = (t: string) => t.split('.').pop() ?? t;
