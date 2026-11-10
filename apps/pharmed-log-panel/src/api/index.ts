import { HttpLogApi } from './http';
import { MockLogApi } from './mock';
import type { LogApi } from './types';

export * from './types';

/** Backend adresi (ör. https://agena.novusyazilim.com). Verilmezse panel sahte veriyle çalışır. */
export const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim() || undefined;

export const api: LogApi = API_BASE_URL ? new HttpLogApi(API_BASE_URL) : new MockLogApi();
