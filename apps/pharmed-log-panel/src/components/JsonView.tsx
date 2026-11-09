// Bağlam/oturum için okunur JSON. İç içe JSON metinleri (istek gövdesi, servis
// yanıtı) açılarak gösterilir — logda string olarak saklanıyorlar.

function tryParse(v: unknown): unknown {
  if (typeof v !== 'string') return v;
  const t = v.trim();
  if (!(t.startsWith('{') || t.startsWith('['))) return v;
  try {
    return JSON.parse(t);
  } catch {
    return v;
  }
}

function Value({ value, depth }: { value: unknown; depth: number }) {
  const v = tryParse(value);
  if (v === null) return <span className="j-null">null</span>;
  if (typeof v === 'string') return <span className="j-str">"{v}"</span>;
  if (typeof v === 'number') return <span className="j-num">{v}</span>;
  if (typeof v === 'boolean') return <span className="j-bool">{String(v)}</span>;
  if (Array.isArray(v)) {
    if (!v.length) return <span>[]</span>;
    const simple = v.every((x) => typeof x !== 'object' || x === null);
    if (simple && v.length <= 8) {
      return (
        <span>
          [
          {v.map((x, i) => (
            <span key={i}>
              {i > 0 && ', '}
              <Value value={x} depth={depth + 1} />
            </span>
          ))}
          ]
        </span>
      );
    }
    return (
      <div className="j-block">
        {v.map((x, i) => (
          <div key={i} className="j-row">
            <span className="j-key">{i}</span>
            <Value value={x} depth={depth + 1} />
          </div>
        ))}
      </div>
    );
  }
  if (typeof v === 'object') {
    const entries = Object.entries(v as Record<string, unknown>);
    if (!entries.length) return <span>{'{}'}</span>;
    return (
      <div className={depth ? 'j-block' : ''}>
        {entries.map(([k, x]) => (
          <div key={k} className="j-row">
            <span className="j-key">{k}</span>
            <Value value={x} depth={depth + 1} />
          </div>
        ))}
      </div>
    );
  }
  return <span>{String(v)}</span>;
}

export function JsonView({ value }: { value: unknown }) {
  return (
    <div className="json">
      <Value value={value} depth={0} />
    </div>
  );
}
