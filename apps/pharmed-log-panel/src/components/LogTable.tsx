import type { LogEntry } from '../api';
import { fmtMillis, fmtShort, fmtTime } from '../format';
import { useDeviceName } from '../lookups';
import { LevelTag } from './ui';

function isToday(iso: string) {
  const d = new Date(iso);
  const n = new Date();
  return d.toDateString() === n.toDateString();
}

export function LogTable({
  items,
  selectedId,
  onSelect,
  highlightId,
  freshIds,
  compact,
}: {
  items: LogEntry[];
  selectedId?: string;
  onSelect: (e: LogEntry) => void;
  highlightId?: string;
  freshIds?: Set<string>;
  compact?: boolean;
}) {
  const deviceName = useDeviceName();
  return (
    <div className={`logtable${compact ? ' logtable-compact' : ''}`} role="table" aria-label="Log kayıtları">
      <div className="logrow logrow-head" role="row">
        <span role="columnheader">Zaman</span>
        <span role="columnheader" className="logrow-level">
          Seviye
        </span>
        <span role="columnheader">Mesaj</span>
        {!compact && (
          <span role="columnheader" className="logrow-meta">
            Kiosk
          </span>
        )}
        {!compact && (
          <span role="columnheader" className="logrow-meta">
            Kullanıcı
          </span>
        )}
      </div>
      {items.map((e) => (
        <button
          key={e.id}
          role="row"
          className={`logrow logrow-${e.level.toLowerCase()}${selectedId === e.id ? ' is-selected' : ''}${highlightId === e.id ? ' is-anchor' : ''}${freshIds?.has(e.id) ? ' is-fresh' : ''}`}
          onClick={() => onSelect(e)}
        >
          <span className="logrow-time" role="cell">
            {isToday(e.timestamp) ? fmtTime(e.timestamp) : fmtShort(e.timestamp)}
            <small>.{fmtMillis(e.timestamp)}</small>
          </span>
          <span role="cell" className="logrow-level">
            <LevelTag level={e.level} />
          </span>
          <span className="logrow-msg" role="cell">
            {e.message}
            {e.rule && <code className="chip">{e.rule}</code>}
            {e.http?.status && e.http.status >= 400 && <code className="chip chip-status">{e.http.status}</code>}
            {e.req && <code className="chip chip-muted">{e.req}</code>}
          </span>
          {!compact && (
            <span className="logrow-meta" role="cell">
              {deviceName(e.deviceId)}
            </span>
          )}
          {!compact && (
            <span className="logrow-meta" role="cell">
              {e.session?.user ?? '—'}
            </span>
          )}
        </button>
      ))}
    </div>
  );
}
