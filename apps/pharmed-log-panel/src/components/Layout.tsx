import type { ReactNode } from 'react';
import { api } from '../api';
import { RANGES, rangeOf } from '../format';
import { href, updateParams, type Route } from '../router';

const NAV = [
  { path: '/', label: 'Genel bakış' },
  { path: '/issues', label: 'Sorunlar' },
  { path: '/logs', label: 'Loglar' },
  { path: '/devices', label: 'Kiosklar' },
];

function isActive(current: string, path: string) {
  if (path === '/') return current === '/';
  return current === path || current.startsWith(`${path}/`);
}

export function Layout({ route, children }: { route: Route; children: ReactNode }) {
  const range = route.params.get('range');
  return (
    <div className="app">
      <nav className="side" aria-label="Ana menü">
        <a className="brand" href="#/">
          <span className="brand-mark" aria-hidden />
          <span>
            PharMed
            <small>Log paneli</small>
          </span>
        </a>
        <ul>
          {NAV.map((n) => (
            <li key={n.path}>
              <a className={isActive(route.path, n.path) ? 'is-active' : ''} href={href(n.path, range ? { range } : undefined)}>
                {n.label}
              </a>
            </li>
          ))}
        </ul>
        <div className="side-foot">
          {api.isMock ? (
            <p>
              <strong>Sahte veri.</strong> Backend hazır olunca <code>VITE_API_BASE_URL</code> ile gerçek loglara bağlanır.
            </p>
          ) : (
            <p>
              <strong>Canlı veri</strong> — {import.meta.env.VITE_API_BASE_URL}
            </p>
          )}
        </div>
      </nav>
      <main className="main">{children}</main>
    </div>
  );
}

export function PageHead({ title, route, showRange = true, children }: { title: ReactNode; route: Route; showRange?: boolean; children?: ReactNode }) {
  const current = rangeOf(route.params.get('range')).key;
  return (
    <header className="page-head">
      <h1>{title}</h1>
      <div className="page-tools">
        {children}
        {showRange && (
          <div className="seg" role="group" aria-label="Zaman aralığı">
            {RANGES.map((r) => (
              <button key={r.key} className={r.key === current ? 'is-on' : ''} onClick={() => updateParams(route, { range: r.key })}>
                {r.label.replace('Son ', '')}
              </button>
            ))}
          </div>
        )}
      </div>
    </header>
  );
}
