// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Dark mode toggle functionality with system preference detection
document.addEventListener('DOMContentLoaded', function() {
  const darkModeToggle = document.getElementById('dark-mode-toggle');
  const html = document.documentElement;
  
  // Check for saved user preference, fallback to system preference, default to light
  function getInitialTheme() {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      return savedTheme;
    }
    
    // Check system preference if no saved preference
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    
    return 'light';
  }
  
  const currentTheme = getInitialTheme();
  html.classList.toggle('dark', currentTheme === 'dark');
  
  if (darkModeToggle) {
    darkModeToggle.addEventListener('click', function() {
      html.classList.toggle('dark');
      const theme = html.classList.contains('dark') ? 'dark' : 'light';
      localStorage.setItem('theme', theme);
    });
  }
  
  // Listen for system preference changes (optional enhancement)
  if (window.matchMedia) {
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
      // Only apply system preference if user hasn't manually set a preference
      if (!localStorage.getItem('theme')) {
        html.classList.toggle('dark', e.matches);
      }
    });
  }
});

// Handle Turbo navigation
document.addEventListener('turbo:load', function() {
  const html = document.documentElement;
  
  // Check for saved user preference, fallback to system preference, default to light
  function getThemeForTurboLoad() {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      return savedTheme;
    }
    
    // Check system preference if no saved preference
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    
    return 'light';
  }
  
  const currentTheme = getThemeForTurboLoad();
  html.classList.toggle('dark', currentTheme === 'dark');
});
