import { api, type LogEntry } from '../api';
import { diagnoseEntry } from '../diagnosis';
import { fmtDateTime, fmtMillis, fmtMs } from '../format';
import { useAsync } from '../hooks';
import { useDeviceName, useStationName } from '../lookups';
import { href } from '../router';
import { DiagnosisCard } from './DiagnosisCard';
import { JsonView } from './JsonView';
import { Copy, ErrorBox, LevelTag, Loading } from './ui';

/** Kayıt detayı — listede tıklanan kaydın tamamı (bağlam, önceki adımlar, stack). */
export function LogDetail({ id, onClose }: { id: string; onClose: () => void }) {
  const { data: e, error, loading, reload } = useAsync(() => api.getLog(id), [id]);
  return (
    <aside className="detail" aria-label="Kayıt detayı">
      <header className="detail-head">
        <h2>Kayıt detayı</h2>
        <button className="btn btn-ghost" onClick={onClose} aria-label="Kapat">
          Kapat
        </button>
      </header>
      {loading && !e && <Loading />}
      {error && <ErrorBox message={error} onRetry={reload} />}
      {e && <EntryBody e={e} />}
    </aside>
  );
}

function EntryBody({ e }: { e: LogEntry }) {
  const deviceName = useDeviceName();
  const stationName = useStationName();
  const d = e.level !== 'INFO' ? diagnoseEntry(e) : undefined;
  const s = e.session;

  return (
    <div className="detail-body">
      <div className="detail-title">
        <LevelTag level={e.level} />
        <time>
          {fmtDateTime(e.timestamp)}.{fmtMillis(e.timestamp)}
        </time>
      </div>
      <p className="detail-msg">{e.message}</p>
      {e.error && <p className="detail-error">{e.error}</p>}

      <nav className="detail-actions" aria-label="İlgili kayıtlar">
        {e.req && (
          <a className="btn" href={href('/trace', { appRunId: e.appRunId, req: e.req, from: e.id })}>
            İsteğin izi ({e.req})
          </a>
        )}
        <a className="btn" href={href('/around', { id: e.id })}>
          Kioskta öncesi / sonrası
        </a>
        {e.fingerprint && (
          <a className="btn" href={href(`/issues/${e.fingerprint}`)}>
            Sorun grubu
          </a>
        )}
        <Copy text={JSON.stringify(e, null, 2)} label="JSON kopyala" />
      </nav>

      {d && <DiagnosisCard d={d} />}

      <dl className="facts">
        <dt>Kiosk</dt>
        <dd>
          <a href={href('/logs', { device: e.deviceId })}>{deviceName(e.deviceId)}</a>
          {e.appVersion && <span className="muted"> · {e.appVersion}</span>}
        </dd>
        <dt>Kullanıcı</dt>
        <dd>{s?.user ? <a href={href('/logs', { user: String(s.userId) })}>{s.user}</a> : 'Oturum yok'}</dd>
        <dt>İstasyon</dt>
        <dd>{s?.stationId ? stationName(s.stationId) : '—'}</dd>
        <dt>Ekran</dt>
        <dd>{s?.screen ? <code>{s.screen}</code> : '—'}</dd>
        <dt>Birim</dt>
        <dd>
          <code>{e.unit}</code> <span className="muted">{e.swreq}</span>
        </dd>
        {e.http && (
          <>
            <dt>İstek</dt>
            <dd>
              <code>
                {e.http.method} {e.http.path}
              </code>
              {e.http.status !== undefined && <span className="muted"> · {e.http.status}</span>}
              {e.http.ms !== undefined && <span className="muted"> · {fmtMs(e.http.ms)}</span>}
            </dd>
          </>
        )}
        {e.errorType && (
          <>
            <dt>Hata tipi</dt>
            <dd>
              <code>{e.errorType}</code>
            </dd>
          </>
        )}
      </dl>

      {e.context && Object.keys(e.context).length > 0 && (
        <section className="detail-section">
          <h3>Bağlam</h3>
          <JsonView value={e.context} />
        </section>
      )}

      {e.breadcrumbs && e.breadcrumbs.length > 0 && (
        <section className="detail-section">
          <h3>Önceki adımlar ({e.breadcrumbs.length})</h3>
          <ol className="crumbs">
            {e.breadcrumbs.map((b, i) => {
              const [time, ...rest] = b.split(' ');
              return (
                <li key={i}>
                  <time>{time}</time>
                  <span>{rest.join(' ')}</span>
                </li>
              );
            })}
          </ol>
        </section>
      )}

      {e.stackTrace && (
        <section className="detail-section">
          <h3>Stack trace</h3>
          <pre className="stack">{e.stackTrace}</pre>
        </section>
      )}
    </div>
  );
}
