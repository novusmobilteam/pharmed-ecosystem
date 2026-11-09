import { useState } from 'react';
import type { Bucket, Level } from '../api';
import { fmtCount, fmtShort } from '../format';

const ORDER: Level[] = ['ERROR', 'WARN', 'INFO'];

/** Seviyelere göre yığılmış sütunlar. Hata alta, bilgi üste — hatalar hep aynı tabandan okunur. */
export function StackedBars({
  buckets,
  height = 120,
  levels = ORDER,
  onSelect,
}: {
  buckets: Bucket[];
  height?: number;
  levels?: Level[];
  onSelect?: (b: Bucket) => void;
}) {
  const [hover, setHover] = useState<number | null>(null);
  const total = (b: Bucket) => levels.reduce((s, l) => s + b.counts[l], 0);
  const max = Math.max(1, ...buckets.map(total));
  const w = 100 / Math.max(1, buckets.length);
  const hb = hover !== null ? buckets[hover] : undefined;

  return (
    <div className="bars" style={{ height }}>
      <svg viewBox={`0 0 100 ${height}`} preserveAspectRatio="none" role="img" aria-label="Zamana göre kayıt sayısı">
        {buckets.map((b, i) => {
          let y = height;
          return (
            <g key={b.t} onMouseEnter={() => setHover(i)} onMouseLeave={() => setHover(null)} onClick={() => onSelect?.(b)}>
              <rect x={i * w} y={0} width={w} height={height} className="bar-hit" />
              {levels.map((l) => {
                const h = (b.counts[l] / max) * (height - 6);
                y -= h;
                return h > 0 ? (
                  <rect key={l} x={i * w + w * 0.12} y={y} width={w * 0.76} height={h} className={`bar bar-${l.toLowerCase()}${hover === i ? ' is-hover' : ''}`} />
                ) : null;
              })}
            </g>
          );
        })}
      </svg>
      <div className="bars-axis">
        <span>{fmtShort(buckets[0]?.t)}</span>
        <span>{fmtShort(buckets[buckets.length - 1]?.t)}</span>
      </div>
      {hb && (
        <div className="bars-tip" style={{ left: `${Math.min(80, Math.max(0, hover! * w))}%` }}>
          <strong>{fmtShort(hb.t)}</strong>
          {levels.map((l) => (
            <span key={l} className={`tip-${l.toLowerCase()}`}>
              {l === 'ERROR' ? 'Hata' : l === 'WARN' ? 'Uyarı' : 'Bilgi'} {fmtCount(hb.counts[l])}
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

export function Sparkline({ values, width = 96, height = 24 }: { values: number[]; width?: number; height?: number }) {
  const max = Math.max(1, ...values);
  const step = width / Math.max(1, values.length);
  return (
    <svg width={width} height={height} className="spark" aria-hidden>
      {values.map((v, i) => {
        const h = v ? Math.max(2, (v / max) * height) : 0;
        return <rect key={i} x={i * step + 0.5} y={height - h} width={Math.max(1, step - 1)} height={h} />;
      })}
    </svg>
  );
}

/** Yatay oranlı liste: anahtar + sayı + oran çubuğu. */
export function BarList({ items, onPick }: { items: { key: string; label: string; count: number; hint?: string }[]; onPick?: (key: string) => void }) {
  const max = Math.max(1, ...items.map((i) => i.count));
  return (
    <ul className="barlist">
      {items.map((i) => (
        <li key={i.key}>
          <button onClick={() => onPick?.(i.key)} disabled={!onPick}>
            <span className="barlist-fill" style={{ width: `${(i.count / max) * 100}%` }} />
            <span className="barlist-label">
              {i.label}
              {i.hint && <small>{i.hint}</small>}
            </span>
            <span className="barlist-count">{fmtCount(i.count)}</span>
          </button>
        </li>
      ))}
    </ul>
  );
}
