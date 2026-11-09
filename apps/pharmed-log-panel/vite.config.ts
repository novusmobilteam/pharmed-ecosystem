import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// base: './' — derlenmiş panel herhangi bir alt klasörden (ör. IIS sanal dizini) sunulabilsin.
export default defineConfig({
  plugins: [react()],
  base: './',
});
