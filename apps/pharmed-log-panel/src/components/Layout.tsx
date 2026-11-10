import type { ReactNode } from 'react';
import { api, API_BASE_URL } from '../api';
import { logout, useSession } from '../auth';
import { RANGES, rangeOf } from '../format';
import { href, updateParams, type Route } from '../router';

const NAV = [
  { path: '/', label: 'Genel bakış' },
  { path: '/issues', label: 'Sorunlar' },
  { path: '/logs', label: 'Loglar' },
  { path: '/devices', label: 'Kiosklar' },
  { path: '/server-errors', label: 'Sunucu hataları' },
];

function isActive(current: string, path: string) {
  if (path === '/') return current === '/';
  return current === path || current.startsWith(`${path}/`);
}

export function Layout({ route, children }: { route: Route; children: ReactNode }) {
  const range = route.params.get('range');
  const session = useSession();
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
            <>
              <p>
                <strong>Canlı veri</strong> — {API_BASE_URL?.replace(/^https?:\/\//, '')}
              </p>
              {session && (
                <p className="side-user">
                  {session.email ?? `#${session.userId}`}
                  <button className="link" onClick={logout}>
                    Çıkış
                  </button>
                </p>
              )}
            </>
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

/** Panelde hesaplanan istatistikler kayıt sınırına takıldıysa. */
export function WindowNote() {
  return (
    <p className="note">
      Son 7 günde çok fazla kayıt var; sorunlar ve grafikler yalnızca en yeni 30.000 kayıttan hesaplandı. Ayrıntılı arama için Loglar ekranını kullanın.
    </p>
  );
}
