import { api } from '../api';
import { PageHead } from '../components/Layout';
import { Empty, ErrorBox, Loading, Panel } from '../components/ui';
import { fmtAgo, fmtCount, fmtShort } from '../format';
import { useAsync, useNow } from '../hooks';
import { href, type Route } from '../router';

const SILENT_MIN = 15;

function compareVersion(a = '', b = '') {
  const pa = a.split(/[.+]/).map(Number);
  const pb = b.split(/[.+]/).map(Number);
  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    const d = (pa[i] ?? 0) - (pb[i] ?? 0);
    if (d) return d;
  }
  return 0;
}

export function Devices({ route }: { route: Route }) {
  const now = useNow(15_000);
  const devices = useAsync(() => api.devices(), []);
  const list = devices.data ?? [];
  const latest = list.reduce((v, d) => (compareVersion(d.appVersion, v) > 0 ? d.appVersion : v), '');

  return (
    <>
      <PageHead title="Kiosklar" route={route} showRange={false} />
      <p className="lead">
        Her kiosk 5 dakikada bir sinyal gönderir. {SILENT_MIN} dakikadır sinyal gelmeyen kiosk kapalı, ağsız ya da uygulaması çökmüş olabilir.
      </p>
      {devices.error && <ErrorBox message={devices.error} onRetry={devices.reload} />}
      {devices.loading && !devices.data && <Loading />}
      {devices.data && list.length === 0 && <Empty title="Henüz log gönderen kiosk yok." hint="Kiosklar ilk açılışta otomatik olarak burada görünür." />}
      {list.length > 0 && (
        <Panel className="panel-flush">
          <table className="table">
            <thead>
              <tr>
                <th>Kiosk</th>
                <th>İstasyon</th>
                <th>Durum</th>
                <th>Sürüm</th>
                <th>Son kayıt</th>
                <th className="num">Hata (24 sa)</th>
                <th className="num">Uyarı (24 sa)</th>
              </tr>
            </thead>
            <tbody>
              {[...list]
                .sort((a, b) => b.errors24h - a.errors24h)
                .map((d) => {
                  const silentMs = now - Date.parse(d.lastSeenAt);
                  const silent = silentMs > SILENT_MIN * 60_000;
                  const outdated = compareVersion(d.appVersion, latest) < 0;
                  return (
                    <tr key={d.deviceId}>
                      <td>
                        <a href={href('/logs', { device: d.deviceId, range: '24h' })}>
                          <strong>{d.hostName}</strong>
                        </a>
                      </td>
                      <td>{d.stationName ?? '—'}</td>
                      <td>
                        {silent ? (
                          <span className="status status-regressed">Sessiz · {fmtAgo(d.lastSeenAt, now)}</span>
                        ) : (
                          <span className="status status-resolved">Çevrimiçi</span>
                        )}
                      </td>
                      <td>
                        <code>{d.appVersion}</code>
                        {outdated && <span className="muted"> · güncel değil</span>}
                      </td>
                      <td>{fmtShort(d.lastEntryAt)}</td>
                      <td className={`num${d.errors24h ? ' is-bad' : ''}`}>
                        <a href={href('/logs', { device: d.deviceId, level: 'ERROR', range: '24h' })}>{fmtCount(d.errors24h)}</a>
                      </td>
                      <td className="num">
                        <a href={href('/logs', { device: d.deviceId, level: 'WARN', range: '24h' })}>{fmtCount(d.warns24h)}</a>
                      </td>
                    </tr>
                  );
                })}
            </tbody>
          </table>
        </Panel>
      )}
    </>
  );
}
