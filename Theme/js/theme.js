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
               element.classList.add('kw-in', 'kw-in-initial');
               return;
            }
            element.setAttribute('data-kw-reveal', '');
            element.style.setProperty('--kw-delay', (index * 0.08) + 's');
            observer.observe(element);
         });
      });

      kitwayRoute();

      // The hero's breathing fox pause while the hero is off screen.
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

// The paw trail: a route through the page's stops ([data-kw-stop]) with paw prints along it.
// The prints appear as the page scrolls and the fox's head walks to the last one, like the paw
// trail on the app's map. Under Reduce Motion the whole trail shows at once and the head stays away.
function kitwayRoute() {
   const map = document.querySelector('.kw-map');
   const svg = map && map.querySelector('.kw-route');
   if (!map || !svg) return;
   const ns = 'http://www.w3.org/2000/svg';
   const still = window.matchMedia('(prefers-reduced-motion: reduce)');
   const step = 30;
   let paws = [];
   let head = null;
   let pending = false;

   // The box of an element inside the map, from the offset chain: the layout position, without the
   // reveal and hover transforms that getBoundingClientRect would include.
   function layoutBox(element) {
      let left = 0, top = 0, node = element;
      while (node && node !== map) {
         left += node.offsetLeft;
         top += node.offsetTop;
         node = node.offsetParent;
      }
      return { left: left, top: top, width: element.offsetWidth, height: element.offsetHeight };
   }

   function stopPoint(element) {
      const kind = element.getAttribute('data-kw-stop');
      const target = kind === 'feature' ? (element.querySelector('img') || element) : element;
      const box = layoutBox(target);
      // `lane`: where the route may run sideways before this stop, the gap just above its card.
      const lane = layoutBox(element).top - 20;
      const x = box.left + box.width / 2;
      if (kind === 'start') {
         // On a phone the hero is centred: the route leaves along the screen's edge, clear of the text.
         const startX = window.innerWidth < 860 ? 14 : box.left + 24;
         return { x: startX, y: box.top + box.height + 18, lane: lane };
      }
      if (kind === 'feature' || kind === 'finish') return { x: x, y: box.top + box.height / 2, lane: lane };
      return { x: x, y: box.top, lane: lane };
   }

   // A smooth curve through the points (Catmull-Rom turned into cubic Béziers).
   function curve(points) {
      let d = 'M' + points[0].x + ' ' + points[0].y;
      for (let i = 0; i < points.length - 1; i++) {
         const p0 = points[i - 1] || points[i], p1 = points[i], p2 = points[i + 1], p3 = points[i + 2] || p2;
         d += ' C' + (p1.x + (p2.x - p0.x) / 6) + ' ' + (p1.y + (p2.y - p0.y) / 6) + ' ' +
            (p2.x - (p3.x - p1.x) / 6) + ' ' + (p2.y - (p3.y - p1.y) / 6) + ' ' + p2.x + ' ' + p2.y;
      }
      return d;
   }

   function pawShape() {
      const g = document.createElementNS(ns, 'g');
      g.setAttribute('class', 'kw-paw');
      [[0, 3, 4.2, 3.6], [-4.6, -2.6, 1.7, 2], [-1.6, -5.2, 1.7, 2], [1.6, -5.2, 1.7, 2], [4.6, -2.6, 1.7, 2]]
         .forEach(function(e) {
            const ellipse = document.createElementNS(ns, 'ellipse');
            ellipse.setAttribute('cx', e[0]); ellipse.setAttribute('cy', e[1]);
            ellipse.setAttribute('rx', e[2]); ellipse.setAttribute('ry', e[3]);
            g.appendChild(ellipse);
         });
      return g;
   }

   function build() {
      const raw = Array.prototype.map.call(map.querySelectorAll('[data-kw-stop]'), stopPoint);
      // Between stops in different columns the route turns in the gap just above the next stop's
      // card, so it does not cut across text: down from one stop, across in the gap, into the next.
      const stops = [];
      raw.forEach(function(point, i) {
         const previous = raw[i - 1];
         if (previous && Math.abs(point.x - previous.x) > 60 && point.lane - previous.y > 40) {
            stops.push({ x: previous.x, y: point.lane }, { x: point.x, y: point.lane });
         }
         stops.push(point);
      });
      svg.textContent = '';
      paws = [];
      svg.setAttribute('width', map.scrollWidth);
      svg.setAttribute('height', map.scrollHeight);
      if (stops.length < 2) return;
      const path = document.createElementNS(ns, 'path');
      path.setAttribute('d', curve(stops));
      path.setAttribute('class', 'kw-route-guide');
      svg.appendChild(path);
      const length = path.getTotalLength();
      for (let s = step, side = 1; s < length - step / 2; s += step, side = -side) {
         const a = path.getPointAtLength(s), b = path.getPointAtLength(Math.min(s + 1, length));
         const angle = Math.atan2(b.y - a.y, b.x - a.x);
         const x = a.x + Math.cos(angle + Math.PI / 2) * 6 * side;
         const y = a.y + Math.sin(angle + Math.PI / 2) * 6 * side;
         const paw = pawShape();
         paw.setAttribute('transform', 'translate(' + x.toFixed(1) + ' ' + y.toFixed(1) + ') rotate(' +
            (angle * 180 / Math.PI + 90).toFixed(1) + ')');
         svg.appendChild(paw);
         paws.push({ node: paw, x: a.x, y: a.y, on: false });
      }
      if (!head) {
         head = document.createElement('img');
         head.className = 'kw-route-head';
         head.src = '/assets/images/kitway-head.png';
         head.alt = '';
         head.setAttribute('aria-hidden', 'true');
         map.appendChild(head);
      }
      update();
   }

   function update() {
      pending = false;
      const all = still.matches;
      const reach = all ? Infinity : window.innerHeight * 0.62 - map.getBoundingClientRect().top;
      let last = null;
      paws.forEach(function(paw) {
         const on = paw.y <= reach;
         if (on !== paw.on) {
            paw.node.classList.toggle('kw-on', on);
            paw.on = on;
         }
         if (on) last = paw;
      });
      if (!head) return;
      const show = !all && last !== null;
      head.classList.toggle('kw-on', show);
      if (show) head.style.transform = 'translate(' + last.x.toFixed(1) + 'px, ' + last.y.toFixed(1) + 'px)';
   }

   function schedule() {
      if (pending) return;
      pending = true;
      window.requestAnimationFrame(update);
   }

   let resizeTimer = 0;
   let lastWidth = window.innerWidth;
   function rebuildSoon() {
      window.clearTimeout(resizeTimer);
      resizeTimer = window.setTimeout(build, 150);
   }
   window.addEventListener('scroll', schedule, { passive: true });
   // iOS resizes the height while the address bar slides; only a new width changes the layout.
   window.addEventListener('resize', function() {
      if (window.innerWidth === lastWidth) return;
      lastWidth = window.innerWidth;
      rebuildSoon();
   });
   // Opening an FAQ answer moves everything below it, the finish included.
   map.addEventListener('toggle', rebuildSoon, true);
   still.addEventListener('change', build);
   // Images and the reveal transforms change the layout: build again once they settle.
   window.addEventListener('load', function() { window.setTimeout(build, 900); });
   build();
}
