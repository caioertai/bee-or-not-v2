import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.applyTheme()
    this.setupSystemPreferenceListener()
  }

  toggle() {
    document.documentElement.classList.toggle('dark')
    const theme = document.documentElement.classList.contains('dark') ? 'dark' : 'light'
    localStorage.setItem('theme', theme)
  }

  applyTheme() {
    const currentTheme = this.getInitialTheme()
    document.documentElement.classList.toggle('dark', currentTheme === 'dark')
  }

  getInitialTheme() {
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
      return savedTheme
    }
    
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark'
    }
    
    return 'light'
  }

  setupSystemPreferenceListener() {
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        if (!localStorage.getItem('theme')) {
          document.documentElement.classList.toggle('dark', e.matches)
        }
      })
    }
  }
}