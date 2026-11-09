import { api, type LogEntry } from '../api';
import { LogDetail } from '../components/LogDetail';
import { LogTable } from '../components/LogTable';
import { Empty, ErrorBox, Loading } from '../components/ui';
import { fmtDateTime, fmtMs } from '../format';
import { useAsync } from '../hooks';
import { useDeviceName } from '../lookups';
import { href, updateParams, type Route } from '../router';

/** Bir isteğin (appRunId + req) tüm kayıtları, aralarındaki sürelerle. */
export function Trace({ route }: { route: Route }) {
  const appRunId = route.params.get('appRunId') ?? '';
  const req = route.params.get('req') ?? '';
  const anchor = route.params.get('from') ?? undefined;
  const selected = route.params.get('sel') ?? undefined;
  const trace = useAsync(() => api.trace(appRunId, req), [appRunId, req]);
  const deviceName = useDeviceName();
  const items = trace.data ?? [];
  const first = items[0];

  return (
    <div className={`with-detail${selected ? ' has-detail' : ''}`}>
      <div className="with-detail-main">
        <a className="back" href="javascript:history.back()">
          Geri
        </a>
        <header className="page-head">
          <h1>
            İstek izi <code className="chip">{req}</code>
          </h1>
          {anchor && (
            <div className="page-tools">
              <a className="btn" href={href('/around', { id: anchor })}>
                Kioskta öncesi / sonrası
              </a>
            </div>
          )}
        </header>
        {first && (
          <p className="lead">
            {deviceName(first.deviceId)} · {first.session?.user ?? 'oturum yok'} · {first.session?.screen ?? '—'} · {fmtDateTime(first.timestamp)}
          </p>
        )}
        {trace.error && <ErrorBox message={trace.error} onRetry={trace.reload} />}
        {trace.loading && !trace.data && <Loading />}
        {trace.data && !items.length && <Empty title="Bu isteğe ait kayıt bulunamadı." hint="Kayıtlar saklama süresini aşmış olabilir." />}
        {items.length > 0 && (
          <ol className="steps">
            {items.map((e, i) => (
              <Step key={e.id} e={e} prev={items[i - 1]} selected={selected === e.id} onSelect={() => updateParams(route, { sel: e.id })} />
            ))}
          </ol>
        )}
      </div>
      {selected && <LogDetail id={selected} onClose={() => updateParams(route, { sel: undefined })} />}
    </div>
  );
}

function Step({ e, prev, selected, onSelect }: { e: LogEntry; prev?: LogEntry; selected: boolean; onSelect: () => void }) {
  const gap = prev ? Date.parse(e.timestamp) - Date.parse(prev.timestamp) : undefined;
  return (
    <li className={`step step-${e.level.toLowerCase()}${selected ? ' is-selected' : ''}`}>
      {gap !== undefined && <span className="step-gap">+{fmtMs(gap)}</span>}
      <button onClick={onSelect}>
        <span className="step-msg">{e.message}</span>
        {e.http?.status !== undefined && <code className="chip chip-muted">{e.http.status}</code>}
        {e.rule && <code className="chip">{e.rule}</code>}
      </button>
    </li>
  );
}

/** Bir kaydın aynı kiosk ve uygulama çalışmasındaki öncesi/sonrası. */
export function Around({ route }: { route: Route }) {
  const id = route.params.get('id') ?? '';
  const selected = route.params.get('sel') ?? undefined;
  const around = useAsync(() => api.surrounding(id, 40, 40), [id]);
  const deviceName = useDeviceName();
  const anchor = around.data?.find((e) => e.id === id);

  return (
    <div className={`with-detail${selected ? ' has-detail' : ''}`}>
      <div className="with-detail-main">
        <a className="back" href="javascript:history.back()">
          Geri
        </a>
        <header className="page-head">
          <h1>Kioskta öncesi / sonrası</h1>
        </header>
        {anchor && (
          <p className="lead">
            {deviceName(anchor.deviceId)} · aynı uygulama çalışmasında, işaretli kaydın 40 öncesi ve 40 sonrası. Başarılı okuma istekleri kaydedilmediği için yalnızca kalıcı kayıtlar görünür; okuma adımları hata kayıtlarının “Önceki adımlar” bölümündedir.
          </p>
        )}
        {around.error && <ErrorBox message={around.error} onRetry={around.reload} />}
        {around.loading && !around.data && <Loading />}
        {around.data && (
          <LogTable compact items={around.data} highlightId={id} selectedId={selected} onSelect={(e) => updateParams(route, { sel: e.id })} />
        )}
      </div>
      {selected && <LogDetail id={selected} onClose={() => updateParams(route, { sel: undefined })} />}
    </div>
  );
}
