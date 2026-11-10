import { useState } from 'react';
import { API_BASE_URL } from '../api';
import { login } from '../auth';

/** Yönetici girişi — log servisleri yalnızca aktif yöneticiye açık. */
export function Login() {
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  return (
    <div className="login">
      <form
        className="login-card"
        onSubmit={async (e) => {
          e.preventDefault();
          const f = new FormData(e.currentTarget);
          setBusy(true);
          setError(undefined);
          try {
            await login(API_BASE_URL!, String(f.get('email') ?? '').trim(), String(f.get('password') ?? ''));
          } catch (err) {
            setError(err instanceof Error ? err.message : String(err));
          } finally {
            setBusy(false);
          }
        }}
      >
        <div className="brand">
          <span className="brand-mark" aria-hidden />
          <span>
            PharMed
            <small>Log paneli</small>
          </span>
        </div>
        <p className="muted">Yönetici hesabınızla giriş yapın.</p>
        <label className="field">
          <span>Kullanıcı adı</span>
          <input name="email" autoComplete="username" required autoFocus />
        </label>
        <label className="field">
          <span>Şifre</span>
          <input name="password" type="password" autoComplete="current-password" required />
        </label>
        {error && (
          <p className="login-error" role="alert">
            {error}
          </p>
        )}
        <button className="btn btn-primary" type="submit" disabled={busy}>
          {busy ? 'Giriş yapılıyor…' : 'Giriş yap'}
        </button>
        <p className="login-server muted">{API_BASE_URL}</p>
      </form>
    </div>
  );
}
