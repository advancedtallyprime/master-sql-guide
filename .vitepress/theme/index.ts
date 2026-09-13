import DefaultTheme from 'vitepress/theme'
import { h } from 'vue'
import './style.css'
import DocFooter from './components/DocFooter.vue'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'doc-footer-before': () => h(DocFooter)
    })
  },
  enhanceApp({ app }) {
    app.component('DocFooter', DocFooter)
  }
}
