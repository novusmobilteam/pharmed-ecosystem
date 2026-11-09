import type { ReactNode } from 'react';
import type { GroupStatus, Level } from '../api';

const LEVEL_LABEL: Record<Level, string> = { ERROR: 'Hata', WARN: 'Uyarı', INFO: 'Bilgi' };

export function LevelTag({ level }: { level: Level }) {
  return <span className={`level level-${level.toLowerCase()}`}>{LEVEL_LABEL[level]}</span>;
}

export const levelLabel = (l: Level) => LEVEL_LABEL[l];

const STATUS_LABEL: Record<GroupStatus, string> = { open: 'Açık', resolved: 'Çözüldü', ignored: 'Yok sayıldı' };
export const statusLabel = (s: GroupStatus) => STATUS_LABEL[s];

export function StatusTag({ status, regressed }: { status: GroupStatus; regressed?: boolean }) {
  if (regressed) return <span className="status status-regressed">Geri döndü</span>;
  return <span className={`status status-${status}`}>{STATUS_LABEL[status]}</span>;
}

export function Panel({ title, action, children, className }: { title?: ReactNode; action?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={`panel ${className ?? ''}`}>
      {(title || action) && (
        <header className="panel-head">
          {title && <h2>{title}</h2>}
          {action}
        </header>
      )}
      {children}
    </section>
  );
}

export function Loading({ label = 'Yükleniyor' }: { label?: string }) {
  return (
    <div className="state" role="status">
      <span className="spinner" aria-hidden /> {label}
    </div>
  );
}

export function ErrorBox({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="state state-error" role="alert">
      <div>
        <strong>Veri alınamadı.</strong> {message}
      </div>
      {onRetry && (
        <button className="btn" onClick={onRetry}>
          Tekrar dene
        </button>
      )}
    </div>
  );
}

export function Empty({ title, hint }: { title: string; hint?: ReactNode }) {
  return (
    <div className="state state-empty">
      <strong>{title}</strong>
      {hint && <span>{hint}</span>}
    </div>
  );
}

export function Copy({ text, label = 'Kopyala' }: { text: string; label?: string }) {
  return (
    <button
      className="btn btn-ghost btn-sm"
      onClick={(e) => {
        const btn = e.currentTarget;
        navigator.clipboard?.writeText(text).then(() => {
          btn.dataset.done = '1';
          setTimeout(() => delete btn.dataset.done, 1200);
        });
      }}
    >
      {label}
    </button>
  );
}
