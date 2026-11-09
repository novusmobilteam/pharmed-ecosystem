import { api, type LogGroup } from '../api';
import { BarList, StackedBars } from '../components/charts';
import { PageHead } from '../components/Layout';
import { Empty, ErrorBox, LevelTag, Loading, Panel, StatusTag } from '../components/ui';
import { fmtAgo, fmtCount, fmtMs, rangeBounds, rangeOf } from '../format';
import { useAsync, useNow } from '../hooks';
import { href, type Route } from '../router';

const SILENT_MIN = 15;

export function Overview({ route }: { route: Route }) {
  const rangeKey = rangeOf(route.params.get('range')).key;
  const now = useNow();
  const { from, to, interval } = rangeBounds(rangeKey);

  const data = useAsync(async () => {
    const q = { from, to };
    const [series, groups, rules, paths, slow, devices] = await Promise.all([
      api.timeseries({ ...q, level: ['WARN', 'ERROR'] }, interval),
      api.listGroups({ ...q, sort: 'count' }),
      api.top({ ...q, level: ['WARN'] }, 'rule', 6),
      api.top({ ...q, level: ['ERROR'] }, 'httpPath', 6),
      api.slow(from, to, 5),
      api.devices(),
    ]);
    return { series, groups, rules, paths, slow, devices };
  }, [rangeKey]);

  const d = data.data;
  const totals = d?.series.reduce(
    (acc, b) => ({ ERROR: acc.ERROR + b.counts.ERROR, WARN: acc.WARN + b.counts.WARN }),
    { ERROR: 0, WARN: 0 },
  );
  const open = d?.groups.filter((g) => g.status === 'open') ?? [];
  const regressed = open.filter((g) => g.regressed).length;
  const silent = d?.devices.filter((x) => now - Date.parse(x.lastSeenAt) > SILENT_MIN * 60_000) ?? [];
  const range = { range: rangeKey };

  return (
    <>
      <PageHead title="Genel bakış" route={route} />
      {data.error && <ErrorBox message={data.error} onRetry={data.reload} />}
      {!d && data.loading && <Loading />}
      {d && totals && (
        <>
          <div className="readouts">
            <a className="readout readout-error" href={href('/logs', { ...range, level: 'ERROR' })}>
              <span className="readout-num">{fmtCount(totals.ERROR)}</span>
              <span>hata</span>
            </a>
            <a className="readout readout-warn" href={href('/logs', { ...range, level: 'WARN' })}>
              <span className="readout-num">{fmtCount(totals.WARN)}</span>
              <span>uyarı</span>
            </a>
            <a className="readout" href={href('/issues', { ...range, status: 'open' })}>
              <span className="readout-num">{open.length}</span>
              <span>açık sorun{regressed ? `, ${regressed} geri döndü` : ''}</span>
            </a>
            <a className={`readout${silent.length ? ' readout-error' : ''}`} href={href('/devices')}>
              <span className="readout-num">{silent.length}</span>
              <span>sessiz kiosk ({SILENT_MIN} dk+)</span>
            </a>
          </div>

          <Panel title="Hata ve uyarılar" action={<span className="legend"><i className="lg-error" />Hata <i className="lg-warn" />Uyarı</span>}>
            <StackedBars buckets={d.series} levels={['ERROR', 'WARN']} height={140} />
          </Panel>

          <div className="grid-2">
            <Panel
              title="En sık açık sorunlar"
              action={
                <a className="link" href={href('/issues', { ...range, status: 'open' })}>
                  Tümü
                </a>
              }
            >
              {open.length ? <IssueMiniList groups={open.slice(0, 6)} range={rangeKey} /> : <Empty title="Bu aralıkta açık sorun yok." />}
            </Panel>

            <Panel title="Sessiz kiosklar">
              {silent.length ? (
                <ul className="mini">
                  {silent.map((x) => (
                    <li key={x.deviceId}>
                      <a href={href('/logs', { device: x.deviceId, range: '7d' })}>
                        <strong>{x.hostName}</strong>
                        <span className="muted">{x.stationName}</span>
                        <span className="mini-right">{fmtAgo(x.lastSeenAt, now)}</span>
                      </a>
                    </li>
                  ))}
                </ul>
              ) : (
                <Empty title="Tüm kiosklar log gönderiyor." hint={`Son ${SILENT_MIN} dakikada her kiosktan sinyal geldi.`} />
              )}
            </Panel>

            <Panel title="Uygulama kuralı redleri">
              {d.rules.length ? (
                <BarList items={d.rules} onPick={(rule) => (window.location.hash = href('/logs', { ...range, rule }))} />
              ) : (
                <Empty title="Kural reddi yok." />
              )}
            </Panel>

            <Panel title="En çok hata veren istekler">
              {d.paths.length ? (
                <BarList
                  items={d.paths}
                  onPick={(key) => (window.location.hash = href('/logs', { ...range, level: 'ERROR', path: key.split(' ')[1] }))}
                />
              ) : (
                <Empty title="Hatalı istek yok." />
              )}
            </Panel>
          </div>

          <Panel title="En yavaş istekler (p95)">
            {d.slow.length ? (
              <table className="table">
                <thead>
                  <tr>
                    <th>İstek</th>
                    <th className="num">Adet</th>
                    <th className="num">Ortalama</th>
                    <th className="num">p95</th>
                    <th className="num">En uzun</th>
                  </tr>
                </thead>
                <tbody>
                  {d.slow.map((s) => (
                    <tr key={`${s.method} ${s.path}`}>
                      <td>
                        <a href={href('/logs', { ...range, path: s.path })}>
                          <code>
                            {s.method} {s.path}
                          </code>
                        </a>
                      </td>
                      <td className="num">{fmtCount(s.count)}</td>
                      <td className="num">{fmtMs(s.avgMs)}</td>
                      <td className={`num${s.p95Ms > 5000 ? ' is-bad' : ''}`}>{fmtMs(s.p95Ms)}</td>
                      <td className="num">{fmtMs(s.maxMs)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <Empty title="Süre bilgisi olan istek yok." />
            )}
            <p className="note">Başarılı okuma istekleri log politikası gereği kaydedilmez; liste işlem yapan istekleri ve 5 sn'yi aşan yanıtları kapsar.</p>
          </Panel>
        </>
      )}
    </>
  );
}

function IssueMiniList({ groups, range }: { groups: LogGroup[]; range: string }) {
  return (
    <ul className="mini">
      {groups.map((g) => (
        <li key={g.fingerprint}>
          <a href={href(`/issues/${g.fingerprint}`, { range })}>
            <LevelTag level={g.level} />
            <span className="mini-title">{g.rule ?? g.title}</span>
            {g.regressed && <StatusTag status={g.status} regressed />}
            <span className="mini-right">
              {fmtCount(g.count)} <span className="muted">· {g.deviceCount} kiosk</span>
            </span>
          </a>
        </li>
      ))}
    </ul>
  );
}
