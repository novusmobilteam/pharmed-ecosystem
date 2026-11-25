import { HttpLogApi } from './http';
import { MockLogApi } from './mock';
import type { LogApi } from './types';

export * from './types';

/** Backend adresi (ör. https://agena.novusyazilim.com). Verilmezse panel sahte veriyle çalışır. */
export const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim() || undefined;

/**
 * İsteklerin gideceği kök. `npm run dev` sırasında Vite proxy açıkken (varsayılan) istekler
 * panelin kendi adresine gider ve Vite bunları API_BASE_URL'e iletir (bkz. vite.config.ts).
 * `VITE_API_PROXY=false` ile kapatılır. Build/preview'de doğrudan API_BASE_URL kullanılır.
 */
export const API_REQUEST_BASE: string | undefined =
  API_BASE_URL && import.meta.env.DEV && import.meta.env.VITE_API_PROXY?.trim().toLowerCase() !== 'false'
    ? window.location.origin
    : API_BASE_URL;

export const api: LogApi = API_REQUEST_BASE ? new HttpLogApi(API_REQUEST_BASE) : new MockLogApi();
