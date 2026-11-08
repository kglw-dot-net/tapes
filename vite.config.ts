import { defineConfig } from 'vite'
import ViteRails from 'vite-plugin-rails'

export default defineConfig({
  server: {
    host: 'localhost',
    hmr: {
      host: 'localhost',
      port: 3036,
      clientPort: 3036,
    }
  },

  plugins: [
    ViteRails({
      fullReload: {
        additionalPaths: [
          'config/routes.rb',
          'app/views/**/*',
          'app/controllers/**/*',
          'app/models/**/*'
        ]
      }
    })
  ],
})
