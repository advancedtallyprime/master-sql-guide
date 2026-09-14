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
  enhanceApp({ app, router }) {
    app.component('DocFooter', DocFooter)
    if (typeof window !== 'undefined') {
      const setMainRole = () => {
        const vpContent = document.getElementById('VPContent')
        if (vpContent && !vpContent.getAttribute('role')) {
          vpContent.setAttribute('role', 'main')
        }
      }
      if (router) {
        router.onAfterRouteChanged = () => setTimeout(setMainRole, 50)
      }
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', setMainRole)
      } else {
        setMainRole()
      }

      // Close mobile drawer when clicking the dimmed backdrop outside the sheet container
      document.addEventListener('click', (e) => {
        const screen = document.getElementById('VPNavScreen')
        if (screen && screen.contains(e.target as Node)) {
          const container = screen.querySelector('.container')
          if (container && !container.contains(e.target as Node)) {
            const hamburger = document.querySelector('.VPNavBarHamburger.active') as HTMLElement | null
            if (hamburger) {
              hamburger.click()
            }
          }
        }
      })
    }
  }
}
