import { useEffect, useMemo, useRef, useState } from 'react';
import { api, LEVELS, type Level, type LogEntry, type LogQuery } from '../api';
import { StackedBars } from '../components/charts';
import { PageHead } from '../components/Layout';
import { LogDetail } from '../components/LogDetail';
import { LogTable } from '../components/LogTable';
import { Empty, ErrorBox, Loading, levelLabel } from '../components/ui';
import { fmtCount, rangeBounds, rangeOf } from '../format';
import { useAsync, useInterval } from '../hooks';
import { list, updateParams, type Route } from '../router';

/** URL parametreleri → sorgu. Bağlantı paylaşılınca aynı görünüm açılır. */
function queryFrom(route: Route, from: string, to: string): LogQuery {
  const p = route.params;
  const num = (k: string) => list(p, k).map(Number).filter((n) => !Number.isNaN(n));
  return {
    from,
    to,
    level: list(p, 'level') as Level[],
    stationId: num('station'),
    deviceId: list(p, 'device'),
    userId: num('user'),
    rule: list(p, 'rule'),
    unit: list(p, 'unit'),
    fingerprint: p.get('fp') ?? undefined,
    httpPath: p.get('path') ?? undefined,
    httpStatus: p.get('status') ? Number(p.get('status')) : undefined,
    appVersion: p.get('version') ?? undefined,
    search: p.get('q') ?? undefined,
    operationId: p.get('op') ? Number(p.get('op')) : undefined,
    take: 100,
  };
}

export function Logs({ route }: { route: Route }) {
  const p = route.params;
  const rangeKey = rangeOf(p.get('range')).key;
  const live = p.get('live') === '1';
  const selected = p.get('sel') ?? undefined;
  // Aralık sabit kalsın diye sınırlar yalnızca filtre değişince hesaplanır.
  const filterKey = [...p.entries()].filter(([k]) => k !== 'sel' && k !== 'live').map((kv) => kv.join('=')).sort().join('&');
  const bounds = useMemo(() => rangeBounds(rangeKey), [filterKey]); // eslint-disable-line react-hooks/exhaustive-deps
  const query = useMemo(() => queryFrom(route, bounds.from, bounds.to), [filterKey, bounds]); // eslint-disable-line react-hooks/exhaustive-deps

  const facets = useAsync(() => api.facets(bounds.from, bounds.to), [bounds.from]);
  const series = useAsync(() => api.timeseries(query, bounds.interval), [query]);
  const first = useAsync(() => api.listLogs(query), [query]);

  const [items, setItems] = useState<LogEntry[]>([]);
  const [cursor, setCursor] = useState<string | undefined>();
  const [more, setMore] = useState(false);
  const [freshIds, setFreshIds] = useState<Set<string>>(new Set());
  const newest = useRef<string | undefined>(undefined);

  useEffect(() => {
    if (!first.data) return;
    setItems(first.data.items);
    setCursor(first.data.nextCursor);
    newest.current = first.data.items[0]?.timestamp ?? bounds.to;
    setFreshIds(new Set());
  }, [first.data]); // eslint-disable-line react-hooks/exhaustive-deps

  // Canlı izleme: son kayıttan sonrası 5 sn'de bir çekilir, listenin başına eklenir.
  useInterval(
    async () => {
      const since = newest.current ?? bounds.to;
      const page = await api.listLogs({ ...query, from: since, to: new Date().toISOString(), cursor: undefined, take: 200 });
      const known = new Set(items.map((i) => i.id));
      const added = page.items.filter((i) => !known.has(i.id));
      if (!added.length) return;
      newest.current = added[0].timestamp;
      setItems((cur) => [...added, ...cur]);
      setFreshIds(new Set(added.map((a) => a.id)));
    },
    live ? 5000 : null,
  );

  async function loadMore() {
    if (!cursor) return;
    setMore(true);
    try {
      const page = await api.listLogs({ ...query, cursor });
      setItems((cur) => [...cur, ...page.items]);
      setCursor(page.nextCursor);
    } finally {
      setMore(false);
    }
  }

  async function exportAs(format: 'ndjson' | 'csv') {
    const { url, filename } = await api.exportUrl(query, format);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
  }

  const set = (patch: Record<string, string | undefined | string[]>) => updateParams(route, { ...patch, sel: undefined });
  const levels = list(p, 'level');
  const f = facets.data;
  const active = activeChips(route, f);

  return (
    <div className={`with-detail${selected ? ' has-detail' : ''}`}>
      <div className="with-detail-main">
        <PageHead title="Loglar" route={route}>
          <label className="toggle">
            <input type="checkbox" checked={live} onChange={(e) => updateParams(route, { live: e.target.checked ? '1' : undefined })} />
            <span>Canlı izle</span>
          </label>
          <div className="menu">
            <button className="btn">Dışa aktar</button>
            <div className="menu-list">
              <button onClick={() => exportAs('csv')}>CSV (Excel)</button>
              <button onClick={() => exportAs('ndjson')}>NDJSON (ham kayıt)</button>
            </div>
          </div>
        </PageHead>

        <div className="filters">
          <form
            className="search"
            onSubmit={(e) => {
              e.preventDefault();
              const v = new FormData(e.currentTarget).get('q') as string;
              set({ q: v.trim() || undefined });
            }}
          >
            <input
              key={p.get('q') ?? ''}
              name="q"
              defaultValue={p.get('q') ?? ''}
              placeholder="Mesaj, hata, bağlam içinde ara (ör. Stok yetersiz, 412, r57)"
              aria-label="Loglarda ara"
            />
          </form>
          <div className="seg" role="group" aria-label="Seviye">
            {LEVELS.map((l) => {
              const on = levels.includes(l);
              return (
                <button
                  key={l}
                  className={`${on ? 'is-on' : ''} seg-${l.toLowerCase()}`}
                  onClick={() => set({ level: on ? levels.filter((x) => x !== l) : [...levels, l] })}
                >
                  {levelLabel(l)}
                </button>
              );
            })}
          </div>
          <Select label="İstasyon" value={p.get('station')} options={f?.stations} onChange={(v) => set({ station: v })} />
          <Select label="Kiosk" value={p.get('device')} options={f?.devices} onChange={(v) => set({ device: v })} />
          <Select label="Kullanıcı" value={p.get('user')} options={f?.users} onChange={(v) => set({ user: v })} />
          <Select label="Kural" value={p.get('rule')} options={f?.rules} onChange={(v) => set({ rule: v })} />
          <Select label="Sürüm" value={p.get('version')} options={f?.versions} onChange={(v) => set({ version: v })} />
        </div>

        {active.length > 0 && (
          <div className="chips">
            {active.map((c) => (
              <button key={c.key} className="chip chip-filter" onClick={() => set({ [c.key]: undefined })} aria-label={`${c.label} filtresini kaldır`}>
                {c.label} ×
              </button>
            ))}
            <button className="link" onClick={() => updateParams(route, Object.fromEntries([...p.keys()].filter((k) => k !== 'range').map((k) => [k, undefined])))}>
              Tümünü temizle
            </button>
          </div>
        )}

        <div className="panel panel-flush">
          {series.data && <StackedBars buckets={series.data} height={72} />}
          <div className="result-line">
            {first.loading && !items.length ? 'Yükleniyor…' : `${fmtCount(items.length)}${cursor ? '+' : ''} kayıt`}
            {live && <span className="live-dot">canlı</span>}
          </div>
        </div>

        {first.error && <ErrorBox message={first.error} onRetry={first.reload} />}
        {first.loading && !items.length && <Loading />}
        {!first.loading && !first.error && items.length === 0 && (
          <Empty title="Bu filtrelerle kayıt yok." hint="Zaman aralığını genişletin ya da bir filtreyi kaldırın." />
        )}
        {items.length > 0 && (
          <LogTable items={items} selectedId={selected} freshIds={freshIds} onSelect={(e) => updateParams(route, { sel: e.id })} />
        )}
        {cursor && (
          <div className="more">
            <button className="btn" onClick={loadMore} disabled={more}>
              {more ? 'Yükleniyor…' : 'Daha eski kayıtlar'}
            </button>
          </div>
        )}
      </div>
      {selected && <LogDetail id={selected} onClose={() => updateParams(route, { sel: undefined })} />}
    </div>
  );
}

function Select({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: string | null;
  options?: { key: string; label: string; count: number }[];
  onChange: (v: string | undefined) => void;
}) {
  return (
    <label className="select">
      <span className="sr-only">{label}</span>
      <select value={value ?? ''} onChange={(e) => onChange(e.target.value || undefined)}>
        <option value="">{label}: tümü</option>
        {options?.map((o) => (
          <option key={o.key} value={o.key}>
            {o.label} ({fmtCount(o.count)})
          </option>
        ))}
      </select>
    </label>
  );
}

function activeChips(route: Route, f?: { stations: { key: string; label: string }[]; devices: { key: string; label: string }[]; users: { key: string; label: string }[] }) {
  const p = route.params;
  const name = (arr: { key: string; label: string }[] | undefined, k: string) => arr?.find((x) => x.key === k)?.label ?? k;
  const chips: { key: string; label: string }[] = [];
  if (p.get('q')) chips.push({ key: 'q', label: `"${p.get('q')}"` });
  if (p.get('station')) chips.push({ key: 'station', label: `İstasyon: ${name(f?.stations, p.get('station')!)}` });
  if (p.get('device')) chips.push({ key: 'device', label: `Kiosk: ${name(f?.devices, p.get('device')!)}` });
  if (p.get('user')) chips.push({ key: 'user', label: `Kullanıcı: ${name(f?.users, p.get('user')!)}` });
  if (p.get('rule')) chips.push({ key: 'rule', label: `Kural: ${p.get('rule')}` });
  if (p.get('version')) chips.push({ key: 'version', label: `Sürüm: ${p.get('version')}` });
  if (p.get('path')) chips.push({ key: 'path', label: `İstek: ${p.get('path')}` });
  if (p.get('status')) chips.push({ key: 'status', label: `HTTP ${p.get('status')}` });
  if (p.get('fp')) chips.push({ key: 'fp', label: 'Sorun grubu' });
  if (p.get('op')) chips.push({ key: 'op', label: `İşlem: ${p.get('op')}` });
  if (p.get('unit')) chips.push({ key: 'unit', label: `Birim: ${p.get('unit')}` });
  return chips;
}
