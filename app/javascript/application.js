// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Dark mode toggle functionality
document.addEventListener('DOMContentLoaded', function() {
  const darkModeToggle = document.getElementById('dark-mode-toggle');
  const html = document.documentElement;
  
  // Check for saved user preference or default to light mode
  const currentTheme = localStorage.getItem('theme') || 'light';
  html.classList.toggle('dark', currentTheme === 'dark');
  
  if (darkModeToggle) {
    darkModeToggle.addEventListener('click', function() {
      html.classList.toggle('dark');
      const theme = html.classList.contains('dark') ? 'dark' : 'light';
      localStorage.setItem('theme', theme);
    });
  }
});

// Handle Turbo navigation
document.addEventListener('turbo:load', function() {
  const html = document.documentElement;
  const currentTheme = localStorage.getItem('theme') || 'light';
  html.classList.toggle('dark', currentTheme === 'dark');
});
