// "PharMed Cihaz Logları — Backend API Sözleşmesi" ile birebir aynı şekiller.
// Backend değiştikçe önce burası güncellenir; ekranlar yalnızca bu tipleri bilir.

export type Level = 'INFO' | 'WARN' | 'ERROR';
export const LEVELS: Level[] = ['ERROR', 'WARN', 'INFO'];

export interface HttpInfo {
  method: string;
  path: string;
  status?: number;
  ms?: number;
}

export interface LogSession {
  userId?: number;
  user?: string;
  stationId?: number;
  serviceId?: number;
  screen?: string;
}

export interface LogEntry {
  id: string;
  deviceId: string;
  appRunId: string;
  appVersion?: string;
  timestamp: string;
  receivedAt?: string;
  level: Level;
  unit: string;
  swreq: string;
  message: string;
  rule?: string;
  req?: string;
  errorType?: string;
  http?: HttpInfo;
  context?: Record<string, unknown>;
  session?: LogSession;
  error?: string;
  stackTrace?: string;
  breadcrumbs?: string[];
  fingerprint?: string;
}

export interface LogQuery {
  from: string;
  to: string;
  level?: Level[];
  stationId?: number[];
  deviceId?: string[];
  userId?: number[];
  unit?: string[];
  rule?: string[];
  fingerprint?: string;
  appRunId?: string;
  req?: string;
  httpPath?: string;
  httpStatus?: number;
  appVersion?: string;
  search?: string;
  cursor?: string;
  take?: number;
}

export interface Page<T> {
  items: T[];
  nextCursor?: string;
}

export type GroupStatus = 'open' | 'resolved' | 'ignored';

export interface LogGroup {
  fingerprint: string;
  title: string;
  level: Level;
  unit: string;
  rule?: string;
  errorType?: string;
  httpMethod?: string;
  httpPath?: string;
  status: GroupStatus;
  count: number;
  totalCount: number;
  deviceCount: number;
  userCount: number;
  stationCount: number;
  firstSeen: string;
  lastSeen: string;
  firstSeenVersion?: string;
  lastSeenVersion?: string;
  sampleEntryId: string;
  note?: string;
  statusChangedBy?: string;
  statusChangedAt?: string;
  resolvedInVersion?: string;
  regressed?: boolean;
}

export interface GroupQuery {
  from: string;
  to: string;
  status?: GroupStatus;
  level?: Level[];
  search?: string;
  sort?: 'lastSeen' | 'count' | 'users' | 'firstSeen';
}

export interface Bucket {
  t: string;
  counts: Record<Level, number>;
}

export type TopDimension = 'rule' | 'httpPath' | 'station' | 'device' | 'user' | 'unit';

export interface TopItem {
  key: string;
  label: string;
  count: number;
}

export interface SlowItem {
  method: string;
  path: string;
  count: number;
  avgMs: number;
  p95Ms: number;
  maxMs: number;
}

export interface Device {
  deviceId: string;
  hostName: string;
  stationId?: number;
  stationName?: string;
  appVersion: string;
  flavor: string;
  lastSeenAt: string;
  lastEntryAt?: string;
  errors24h: number;
  warns24h: number;
}

export interface Facets {
  units: TopItem[];
  rules: TopItem[];
  stations: TopItem[];
  devices: TopItem[];
  users: TopItem[];
  versions: TopItem[];
}

export interface StatusChange {
  status: GroupStatus;
  note?: string;
  resolvedInVersion?: string;
}

/** Panelin konuştuğu tek arayüz — sahte veri ya da gerçek backend. */
export interface LogApi {
  readonly isMock: boolean;
  listLogs(q: LogQuery): Promise<Page<LogEntry>>;
  getLog(id: string): Promise<LogEntry>;
  surrounding(id: string, before?: number, after?: number): Promise<LogEntry[]>;
  trace(appRunId: string, req: string): Promise<LogEntry[]>;
  facets(from: string, to: string): Promise<Facets>;
  listGroups(q: GroupQuery): Promise<LogGroup[]>;
  getGroup(fingerprint: string): Promise<LogGroup>;
  groupTimeline(fingerprint: string, from: string, to: string, interval: string): Promise<Bucket[]>;
  setGroupStatus(fingerprint: string, change: StatusChange): Promise<LogGroup>;
  timeseries(q: LogQuery, interval: string): Promise<Bucket[]>;
  top(q: LogQuery, dimension: TopDimension, limit?: number): Promise<TopItem[]>;
  slow(from: string, to: string, limit?: number): Promise<SlowItem[]>;
  devices(): Promise<Device[]>;
  exportUrl(q: LogQuery, format: 'ndjson' | 'csv'): Promise<{ url: string; filename: string }>;
}
