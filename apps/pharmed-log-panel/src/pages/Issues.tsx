import { api, type GroupStatus, type LogGroup } from '../api';
import { Sparkline } from '../components/charts';
import { PageHead, WindowNote } from '../components/Layout';
import { Empty, ErrorBox, LevelTag, Loading, StatusTag } from '../components/ui';
import { KIND_LABEL, diagnoseGroup } from '../diagnosis';
import { fmtAgo, fmtCount, rangeBounds, rangeOf } from '../format';
import { useAsync, useNow } from '../hooks';
import { href, updateParams, type Route } from '../router';

const TABS: { key: GroupStatus | 'all'; label: string }[] = [
  { key: 'open', label: 'Açık' },
  { key: 'resolved', label: 'Çözüldü' },
  { key: 'ignored', label: 'Yok sayıldı' },
  { key: 'all', label: 'Tümü' },
];

const SORTS = [
  { key: 'lastSeen', label: 'Son görülme' },
  { key: 'count', label: 'Tekrar sayısı' },
  { key: 'users', label: 'Etkilenen kullanıcı' },
  { key: 'firstSeen', label: 'İlk görülme' },
] as const;

export function Issues({ route }: { route: Route }) {
  const p = route.params;
  const rangeKey = rangeOf(p.get('range')).key;
  const tab = (p.get('status') as GroupStatus | 'all' | null) ?? 'open';
  const sort = (p.get('sort') as (typeof SORTS)[number]['key'] | null) ?? 'lastSeen';
  const level = p.get('level');
  const search = p.get('q') ?? '';
  const { from, to } = rangeBounds(rangeKey);

  const groups = useAsync(
    () =>
      api.listGroups({
        from,
        to,
        status: tab === 'all' ? undefined : tab,
        sort,
        level: level ? [level as 'WARN' | 'ERROR'] : undefined,
        search: search || undefined,
      }),
    [rangeKey, tab, sort, level, search],
  );

  return (
    <>
      <PageHead title="Sorunlar" route={route} />
      <p className="lead">
        Aynı hatanın tekrarları tek satırda toplanır. Bir sorunu çözdüğünüzde işaretleyin; yeniden görülürse “Geri döndü” olarak açılır.
        {!api.capabilities.sharedGroupStatus && !api.isMock && ' Durumlar şimdilik yalnızca bu tarayıcıda saklanır.'}
      </p>
      {api.capabilities.truncated && <WindowNote />}
      <div className="filters">
        <div className="seg" role="tablist" aria-label="Durum">
          {TABS.map((t) => (
            <button key={t.key} role="tab" aria-selected={tab === t.key} className={tab === t.key ? 'is-on' : ''} onClick={() => updateParams(route, { status: t.key })}>
              {t.label}
            </button>
          ))}
        </div>
        <div className="seg" role="group" aria-label="Seviye">
          {[
            { key: undefined, label: 'Hepsi' },
            { key: 'ERROR', label: 'Hata' },
            { key: 'WARN', label: 'Uyarı' },
          ].map((l) => (
            <button key={l.label} className={(level ?? undefined) === l.key ? 'is-on' : ''} onClick={() => updateParams(route, { level: l.key })}>
              {l.label}
            </button>
          ))}
        </div>
        <form
          className="search"
          onSubmit={(e) => {
            e.preventDefault();
            updateParams(route, { q: ((new FormData(e.currentTarget).get('q') as string) || '').trim() || undefined });
          }}
        >
          <input key={search} name="q" defaultValue={search} placeholder="Başlık, kural kodu, endpoint ara" aria-label="Sorunlarda ara" />
        </form>
        <label className="select">
          <span className="sr-only">Sıralama</span>
          <select value={sort} onChange={(e) => updateParams(route, { sort: e.target.value })}>
            {SORTS.map((s) => (
              <option key={s.key} value={s.key}>
                Sırala: {s.label}
              </option>
            ))}
          </select>
        </label>
      </div>

      {groups.error && <ErrorBox message={groups.error} onRetry={groups.reload} />}
      {groups.loading && !groups.data && <Loading />}
      {groups.data && groups.data.length === 0 && (
        <Empty
          title={tab === 'open' ? 'Bu aralıkta açık sorun yok.' : 'Bu filtrelerle sorun yok.'}
          hint={tab === 'open' ? 'Kiosklardan gelen hatalar burada gruplanır.' : 'Zaman aralığını genişletmeyi deneyin.'}
        />
      )}
      {groups.data && groups.data.length > 0 && (
        <div className="issues">
          {groups.data.map((g) => (
            <IssueRow key={g.fingerprint} g={g} from={from} to={to} range={rangeKey} />
          ))}
        </div>
      )}
    </>
  );
}

function IssueRow({ g, from, to, range }: { g: LogGroup; from: string; to: string; range: string }) {
  const now = useNow();
  const interval = rangeOf(range).interval;
  const tl = useAsync(() => api.groupTimeline(g.fingerprint, from, to, interval), [g.fingerprint, from]);
  const kind = diagnoseGroup(g).kind;
  return (
    <a className={`issue issue-${g.level.toLowerCase()}`} href={href(`/issues/${g.fingerprint}`, { range })}>
      <div className="issue-main">
        <div className="issue-title">
          <LevelTag level={g.level} />
          <span>{g.title}</span>
        </div>
        <div className="issue-sub">
          <span className="kind">{KIND_LABEL[kind]}</span>
          {g.rule && <code className="chip">{g.rule}</code>}
          {g.httpPath && (
            <code className="chip chip-muted">
              {g.httpMethod} {g.httpPath}
            </code>
          )}
          {g.errorType && !g.rule && <code className="chip chip-muted">{g.errorType}</code>}
          <span className="muted">
            İlk {fmtAgo(g.firstSeen, now)} · son {fmtAgo(g.lastSeen, now)}
          </span>
        </div>
      </div>
      <div className="issue-spark">{tl.data && <Sparkline values={tl.data.map((b) => b.counts.ERROR + b.counts.WARN)} />}</div>
      <div className="issue-num">
        <strong>{fmtCount(g.count)}</strong>
        <span>tekrar</span>
      </div>
      <div className="issue-num">
        <strong>{g.deviceCount}</strong>
        <span>kiosk</span>
      </div>
      <div className="issue-num">
        <strong>{g.userCount}</strong>
        <span>kullanıcı</span>
      </div>
      <div className="issue-status">
        <StatusTag status={g.status} regressed={g.regressed} />
      </div>
    </a>
  );
}
