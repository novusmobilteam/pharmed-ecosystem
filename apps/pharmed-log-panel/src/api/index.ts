import { HttpLogApi } from './http';
import { MockLogApi } from './mock';
import type { LogApi } from './types';

export * from './types';

/**
 * VITE_API_BASE_URL verilirse gerçek backend (bkz. API sözleşmesi), verilmezse
 * sahte veri. Token şimdilik localStorage'dan okunur; panelin kendi giriş
 * ekranı backend'deki yetki modeli netleşince eklenecek.
 */
function createApi(): LogApi {
  const base = import.meta.env.VITE_API_BASE_URL as string | undefined;
  if (base) {
    return new HttpLogApi(base, () => {
      try {
        return localStorage.getItem('pharmed-log-panel:token');
      } catch {
        return null;
      }
    });
  }
  return new MockLogApi();
}

export const api: LogApi = createApi();
