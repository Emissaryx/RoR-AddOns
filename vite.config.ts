import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  base: '/addons/',
  resolve: {
    tsconfigPaths: true,
  },
  plugins: [react()],
  server: {
    allowedHosts: ['terminal.local'],
    host: '0.0.0.0',
    port: 3000,
  },
  build: {
    outDir: './build',
  },
});
