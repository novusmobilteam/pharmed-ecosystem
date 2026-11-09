// Gerçek backend istemcisi — sözleşmedeki /api/DeviceLog endpoint'leri.
// VITE_API_BASE_URL verilmezse panel sahte veriyle çalışır (bkz. api/index.ts).

import type {
  Bucket,
  Device,
  Facets,
  GroupQuery,
  LogApi,
  LogEntry,
  LogGroup,
  LogQuery,
  Page,
  SlowItem,
  StatusChange,
  TopDimension,
  TopItem,
} from './types';

type Params = Record<string, string | number | undefined | null | (string | number)[]>;

function toSearch(params: Params): string {
  const sp = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v === undefined || v === null || v === '') continue;
    if (Array.isArray(v)) {
      if (v.length) sp.set(k, v.join(','));
    } else {
      sp.set(k, String(v));
    }
  }
  const s = sp.toString();
  return s ? `?${s}` : '';
}

function logParams(q: LogQuery): Params {
  return { ...q };
}

export class HttpLogApi implements LogApi {
  readonly isMock = false;

  constructor(
    private readonly baseUrl: string,
    private readonly token: () => string | null,
  ) {}

  private async request<T>(path: string, init?: RequestInit): Promise<T> {
    const token = this.token();
    const res = await fetch(`${this.baseUrl.replace(/\/$/, '')}/api/DeviceLog${path}`, {
      ...init,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...init?.headers,
      },
    });
    if (!res.ok) {
      let detail = '';
      try {
        const body = await res.json();
        detail = body?.message ?? body?.error ?? '';
      } catch {
        // gövde JSON değil
      }
      throw new Error(`${res.status} ${res.statusText}${detail ? ` — ${detail}` : ''}`);
    }
    return (await res.json()) as T;
  }

  listLogs(q: LogQuery) {
    return this.request<Page<LogEntry>>(toSearch(logParams(q)));
  }
  getLog(id: string) {
    return this.request<LogEntry>(`/${encodeURIComponent(id)}`);
  }
  surrounding(id: string, before = 50, after = 50) {
    return this.request<LogEntry[]>(`/${encodeURIComponent(id)}/surrounding${toSearch({ before, after })}`);
  }
  trace(appRunId: string, req: string) {
    return this.request<LogEntry[]>(`/trace${toSearch({ appRunId, req })}`);
  }
  facets(from: string, to: string) {
    return this.request<Facets>(`/facets${toSearch({ from, to })}`);
  }
  listGroups(q: GroupQuery) {
    return this.request<LogGroup[]>(`/groups${toSearch({ ...q })}`);
  }
  getGroup(fingerprint: string) {
    return this.request<LogGroup>(`/groups/${encodeURIComponent(fingerprint)}`);
  }
  groupTimeline(fingerprint: string, from: string, to: string, interval: string) {
    return this.request<Bucket[]>(
      `/groups/${encodeURIComponent(fingerprint)}/timeline${toSearch({ from, to, interval })}`,
    );
  }
  setGroupStatus(fingerprint: string, change: StatusChange) {
    return this.request<LogGroup>(`/groups/${encodeURIComponent(fingerprint)}/status`, {
      method: 'PUT',
      body: JSON.stringify(change),
    });
  }
  timeseries(q: LogQuery, interval: string) {
    return this.request<Bucket[]>(`/stats/timeseries${toSearch({ ...logParams(q), interval, groupBy: 'level' })}`);
  }
  top(q: LogQuery, dimension: TopDimension, limit = 10) {
    return this.request<TopItem[]>(`/stats/top${toSearch({ ...logParams(q), dimension, limit })}`);
  }
  slow(from: string, to: string, limit = 10) {
    return this.request<SlowItem[]>(`/stats/slow${toSearch({ from, to, limit })}`);
  }
  devices() {
    return this.request<Device[]>('/devices');
  }
  async exportUrl(q: LogQuery, format: 'ndjson' | 'csv') {
    return {
      url: `${this.baseUrl.replace(/\/$/, '')}/api/DeviceLog/export${toSearch({ ...logParams(q), format })}`,
      filename: `pharmed-logs.${format}`,
    };
  }
}
