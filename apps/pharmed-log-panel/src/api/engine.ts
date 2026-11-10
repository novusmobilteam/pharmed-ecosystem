// Bellekteki kayıtlar üzerinde sorgu ve istatistik — sahte veri katmanı ve
// gerçek backend istemcisi ortak kullanır. Backend'de gruplama/istatistik
// servisi olmadığı için sorunlar, grafikler, en çoklar ve kiosk listesi son
// 7 günün kayıtlarından panelde hesaplanır (bkz. api/http.ts).

import { normalizePath } from './fingerprint';
import type {
  Bucket,
  Facets,
  GroupQuery,
  GroupStatus,
  LogEntry,
  LogGroup,
  LogQuery,
  SlowItem,
  StatusChange,
  TopDimension,
  TopItem,
} from './types';

export const MIN = 60_000;
export const HOUR = 60 * MIN;
export const DAY = 24 * HOUR;

export function compareVersion(a = '', b = ''): number {
  const pa = a.split(/[.+]/).map(Number);
  const pb = b.split(/[.+]/).map(Number);
  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    const d = (pa[i] ?? 0) - (pb[i] ?? 0);
    if (d) return d;
  }
  return 0;
}

/**
 * Kaydın ilgili olduğu backend işlemi: başarılı yazmalarda relatedOperationId
 * ya da context.operationId; hata yanıtlarında yanıt gövdesindeki operationId.
 */
export function operationIdOf(e: LogEntry): number | undefined {
  if (e.relatedOperationId) return e.relatedOperationId;
  const c = e.context;
  if (!c) return undefined;
  if (typeof c.operationId === 'number') return c.operationId;
  const res = c.response;
  if (res && typeof res === 'object' && typeof (res as Record<string, unknown>).operationId === 'number')
    return (res as Record<string, number>).operationId;
  const m = /"?operationId"?\s*[:=]\s*(\d+)/.exec(typeof res === 'string' ? res : '');
  return m ? Number(m[1]) : undefined;
}

export function matches(e: LogEntry, q: LogQuery): boolean {
  const t = e.timestamp;
  if (t < q.from || t > q.to) return false;
  if (q.level?.length && !q.level.includes(e.level)) return false;
  if (q.stationId?.length && !q.stationId.includes(e.session?.stationId ?? -1)) return false;
  if (q.deviceId?.length && !q.deviceId.includes(e.deviceId)) return false;
  if (q.userId?.length && !q.userId.includes(e.session?.userId ?? -1)) return false;
  if (q.unit?.length && !q.unit.includes(e.unit)) return false;
  if (q.rule?.length && !q.rule.includes(e.rule ?? '')) return false;
  if (q.fingerprint && e.fingerprint !== q.fingerprint) return false;
  if (q.appRunId && e.appRunId !== q.appRunId) return false;
  if (q.req && e.req !== q.req) return false;
  if (q.appVersion && e.appVersion !== q.appVersion) return false;
  if (q.httpStatus && e.http?.status !== q.httpStatus) return false;
  if (q.operationId && operationIdOf(e) !== q.operationId) return false;
  if (q.httpPath) {
    const p = e.http?.path;
    if (!p || !(p.includes(q.httpPath) || normalizePath(p).includes(q.httpPath))) return false;
  }
  if (q.search) {
    const s = q.search.toLocaleLowerCase('tr');
    const hay = `${e.message} ${e.error ?? ''} ${e.rule ?? ''} ${JSON.stringify(e.context ?? {})}`.toLocaleLowerCase('tr');
    if (!hay.includes(s)) return false;
  }
  return true;
}

export function intervalMs(interval: string): number {
  const m = /^(\d+)([mhd])$/.exec(interval);
  if (!m) return HOUR;
  const n = Number(m[1]);
  return n * (m[2] === 'm' ? MIN : m[2] === 'h' ? HOUR : DAY);
}

export function bucketize(entries: LogEntry[], from: string, to: string, interval: string): Bucket[] {
  const step = intervalMs(interval);
  const start = Math.floor(Date.parse(from) / step) * step;
  const end = Date.parse(to);
  const buckets: Bucket[] = [];
  for (let t = start; t <= end; t += step) {
    buckets.push({ t: new Date(t).toISOString(), counts: { INFO: 0, WARN: 0, ERROR: 0 } });
  }
  for (const e of entries) {
    const i = Math.floor((Date.parse(e.timestamp) - start) / step);
    if (i >= 0 && i < buckets.length) buckets[i].counts[e.level] += 1;
  }
  return buckets;
}

// ── Sorun durumları ──────────────────────────────────────────────────────

export interface StoredStatus {
  status: GroupStatus;
  note?: string;
  resolvedInVersion?: string;
  statusChangedAt: string;
  statusChangedBy: string;
}

/**
 * Sorun grubu durumları (açık / çözüldü / yok sayıldı). Backend'de karşılığı
 * olana kadar tarayıcıda saklanır — yalnızca bu tarayıcıda görünür.
 */
export class StatusStore {
  private map: Record<string, StoredStatus>;

  constructor(private readonly key: string) {
    this.map = this.load();
  }

  private load(): Record<string, StoredStatus> {
    try {
      return JSON.parse(localStorage.getItem(this.key) ?? '{}');
    } catch {
      return {};
    }
  }

  private save() {
    try {
      localStorage.setItem(this.key, JSON.stringify(this.map));
    } catch {
      // önizleme ortamında depolama olmayabilir
    }
  }

  get isEmpty() {
    return Object.keys(this.map).length === 0;
  }

  get(fingerprint: string): StoredStatus | undefined {
    return this.map[fingerprint];
  }

  set(fingerprint: string, change: StatusChange, by: string, at = new Date().toISOString()) {
    this.map[fingerprint] = { ...change, statusChangedAt: at, statusChangedBy: by };
    this.save();
  }

  /** Çözüldü işaretli bir hata (çözüldüğü sürümde ya da sonrasında) tekrar gelirse açılır. */
  reopenRegressions(fresh: LogEntry[]) {
    let changed = false;
    for (const e of fresh) {
      const s = e.fingerprint ? this.map[e.fingerprint] : undefined;
      if (s?.status !== 'resolved') continue;
      if (s.resolvedInVersion && compareVersion(e.appVersion, s.resolvedInVersion) < 0) continue;
      this.map[e.fingerprint!] = { ...s, status: 'open' };
      changed = true;
    }
    if (changed) this.save();
  }
}

// ── Hesaplamalar ─────────────────────────────────────────────────────────

/** Listelerde id yerine gösterilecek adlar. */
export interface Labels {
  station: (id: string) => string | undefined;
  device: (id: string) => string | undefined;
  user: (id: string) => string | undefined;
}

/**
 * [all]: elimizdeki tüm kayıtlar (en yeni başta); [rangeEntries]: seçili
 * aralıktakiler. Sayılar aralıktan, ilk/son görülme tümünden hesaplanır.
 */
export function buildGroup(fingerprint: string, all: LogEntry[], rangeEntries: LogEntry[], stored?: StoredStatus): LogGroup {
  const mine = all.filter((e) => e.fingerprint === fingerprint);
  const first = mine[mine.length - 1];
  const last = mine[0];
  let status: GroupStatus = stored?.status ?? 'open';
  let regressed = false;
  if (stored?.status === 'resolved') {
    const after = mine.filter(
      (e) =>
        e.timestamp > stored.statusChangedAt &&
        (!stored.resolvedInVersion || compareVersion(e.appVersion, stored.resolvedInVersion) >= 0),
    );
    if (after.length) {
      status = 'open';
      regressed = true;
    }
  }
  const inRange = rangeEntries.filter((e) => e.fingerprint === fingerprint);
  const uniq = <T,>(xs: T[]) => new Set(xs).size;
  return {
    fingerprint,
    title: first.message,
    level: first.level,
    unit: first.unit,
    rule: first.rule,
    errorType: first.errorType,
    httpMethod: first.http?.method,
    httpPath: first.http ? normalizePath(first.http.path) : undefined,
    status,
    count: inRange.length,
    totalCount: mine.length,
    deviceCount: uniq(inRange.map((e) => e.deviceId)),
    userCount: uniq(inRange.map((e) => e.session?.userId).filter(Boolean)),
    stationCount: uniq(inRange.map((e) => e.session?.stationId).filter(Boolean)),
    firstSeen: first.timestamp,
    lastSeen: last.timestamp,
    firstSeenVersion: first.appVersion,
    lastSeenVersion: last.appVersion,
    sampleEntryId: last.id,
    note: stored?.note,
    statusChangedBy: stored?.statusChangedBy,
    statusChangedAt: stored?.statusChangedAt,
    resolvedInVersion: stored?.resolvedInVersion,
    regressed,
  };
}

export function listGroupsOf(all: LogEntry[], q: GroupQuery, statuses: StatusStore): LogGroup[] {
  const inRange = all.filter(
    (e) => e.fingerprint && e.timestamp >= q.from && e.timestamp <= q.to && (!q.level?.length || q.level.includes(e.level)),
  );
  const fps = [...new Set(inRange.map((e) => e.fingerprint!))];
  let groups = fps.map((fp) => buildGroup(fp, all, inRange, statuses.get(fp)));
  if (q.status) groups = groups.filter((g) => g.status === q.status);
  if (q.search) {
    const s = q.search.toLocaleLowerCase('tr');
    groups = groups.filter((g) =>
      `${g.title} ${g.rule ?? ''} ${g.httpPath ?? ''} ${g.errorType ?? ''}`.toLocaleLowerCase('tr').includes(s),
    );
  }
  const sort = q.sort ?? 'lastSeen';
  groups.sort((a, b) =>
    sort === 'count'
      ? b.count - a.count
      : sort === 'users'
        ? b.userCount - a.userCount || b.count - a.count
        : sort === 'firstSeen'
          ? b.firstSeen.localeCompare(a.firstSeen)
          : b.lastSeen.localeCompare(a.lastSeen),
  );
  return groups;
}

function countBy(entries: LogEntry[], key: (e: LogEntry) => string | undefined, label?: (k: string) => string | undefined): TopItem[] {
  const m = new Map<string, number>();
  for (const e of entries) {
    const k = key(e);
    if (k) m.set(k, (m.get(k) ?? 0) + 1);
  }
  return [...m.entries()]
    .map(([k, n]) => ({ key: k, label: label?.(k) ?? k, count: n }))
    .sort((a, b) => b.count - a.count);
}

export function facetsOf(all: LogEntry[], from: string, to: string, labels: Labels): Facets {
  const inRange = all.filter((e) => e.timestamp >= from && e.timestamp <= to);
  return {
    units: countBy(inRange, (e) => e.unit),
    rules: countBy(inRange, (e) => e.rule),
    stations: countBy(inRange, (e) => (e.session?.stationId ? String(e.session.stationId) : undefined), labels.station),
    devices: countBy(inRange, (e) => e.deviceId, labels.device),
    users: countBy(inRange, (e) => (e.session?.userId ? String(e.session.userId) : undefined), labels.user),
    versions: countBy(inRange, (e) => e.appVersion),
  };
}

export function topOf(all: LogEntry[], q: LogQuery, dimension: TopDimension, limit: number, labels: Labels): TopItem[] {
  const key = (e: LogEntry): string | undefined => {
    switch (dimension) {
      case 'rule':
        return e.rule;
      case 'httpPath':
        return e.http ? `${e.http.method} ${normalizePath(e.http.path)}` : undefined;
      case 'station':
        return e.session?.stationId ? String(e.session.stationId) : undefined;
      case 'device':
        return e.deviceId;
      case 'user':
        return e.session?.userId ? String(e.session.userId) : undefined;
      case 'unit':
        return e.unit;
    }
  };
  const label = (k: string) =>
    dimension === 'station' ? labels.station(k) : dimension === 'device' ? labels.device(k) : dimension === 'user' ? labels.user(k) : undefined;
  return countBy(
    all.filter((e) => matches(e, q)),
    key,
    label,
  ).slice(0, limit);
}

export function slowOf(all: LogEntry[], from: string, to: string, limit: number): SlowItem[] {
  const m = new Map<string, number[]>();
  for (const e of all) {
    if (e.timestamp < from || e.timestamp > to || !e.http?.ms || !e.http.status) continue;
    const k = `${e.http.method} ${normalizePath(e.http.path)}`;
    m.set(k, [...(m.get(k) ?? []), e.http.ms]);
  }
  const items = [...m.entries()].map(([k, ms]) => {
    const sorted = [...ms].sort((a, b) => a - b);
    const [method, ...rest] = k.split(' ');
    return {
      method,
      path: rest.join(' '),
      count: ms.length,
      avgMs: Math.round(ms.reduce((s, x) => s + x, 0) / ms.length),
      p95Ms: sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * 0.95))],
      maxMs: sorted[sorted.length - 1],
    };
  });
  return items.sort((a, b) => b.p95Ms - a.p95Ms).slice(0, limit);
}

export function exportFile(rows: LogEntry[], format: 'ndjson' | 'csv') {
  let text: string;
  if (format === 'ndjson') {
    text = rows.map((r) => JSON.stringify(r)).join('\n');
  } else {
    const cols = ['timestamp', 'level', 'unit', 'message', 'rule', 'req', 'httpMethod', 'httpPath', 'httpStatus', 'deviceId', 'userId', 'stationId', 'screen'];
    const esc = (v: unknown) => {
      const s = v === undefined || v === null ? '' : String(v);
      return /[",\n;]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
    };
    text = [
      cols.join(','),
      ...rows.map((r) =>
        [
          r.timestamp,
          r.level,
          r.unit,
          r.message,
          r.rule,
          r.req,
          r.http?.method,
          r.http?.path,
          r.http?.status,
          r.deviceId,
          r.session?.userId,
          r.session?.stationId,
          r.session?.screen,
        ]
          .map(esc)
          .join(','),
      ),
    ].join('\n');
  }
  const blob = new Blob([text], { type: format === 'csv' ? 'text/csv' : 'application/x-ndjson' });
  return { url: URL.createObjectURL(blob), filename: `pharmed-logs.${format}` };
}
