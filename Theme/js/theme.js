// The site stores two choices in this browser only, never sends them anywhere:
// `theme` (light or dark) and `preferredLang` (read by SiteKit's language redirect).
function kitwayStore(key, value) {
   try { localStorage.setItem(key, value); } catch (e) { /* storage blocked: the choice lasts for this page */ }
}

document.addEventListener('DOMContentLoaded', function() {
   // Scroll reveal: mark the pieces of each section; each one rises in when it enters the screen.
   // Siblings in one group come in one after another (--kw-delay). Without IntersectionObserver the
   // head script does not add .kw-js, so nothing is hidden.
   if (document.documentElement.classList.contains('kw-js')) {
      const groups = [
         '.kw-section .landing-section-title',
         '.kw-section .kw-section-subtitle',
         '.kw-trio-grid > li',
         '.kw-feature-list > li',
         '.kw-tier-grid > .kw-tier',
         '.kw-pricing-note',
         '.landing-faq-item',
         '.kw-cta .kw-hero-actions'
      ];
      // After its reveal a piece drops its stagger delay, so a hover settles back at once.
      function reveal(element) {
         element.classList.add('kw-in');
         window.setTimeout(function() { element.style.removeProperty('--kw-delay'); }, 1200);
      }
      const observer = new IntersectionObserver(function(entries) {
         entries.forEach(function(entry) {
            if (!entry.isIntersecting) return;
            reveal(entry.target);
            observer.unobserve(entry.target);
         });
      }, { rootMargin: '0px 0px -8% 0px', threshold: 0.12 });
      // A piece the first paint already showed stays shown: hiding it now would make it blink.
      const viewportHeight = window.innerHeight || document.documentElement.clientHeight;
      groups.forEach(function(selector) {
         document.querySelectorAll(selector).forEach(function(element) {
            const siblings = Array.prototype.filter.call(element.parentElement.children, function(child) {
               return child.matches(selector);
            });
            const index = Math.min(siblings.indexOf(element), 5);
            const box = element.getBoundingClientRect();
            if (box.top < viewportHeight && box.bottom > 0) {
               element.setAttribute('data-kw-reveal', '');
               element.classList.add('kw-in');
               return;
            }
            element.setAttribute('data-kw-reveal', '');
            element.style.setProperty('--kw-delay', (index * 0.08) + 's');
            observer.observe(element);
         });
      });

      // The hero's breathing fox and drifting glow pause while the hero is off screen.
      const hero = document.querySelector('.kw-hero');
      if (hero) {
         new IntersectionObserver(function(entries) {
            hero.classList.toggle('kw-hero-away', !entries[0].isIntersecting);
         }).observe(hero);
      }
   }

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
