import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const apiTarget = env.VITE_API_BASE_URL?.trim().replace(/\/$/, '');
  const useProxy = !!apiTarget && env.VITE_API_PROXY?.trim().toLowerCase() !== 'false';

  return {
    plugins: [react()],
    // base: './' — derlenmiş panel herhangi bir alt klasörden (ör. IIS sanal dizini) sunulabilsin.
    base: './',
    // `npm run dev` sırasında panel istekleri kendi adresine (/api/...) gönderir, Vite bunları
    // backend'e iletir. Aynı kaynak olduğu için tarayıcı CORS preflight (OPTIONS) göndermez.
    // Build/preview bu bloğu kullanmaz; yayınlanan panel için backend'de CORS gerekir.
    server: useProxy
      ? {
          proxy: {
            '/api': {
              target: apiTarget,
              changeOrigin: true,
              secure: true,
              configure: (proxy) => {
                proxy.on('proxyReq', (req) => req.removeHeader('origin'));
              },
            },
          },
        }
      : undefined,
  };
});
