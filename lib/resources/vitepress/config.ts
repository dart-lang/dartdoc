import { defineConfig } from 'vitepress'
import { apiSidebar } from './generated/api-sidebar'
import { guideSidebar } from './generated/guide-sidebar'

export default defineConfig({
  title: '{{packageName}} API',
  description: 'API documentation for {{packageName}}',
  // Cross-references to SDK types (dart:core, dart:collection) produce
  // dead links since we only generate docs for this package.
  ignoreDeadLinks: true,
  themeConfig: {
    // Full-text search powered by MiniSearch (built into VitePress).
    search: {
      provider: 'local',
    },
    // Navigation bar links.
    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'API Reference', link: '/api/' },
    ],
    sidebar: {
      ...apiSidebar,
      ...guideSidebar,
    },
    socialLinks: {{socialLinks}},
  },
})
