import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "fr-theme"

// Toggles [data-theme] on <html> between "light" and "dark" and persists
// the choice in localStorage. The initial paint (before Stimulus boots)
// is handled by layouts/_theme_bootstrap.html.erb so there's no flash.
export default class extends Controller {
  connect() {
    this.render()
  }

  toggle() {
    this.setTheme(this.currentTheme() === "dark" ? "light" : "dark")
  }

  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)

    try {
      localStorage.setItem(STORAGE_KEY, theme)
    } catch (e) {}

    this.render()
  }

  currentTheme() {
    const stored = document.documentElement.getAttribute("data-theme")
    if (stored) return stored

    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  render() {
    const isDark = this.currentTheme() === "dark"
    this.element.setAttribute("aria-pressed", isDark)
    this.element.setAttribute("aria-label", isDark ? "Switch to light theme" : "Switch to dark theme")
  }
}
