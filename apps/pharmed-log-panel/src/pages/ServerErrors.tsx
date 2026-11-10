import { useState } from 'react';
import { api, type ServerError } from '../api';
import { PageHead } from '../components/Layout';
import { JsonView } from '../components/JsonView';
import { Copy, Empty, ErrorBox, Loading, Panel } from '../components/ui';
import { fmtCount, fmtDateTime, fmtShort, rangeBounds, shortType } from '../format';
import { useAsync } from '../hooks';
import { href, updateParams, type Route } from '../router';

/** Backend'de yakalanmamış hatalar (BackendLog). */
export function ServerErrors({ route }: { route: Route }) {
  const p = route.params;
  const { from, to } = rangeBounds(p.get('range'));
  const [pages, setPages] = useState(1);
  const op = Number(p.get('op')) || undefined;
  const q = { from: op ? new Date(0).toISOString() : from, to, service: p.get('service') ?? undefined, operationId: op, search: p.get('q') ?? undefined };
  const list = useAsync(() => api.listServerErrors({ ...q, take: 50 * pages }), [p.toString(), pages]);
  const selected = p.get('id');
  const items = list.data?.items ?? [];
  const set = (patch: Record<string, string | undefined>) => updateParams(route, patch);

  return (
    <div className={`with-detail${selected ? ' has-detail' : ''}`}>
      <div className="with-detail-main">
        <PageHead title="Sunucu hataları" route={route} />
        <p className="lead">
          Backend'de yakalanmamış hatalar. Kiosktaki kayıtla aynı <code>operationId</code>'yi taşır; istemci kaydının detayından buraya bağlantı vardır.
        </p>
        <div className="filters">
          <form
            className="search"
            onSubmit={(e) => {
              e.preventDefault();
              const v = String(new FormData(e.currentTarget).get('q') ?? '').trim();
              set({ q: v || undefined });
            }}
          >
            <input key={p.get('q') ?? ''} name="q" defaultValue={p.get('q') ?? ''} placeholder="Hata mesajı ya da istek yolu içinde ara" aria-label="Sunucu hatalarında ara" />
          </form>
          {(p.get('service') || op) && (
            <div className="chips">
              {p.get('service') && (
                <button className="chip chip-filter" onClick={() => set({ service: undefined })}>
                  Servis: {p.get('service')} ×
                </button>
              )}
              {op && (
                <button className="chip chip-filter" onClick={() => set({ op: undefined })}>
                  İşlem: {op} ×
                </button>
              )}
            </div>
          )}
        </div>

        {list.error && <ErrorBox message={list.error} onRetry={list.reload} />}
        {list.loading && !list.data && <Loading />}
        {list.data && items.length === 0 && <Empty title="Bu aralıkta sunucu hatası yok." />}
        {items.length > 0 && (
          <Panel className="panel-flush">
            <div className="result-line">{fmtCount(list.data?.total ?? items.length)} hata</div>
            <table className="table">
              <thead>
                <tr>
                  <th>Zaman</th>
                  <th>İstek</th>
                  <th>Hata</th>
                  <th className="num">İşlem</th>
                </tr>
              </thead>
              <tbody>
                {items.map((x) => (
                  <tr key={x.id} className={String(x.id) === selected ? 'is-selected' : ''}>
                    <td className="nowrap">{fmtShort(x.occurredAt)}</td>
                    <td>
                      <a href={href('/server-errors', { ...Object.fromEntries(p), id: String(x.id) })}>
                        <code>
                          {x.httpMethod} {x.requestPath}
                        </code>
                      </a>
                      <div className="muted">
                        <button className="link" onClick={() => set({ service: x.service })}>
                          {x.service}
                        </button>{' '}
                        · {x.action}
                      </div>
                    </td>
                    <td>
                      <code>{shortType(x.exceptionType)}</code>
                      <div className="clamp">{x.exceptionMessage}</div>
                    </td>
                    <td className="num">{x.operationId ?? '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            {list.data?.nextCursor && (
              <div className="more">
                <button className="btn" onClick={() => setPages((n) => n + 1)} disabled={list.loading}>
                  Daha fazla
                </button>
              </div>
            )}
          </Panel>
        )}
      </div>
      {selected && <ServerErrorDetail id={Number(selected)} onClose={() => set({ id: undefined })} />}
    </div>
  );
}

export function ServerErrorDetail({ id, onClose }: { id: number; onClose: () => void }) {
  const { data: x, error, loading, reload } = useAsync(() => api.getServerError(id), [id]);
  return (
    <aside className="detail" aria-label="Sunucu hatası detayı">
      <header className="detail-head">
        <h2>Sunucu hatası</h2>
        <button className="btn btn-ghost" onClick={onClose}>
          Kapat
        </button>
      </header>
      {loading && !x && <Loading />}
      {error && <ErrorBox message={error} onRetry={reload} />}
      {x && <ServerErrorBody x={x} />}
    </aside>
  );
}

function ServerErrorBody({ x }: { x: ServerError }) {
  return (
    <div className="detail-body">
      <div className="detail-title">
        <span className="level level-error">Sunucu</span>
        <time>{fmtDateTime(x.occurredAt)}</time>
      </div>
      <p className="detail-msg">{x.exceptionMessage}</p>
      <nav className="detail-actions">
        {x.operationId && (
          <a className="btn" href={href('/logs', { op: String(x.operationId), range: '7d' })}>
            Kiosk kayıtları
          </a>
        )}
        <Copy text={JSON.stringify(x, null, 2)} label="JSON kopyala" />
      </nav>
      <dl className="facts">
        <dt>İstek</dt>
        <dd>
          <code>
            {x.httpMethod} {x.requestPath}
          </code>
        </dd>
        <dt>Servis</dt>
        <dd>
          {x.service} · {x.action}
        </dd>
        <dt>Hata tipi</dt>
        <dd>
          <code>{x.exceptionType}</code>
        </dd>
        <dt>İşlem</dt>
        <dd>{x.operationId ?? '—'}</dd>
        <dt>Kullanıcı</dt>
        <dd>{x.userId ?? '—'}</dd>
        <dt>İstasyon</dt>
        <dd>{x.stationId ?? '—'}</dd>
      </dl>
      {x.parameters !== undefined && (
        <section className="detail-section">
          <h3>Parametreler</h3>
          <JsonView value={x.parameters} />
        </section>
      )}
      {x.exceptionDetails && (
        <section className="detail-section">
          <h3>Stack trace</h3>
          <pre className="stack">{x.exceptionDetails}</pre>
        </section>
      )}
      {x.user !== undefined && x.user !== null && (
        <section className="detail-section">
          <h3>Kullanıcı kaydı</h3>
          <JsonView value={x.user} />
        </section>
      )}
      {x.station !== undefined && x.station !== null && (
        <section className="detail-section">
          <h3>İstasyon kaydı</h3>
          <JsonView value={x.station} />
        </section>
      )}
    </div>
  );
}
