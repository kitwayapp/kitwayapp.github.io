// The site stores two choices in this browser only, never sends them anywhere:
// `theme` (light or dark) and `preferredLang` (read by SiteKit's language redirect).
function kitwayStore(key, value) {
   try { localStorage.setItem(key, value); } catch (e) { /* storage blocked: the choice lasts for this page */ }
}

document.addEventListener('DOMContentLoaded', function() {
   // Dark mode toggle
   const toggle = document.querySelector('.sk-theme-toggle');
   if (toggle) {
      const label = document.documentElement.lang === 'uk' ? 'Світла або темна тема' : 'Light or dark theme';
      toggle.setAttribute('aria-label', label);
      toggle.addEventListener('click', function() {
         const current = document.documentElement.getAttribute('data-theme');
         const next = current === 'dark' ? 'light' : 'dark';
         document.documentElement.setAttribute('data-theme', next);
         kitwayStore('theme', next);
      });
   }

   // Language menu: one item per hreflang alternate of this page.
   const picker = document.querySelector('.sk-lang-picker');
   const langButton = picker && picker.querySelector('.sk-lang-btn');
   const menu = picker && picker.querySelector('.sk-lang-menu');
   if (picker && langButton && menu) {
      const names = { en: 'English', uk: 'Українська' };
      const current = document.documentElement.lang;
      document.querySelectorAll('link[rel="alternate"][hreflang]').forEach(function(link) {
         const lang = link.getAttribute('hreflang');
         if (!names[lang]) return;
         const item = document.createElement('a');
         item.setAttribute('role', 'menuitem');
         item.className = 'sk-lang-option';
         item.setAttribute('lang', lang);
         item.href = new URL(link.href).pathname + location.hash;
         item.textContent = names[lang];
         if (lang === current) {
            item.setAttribute('aria-current', 'true');
            item.classList.add('sk-lang-active');
         }
         item.addEventListener('click', function() { kitwayStore('preferredLang', lang); });
         menu.appendChild(item);
      });
      langButton.setAttribute('aria-haspopup', 'true');
      langButton.setAttribute('aria-expanded', 'false');
      function setOpen(open) {
         picker.classList.toggle('sk-lang-open', open);
         langButton.setAttribute('aria-expanded', open ? 'true' : 'false');
      }
      langButton.addEventListener('click', function(event) {
         event.stopPropagation();
         setOpen(!picker.classList.contains('sk-lang-open'));
      });
      document.addEventListener('click', function() { setOpen(false); });
      document.addEventListener('keydown', function(event) {
         if (event.key === 'Escape' && picker.classList.contains('sk-lang-open')) {
            setOpen(false);
            langButton.focus();
         }
      });
   }
});
