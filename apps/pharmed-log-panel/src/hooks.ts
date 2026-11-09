import { useCallback, useEffect, useRef, useState } from 'react';

export interface Async<T> {
  data?: T;
  error?: string;
  loading: boolean;
  reload: () => void;
}

/** Bağımlılık değişince yeniden yükler; eski isteğin cevabı yenisini ezmez. */
export function useAsync<T>(fn: () => Promise<T>, deps: unknown[]): Async<T> {
  const [state, setState] = useState<{ data?: T; error?: string; loading: boolean }>({ loading: true });
  const seq = useRef(0);
  const [nonce, setNonce] = useState(0);

  useEffect(() => {
    const id = ++seq.current;
    setState((s) => ({ ...s, loading: true, error: undefined }));
    fn().then(
      (data) => id === seq.current && setState({ data, loading: false }),
      (e: unknown) => id === seq.current && setState((s) => ({ ...s, loading: false, error: e instanceof Error ? e.message : String(e) })),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, nonce]);

  const reload = useCallback(() => setNonce((n) => n + 1), []);
  return { ...state, reload };
}

/** Sayfa görünürken belirli aralıkla çalışır. */
export function useInterval(fn: () => void, ms: number | null) {
  const ref = useRef(fn);
  ref.current = fn;
  useEffect(() => {
    if (ms === null) return;
    const t = setInterval(() => {
      if (document.visibilityState === 'visible') ref.current();
    }, ms);
    return () => clearInterval(t);
  }, [ms]);
}

/** Saniyede bir değişen "şimdi" — göreli zamanlar tazelensin. */
export function useNow(ms = 30_000) {
  const [now, setNow] = useState(Date.now());
  useInterval(() => setNow(Date.now()), ms);
  return now;
}
