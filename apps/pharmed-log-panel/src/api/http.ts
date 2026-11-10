// Gerçek backend istemcisi.
//
// Backend'de olanlar:
//   GET /api/FrontendLog        filtreli, sayfalı liste (DevExtreme parametreleri)
//   GET /api/FrontendLog/{id}   kayıt ayrıntısı (context, session, breadcrumbs, stack)
//   GET /api/BackendLog         sunucuda yakalanmamış hatalar
//   GET /api/BackendLog/{id}    hata ayrıntısı, maskelenmiş parametreler
//   GET /api/User, /api/Station kullanıcı ve istasyon adları
//
// Gruplama ve istatistik servisi henüz yok: sorunlar, grafikler, en çoklar ve
// kiosk listesi son 7 günün kayıtları çekilip panelde hesaplanır (engine.ts).
// Bu pencere ilk açılışta bir kez yüklenir, sonra yalnızca yeni kayıtlar
// (id > son id) eklenir. Liste kayıtlarında context/session/breadcrumbs
// gelmediği için bu hesaplarda kullanıcı ve istasyon, backend'in token'dan
// aldığı değerlerdir.

import { cleanError, getToken, logout } from '../auth';
import { bucketize, buildGroup, DAY, exportFile, facetsOf, listGroupsOf, matches, slowOf, StatusStore, topOf, type Labels } from './engine';
import { fingerprintOf } from './fingerprint';
import type {
  Bucket,
  Capabilities,
  Device,
  Facets,
  GroupQuery,
  Level,
  LogApi,
  LogEntry,
  LogGroup,
  LogQuery,
  LogSession,
  Page,
  ServerError,
  ServerErrorQuery,
  SlowItem,
  StatusChange,
  TopDimension,
  TopItem,
} from './types';

// ── Backend şekilleri ────────────────────────────────────────────────────

interface Envelope<T> {
  statusCode?: number;
  isSuccess?: boolean;
  data?: T;
  error?: string;
  message?: string;
  totalCount?: number;
}

interface RawFrontendLog {
  id: number;
  operationId?: number | null;
  relatedOperationId?: number | null;
  clientEntryId?: string;
  deviceId: string;
  ipAddress?: string | null;
  appRunId: string;
  timestampUtc: string;
  receivedAtUtc?: string;
  application?: string;
  hostName?: string | null;
  appVersion?: string | null;
  flavor?: string | null;
  os?: string | null;
  level: string;
  unit: string;
  swreq: string;
  message: string;
  screen?: string | null;
  rule?: string | null;
  req?: string | null;
  errorType?: string | null;
  httpMethod?: string | null;
  httpPath?: string | null;
  httpStatusCode?: number | null;
  httpDurationMs?: number | null;
  correlationId?: string | null;
  userId?: number | null;
  stationId?: number | null;
  // yalnızca ayrıntıda
  error?: string | null;
  stackTrace?: string | null;
  context?: Record<string, unknown> | null;
  session?: LogSession | null;
  breadcrumbs?: string[] | null;
}

interface RawBackendLog {
  id: number;
  operationId?: number | null;
  occurredAtUtc: string;
  service: string;
  action: string;
  requestPath: string;
  httpMethod: string;
  exceptionType: string;
  exceptionMessage: string;
  userId?: number | null;
  stationId?: number | null;
  exceptionDetails?: string | null;
  parametersJson?: string | null;
  userJson?: string | null;
  stationJson?: string | null;
}

const opt = <T,>(v: T | null | undefined): T | undefined => (v === null ? undefined : v);
const iso = (v?: string | null) => (v ? new Date(v).toISOString() : undefined);
const LEVELS: Level[] = ['INFO', 'WARN', 'ERROR'];

function parseJson(s?: string | null): unknown {
  if (!s) return undefined;
  try {
    return JSON.parse(s);
  } catch {
    return s;
  }
}

function toServerError(r: RawBackendLog): ServerError {
  return {
    id: r.id,
    operationId: opt(r.operationId),
    occurredAt: iso(r.occurredAtUtc)!,
    service: r.service,
    action: r.action,
    requestPath: r.requestPath,
    httpMethod: r.httpMethod,
    exceptionType: r.exceptionType,
    exceptionMessage: r.exceptionMessage,
    userId: opt(r.userId),
    stationId: opt(r.stationId),
    exceptionDetails: opt(r.exceptionDetails),
    parameters: parseJson(r.parametersJson),
    user: parseJson(r.userJson),
    station: parseJson(r.stationJson),
  };
}

// ── DevExtreme filtre/sıralama ───────────────────────────────────────────

type Cond = [string, string, unknown];
type Clause = Cond | unknown[];

function anyOf(field: string, values: (string | number)[]): Clause | undefined {
  if (!values.length) return undefined;
  if (values.length === 1) return [field, '=', values[0]];
  // Backend 'in' operatörünü desteklemiyor.
  return values.flatMap((v, i) => (i ? ['or', [field, '=', v]] : [[field, '=', v]]));
}

function combine(clauses: (Clause | undefined)[]): string | undefined {
  const cs = clauses.filter((c): c is Clause => !!c);
  if (!cs.length) return undefined;
  if (cs.length === 1) return JSON.stringify(cs[0]);
  return JSON.stringify(cs.flatMap((c, i) => (i ? ['and', c] : [c])));
}

const sortBy = (...fields: [string, boolean][]) => JSON.stringify(fields.map(([selector, desc]) => ({ selector, desc })));

type Params = Record<string, string | number | undefined | null>;

function toSearch(params: Params): string {
  const sp = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v === undefined || v === null || v === '') continue;
    sp.set(k, String(v));
  }
  const s = sp.toString();
  return s ? `?${s}` : '';
}

/** Panel sorgusunu backend parametrelerine çevirir. */
function logParams(q: LogQuery): Params {
  const one = <T,>(xs?: T[]) => (xs?.length === 1 ? xs[0] : undefined);
  const many = <T extends string | number>(field: string, xs?: T[]) => (xs && xs.length > 1 ? anyOf(field, xs) : undefined);
  return {
    From: q.from,
    To: q.to,
    Level: one(q.level),
    DeviceId: one(q.deviceId),
    UserId: one(q.userId),
    StationId: one(q.stationId),
    Unit: one(q.unit),
    Rule: one(q.rule),
    AppRunId: q.appRunId,
    Req: q.req,
    Search: q.search,
    Filter: combine([
      many('level', q.level),
      many('deviceId', q.deviceId),
      many('userId', q.userId),
      many('stationId', q.stationId),
      many('unit', q.unit),
      many('rule', q.rule),
      q.httpPath ? ['httpPath', 'contains', q.httpPath] : undefined,
      q.httpStatus ? ['httpStatusCode', '=', q.httpStatus] : undefined,
      q.appVersion ? ['appVersion', '=', q.appVersion] : undefined,
    ]),
  };
}

// ── İstemci ──────────────────────────────────────────────────────────────

const WINDOW_MS = 7 * DAY;
const WINDOW_CAP = 30_000;
const PAGE = 1000;
const REFRESH_MS = 30_000;

interface Window {
  entries: LogEntry[];
  maxId: number;
  loadedAt: number;
  truncated: boolean;
}

export class HttpLogApi implements LogApi {
  readonly isMock = false;
  readonly capabilities: Capabilities = { heartbeat: false, sharedGroupStatus: false };
  private readonly base: string;
  private statuses = new StatusStore('pharmed-log-panel:group-status');
  private win: Window | null = null;
  private winLoading: Promise<Window> | null = null;
  private names: Promise<{ users: Map<number, string>; stations: Map<number, string> }> | null = null;
  private deviceNames = new Map<string, string>();

  constructor(baseUrl: string) {
    this.base = baseUrl.replace(/\/$/, '');
  }

  private async request<T>(path: string): Promise<Envelope<T>> {
    const token = getToken();
    let res: Response;
    try {
      res = await fetch(`${this.base}/api${path}`, { headers: token ? { Authorization: `Bearer ${token}` } : {} });
    } catch {
      throw new Error('Sunucuya ulaşılamadı.');
    }
    if (res.status === 401) {
      logout();
      throw new Error('Oturum süresi doldu, tekrar giriş yapın.');
    }
    let body: Envelope<T> = {};
    try {
      body = await res.json();
    } catch {
      // gövde yok
    }
    if (res.status === 403) throw new Error('Bu hesabın log kayıtlarını görme yetkisi yok.');
    if (!res.ok || body.isSuccess === false) {
      const detail = cleanError(body.error ?? body.message ?? '');
      throw new Error(`${res.status}${detail ? ` — ${detail}` : ''}`);
    }
    return body;
  }

  // ── Adlar ──

  private loadNames() {
    this.names ??= (async () => {
      const users = new Map<number, string>();
      const stations = new Map<number, string>();
      const [u, s] = await Promise.allSettled([
        this.request<{ id: number; nameSurname?: string; name?: string; surname?: string }[]>('/User?Take=5000'),
        this.request<{ id: number; name: string }[]>('/Station?Take=5000'),
      ]);
      if (u.status === 'fulfilled')
        for (const x of u.value.data ?? []) users.set(x.id, x.nameSurname ?? [x.name, x.surname].filter(Boolean).join(' '));
      if (s.status === 'fulfilled') for (const x of s.value.data ?? []) stations.set(x.id, x.name);
      return { users, stations };
    })();
    return this.names;
  }

  private async labels(): Promise<Labels> {
    const { users, stations } = await this.loadNames();
    return {
      station: (k) => stations.get(Number(k)) ?? `İstasyon #${k}`,
      device: (k) => this.deviceNames.get(k),
      // Yönetici hesapları /api/User listesinde dönmüyor.
      user: (k) => users.get(Number(k)) ?? `Kullanıcı #${k}`,
    };
  }

  private async toEntry(r: RawFrontendLog): Promise<LogEntry> {
    const { users } = await this.loadNames();
    const session: LogSession = { ...(r.session ?? {}) };
    // Listede kaydın kendi oturumu gelmez; backend'in token'dan aldığı hesap kullanılır.
    session.userId ??= opt(r.userId);
    session.stationId ??= opt(r.stationId);
    session.screen ??= opt(r.screen);
    if (session.userId && !session.user) session.user = users.get(session.userId);
    if (r.hostName) this.deviceNames.set(r.deviceId, r.hostName);
    const level = (LEVELS.includes(r.level as Level) ? r.level : 'INFO') as Level;
    const e: LogEntry = {
      id: String(r.id),
      deviceId: r.deviceId,
      appRunId: r.appRunId,
      appVersion: opt(r.appVersion),
      hostName: opt(r.hostName),
      timestamp: iso(r.timestampUtc)!,
      receivedAt: iso(r.receivedAtUtc),
      level,
      unit: r.unit,
      swreq: r.swreq,
      message: r.message,
      rule: opt(r.rule),
      req: opt(r.req),
      errorType: opt(r.errorType),
      correlationId: opt(r.correlationId),
      relatedOperationId: opt(r.relatedOperationId),
      http: r.httpMethod && r.httpPath
        ? { method: r.httpMethod, path: r.httpPath, status: opt(r.httpStatusCode), ms: opt(r.httpDurationMs) }
        : undefined,
      context: opt(r.context),
      session: Object.values(session).some((v) => v !== undefined) ? session : undefined,
      sender: { userId: opt(r.userId), stationId: opt(r.stationId), ipAddress: opt(r.ipAddress) },
      error: opt(r.error),
      stackTrace: opt(r.stackTrace),
      breadcrumbs: opt(r.breadcrumbs),
    };
    e.fingerprint = fingerprintOf(e);
    return e;
  }

  private async page(params: Params): Promise<{ items: LogEntry[]; total?: number }> {
    const env = await this.request<RawFrontendLog[]>(`/FrontendLog${toSearch({ RequireTotalCount: 'true', ...params })}`);
    return { items: await Promise.all((env.data ?? []).map((r) => this.toEntry(r))), total: env.totalCount };
  }

  // ── Son 7 gün penceresi ──

  private async recent(): Promise<LogEntry[]> {
    const fresh = this.win && Date.now() - this.win.loadedAt < REFRESH_MS;
    if (fresh) return this.win!.entries;
    this.winLoading ??= this.loadWindow().finally(() => (this.winLoading = null));
    return (await this.winLoading).entries;
  }

  private async loadWindow(): Promise<Window> {
    const now = Date.now();
    const from = new Date(now - WINDOW_MS).toISOString();
    const prev = this.win;
    const got: LogEntry[] = [];
    let truncated = false;
    for (let skip = 0; ; skip += PAGE) {
      const { items } = await this.page({
        From: from,
        Filter: prev ? JSON.stringify(['id', '>', prev.maxId]) : undefined,
        Sort: sortBy(['id', false]),
        Skip: skip,
        Take: PAGE,
        RequireTotalCount: 'false',
      });
      got.push(...items);
      if (items.length < PAGE) break;
      if ((prev?.entries.length ?? 0) + got.length >= WINDOW_CAP) {
        truncated = true;
        break;
      }
    }
    if (prev) this.statuses.reopenRegressions(got);
    const merged = [...got.reverse(), ...(prev?.entries ?? [])]
      .filter((e) => e.timestamp >= from)
      .sort((a, b) => b.timestamp.localeCompare(a.timestamp) || Number(b.id) - Number(a.id))
      .slice(0, WINDOW_CAP);
    const maxId = merged.reduce((m, e) => Math.max(m, Number(e.id)), prev?.maxId ?? 0);
    this.win = { entries: merged, maxId, loadedAt: now, truncated: truncated || (prev?.truncated ?? false) };
    this.capabilities.truncated = this.win.truncated;
    return this.win;
  }

  // ── LogApi ──

  async listLogs(q: LogQuery): Promise<Page<LogEntry>> {
    const skip = q.cursor ? Number(q.cursor) : 0;
    const take = Math.min(q.take ?? 100, 200);
    if (q.operationId) {
      // Backend yalnızca relatedOperationId'ye göre süzebiliyor; hata yanıtındaki
      // operationId context'te durduğu için son 7 gün panelde de taranır.
      const [server, local] = await Promise.all([
        this.page({ ...logParams({ ...q, operationId: undefined }), RelatedOperationId: q.operationId, Take: 500 }),
        this.recentDetailed(q),
      ]);
      const seen = new Set<string>();
      const all = [...server.items, ...local]
        .filter((e) => (seen.has(e.id) ? false : (seen.add(e.id), true)))
        .sort((a, b) => b.timestamp.localeCompare(a.timestamp));
      return { items: all.slice(skip, skip + take), nextCursor: skip + take < all.length ? String(skip + take) : undefined, total: all.length };
    }
    if (q.fingerprint) {
      // Fingerprint panelde hesaplanıyor; backend bu alana göre süzemiyor.
      const all = (await this.recent()).filter((e) => matches(e, q));
      return { items: all.slice(skip, skip + take), nextCursor: skip + take < all.length ? String(skip + take) : undefined, total: all.length };
    }
    const { items, total } = await this.page({
      ...logParams(q),
      Sort: sortBy(['timestampUtc', true], ['id', true]),
      Skip: skip,
      Take: take,
    });
    const more = total !== undefined ? skip + items.length < total : items.length === take;
    return { items, nextCursor: more ? String(skip + take) : undefined, total };
  }

  /**
   * İşlem kimliği listede gelmeyen context'te olabileceği için: aynı zaman
   * aralığındaki hata/uyarı kayıtlarının ayrıntısı çekilip süzülür (en çok 200).
   */
  private async recentDetailed(q: LogQuery): Promise<LogEntry[]> {
    const candidates = (await this.recent())
      .filter((e) => e.level !== 'INFO' && e.timestamp >= q.from && e.timestamp <= q.to && e.http?.status)
      .slice(0, 200);
    const detailed = await Promise.all(candidates.map((e) => this.getLog(e.id).catch(() => e)));
    return detailed.filter((e) => matches(e, q));
  }

  async getLog(id: string): Promise<LogEntry> {
    const env = await this.request<RawFrontendLog>(`/FrontendLog/${encodeURIComponent(id)}`);
    if (!env.data) throw new Error('404 — kayıt bulunamadı');
    return this.toEntry(env.data);
  }

  async surrounding(id: string, before = 50, after = 50): Promise<LogEntry[]> {
    const e = await this.getLog(id);
    const { items } = await this.page({
      DeviceId: e.deviceId,
      AppRunId: e.appRunId,
      Sort: sortBy(['timestampUtc', false], ['id', false]),
      Take: 2000,
    });
    const i = items.findIndex((x) => x.id === id);
    return i < 0 ? items : items.slice(Math.max(0, i - before), i + after + 1);
  }

  async trace(appRunId: string, req: string): Promise<LogEntry[]> {
    const { items } = await this.page({ AppRunId: appRunId, Req: req, Sort: sortBy(['timestampUtc', false], ['id', false]), Take: 500 });
    return items;
  }

  async facets(from: string, to: string): Promise<Facets> {
    const [all, labels] = await Promise.all([this.recent(), this.labels()]);
    return facetsOf(all, from, to, labels);
  }

  async listGroups(q: GroupQuery): Promise<LogGroup[]> {
    return listGroupsOf(await this.recent(), q, this.statuses);
  }

  async getGroup(fingerprint: string): Promise<LogGroup> {
    const all = await this.recent();
    if (!all.some((e) => e.fingerprint === fingerprint)) throw new Error('Bu sorun son 7 günde görülmedi.');
    return buildGroup(fingerprint, all, all, this.statuses.get(fingerprint));
  }

  async groupTimeline(fingerprint: string, from: string, to: string, interval: string): Promise<Bucket[]> {
    return bucketize((await this.recent()).filter((e) => e.fingerprint === fingerprint), from, to, interval);
  }

  async setGroupStatus(fingerprint: string, change: StatusChange): Promise<LogGroup> {
    this.statuses.set(fingerprint, change, 'Bu tarayıcı');
    return this.getGroup(fingerprint);
  }

  async timeseries(q: LogQuery, interval: string): Promise<Bucket[]> {
    return bucketize((await this.recent()).filter((e) => matches(e, q)), q.from, q.to, interval);
  }

  async top(q: LogQuery, dimension: TopDimension, limit = 10): Promise<TopItem[]> {
    const [all, labels] = await Promise.all([this.recent(), this.labels()]);
    return topOf(all, q, dimension, limit, labels);
  }

  async slow(from: string, to: string, limit = 10): Promise<SlowItem[]> {
    return slowOf(await this.recent(), from, to, limit);
  }

  async devices(): Promise<Device[]> {
    const [all, labels] = await Promise.all([this.recent(), this.labels()]);
    const dayAgo = new Date(Date.now() - DAY).toISOString();
    const byDevice = new Map<string, LogEntry[]>();
    for (const e of all) byDevice.set(e.deviceId, [...(byDevice.get(e.deviceId) ?? []), e]);
    return [...byDevice.entries()].map(([deviceId, mine]) => {
      const latest = mine[0];
      const stationId = mine.find((e) => e.session?.stationId)?.session?.stationId;
      const recent = mine.filter((e) => e.timestamp >= dayAgo);
      const lastReceived = mine.reduce((m, e) => ((e.receivedAt ?? e.timestamp) > m ? (e.receivedAt ?? e.timestamp) : m), '');
      return {
        deviceId,
        hostName: mine.find((e) => e.hostName)?.hostName ?? deviceId.slice(0, 8),
        stationId,
        stationName: stationId ? (labels.station(String(stationId)) ?? `İstasyon ${stationId}`) : undefined,
        appVersion: latest.appVersion ?? '—',
        flavor: '',
        lastSeenAt: lastReceived,
        lastEntryAt: latest.timestamp,
        errors24h: recent.filter((e) => e.level === 'ERROR').length,
        warns24h: recent.filter((e) => e.level === 'WARN').length,
      };
    });
  }

  async exportUrl(q: LogQuery, format: 'ndjson' | 'csv') {
    if (q.fingerprint) return exportFile((await this.recent()).filter((e) => matches(e, q)), format);
    const rows: LogEntry[] = [];
    for (let skip = 0; rows.length < 50_000; skip += PAGE) {
      const { items } = await this.page({ ...logParams(q), Sort: sortBy(['timestampUtc', true], ['id', true]), Skip: skip, Take: PAGE });
      rows.push(...items);
      if (items.length < PAGE) break;
    }
    return exportFile(rows, format);
  }

  async listServerErrors(q: ServerErrorQuery): Promise<Page<ServerError>> {
    const skip = q.cursor ? Number(q.cursor) : 0;
    const take = q.take ?? 50;
    const env = await this.request<RawBackendLog[]>(
      `/BackendLog${toSearch({
        From: q.from,
        To: q.to,
        Service: q.service,
        ExceptionType: q.exceptionType,
        OperationId: q.operationId,
        Search: q.search,
        RequireTotalCount: 'true',
        Sort: sortBy(['occurredAtUtc', true], ['id', true]),
        Skip: skip,
        Take: take,
      })}`,
    );
    const items = (env.data ?? []).map(toServerError);
    const total = env.totalCount;
    const more = total !== undefined ? skip + items.length < total : items.length === take;
    return { items, nextCursor: more ? String(skip + take) : undefined, total };
  }

  async getServerError(id: number): Promise<ServerError> {
    const env = await this.request<RawBackendLog>(`/BackendLog/${id}`);
    if (!env.data) throw new Error('404 — sunucu hatası bulunamadı');
    return toServerError(env.data);
  }
}
