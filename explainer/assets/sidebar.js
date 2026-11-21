/* Explainer sidebar: the single source of truth for navigating between explainer pages.
 *
 * To add a page, add an entry to GROUPS below. Every page that loads this script shows it.
 *
 * Include in the <head> of each page (adjust the path to this folder):
 *   <link rel="stylesheet" href="assets/sidebar.css">
 *   <script src="assets/sidebar.js"></script>
 *
 * Paths in GROUPS are relative to the explainer/ folder, so the sidebar works the same
 * from explainer/ and from explainer/skills-detail/.
 */
(function () {
  'use strict';

  var script = document.currentScript;
  if (!script || !script.src) return;
  var ROOT = new URL('../', script.src); // explainer/

  var GROUPS = [
    {
      title: 'Tổng quan',
      items: [
        { href: 'superpowers.html', label: 'Superpowers', desc: 'Bản đồ skill và MCP' }
      ]
    },
    {
      title: 'Luồng chính',
      items: [
        { href: 'skills-detail/using-superpowers.html', label: 'using-superpowers', n: '0', mono: true },
        { href: 'skills-detail/brainstorming.html', label: 'brainstorming', n: '1', mono: true, tag: 'Nâng cấp' },
        { href: 'skills-detail/using-git-worktrees.html', label: 'using-git-worktrees', n: '2', mono: true },
        { href: 'skills-detail/writing-plans.html', label: 'writing-plans', n: '3', mono: true, tag: 'Nâng cấp' },
        { href: 'skills-detail/subagent-driven-development.html', label: 'subagent-driven-development', n: '4', mono: true },
        { href: 'skills-detail/executing-plans.html', label: 'executing-plans', n: '4', mono: true },
        { href: 'skills-detail/test-driven-development.html', label: 'test-driven-development', n: '5', mono: true, tag: 'Nâng cấp' },
        { href: 'skills-detail/requesting-code-review.html', label: 'requesting-code-review', n: '6', mono: true },
        { href: 'skills-detail/verification-before-completion.html', label: 'verification-before-completion', n: '7', mono: true, tag: 'Nâng cấp' },
        { href: 'skills-detail/finishing-a-development-branch.html', label: 'finishing-a-development-branch', n: '8', mono: true }
      ]
    },
    {
      title: 'Gọi khi cần',
      items: [
        { href: 'skills-detail/systematic-debugging.html', label: 'systematic-debugging', mono: true },
        { href: 'skills-detail/receiving-code-review.html', label: 'receiving-code-review', mono: true },
        { href: 'skills-detail/dispatching-parallel-agents.html', label: 'dispatching-parallel-agents', mono: true }
      ]
    },
    {
      title: 'Ngoài luồng chính',
      items: [
        { href: 'skills-detail/writing-skills.html', label: 'writing-skills', mono: true },
        { href: 'skills-detail/diagnosing-superpowers.html', label: 'diagnosing-superpowers', mono: true }
      ]
    }
  ];

  var MENU_ICON =
    '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="currentColor" ' +
    'stroke-width="1.8" stroke-linecap="round" aria-hidden="true">' +
    '<path d="M2 4h12M2 8h12M2 12h12"/></svg>';

  // Set before first paint so the stylesheet reserves the sidebar gutter. No JS, no gutter.
  document.documentElement.classList.add('ex-sb-on');

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text) e.textContent = text;
    return e;
  }

  function buildItem(item, here) {
    var url = new URL(item.href, ROOT);
    var a = el('a', 'ex-sb-item');
    a.href = url.href;
    if (url.pathname === here) a.setAttribute('aria-current', 'page');

    if (item.n) a.appendChild(el('span', 'ex-sb-n', item.n));

    var text = el('span', 'ex-sb-text');
    text.appendChild(el('span', item.mono ? 'ex-sb-mono' : '', item.label));
    if (item.desc) text.appendChild(el('small', '', item.desc));
    a.appendChild(text);

    if (item.tag) a.appendChild(el('span', 'ex-sb-tag', item.tag));

    var li = el('li');
    li.appendChild(a);
    return li;
  }

  function build() {
    var here = location.pathname;

    var nav = el('nav', 'ex-sb');
    nav.id = 'ex-sb';
    nav.setAttribute('aria-label', 'Các trang explainer');

    var brand = el('a', 'ex-sb-brand', 'Superpowers');
    brand.href = new URL('superpowers.html', ROOT).href;
    brand.appendChild(el('small', '', 'Explainer'));
    nav.appendChild(brand);

    GROUPS.forEach(function (group) {
      nav.appendChild(el('p', 'ex-sb-group', group.title));
      var list = el('ul', 'ex-sb-list');
      group.items.forEach(function (item) { list.appendChild(buildItem(item, here)); });
      nav.appendChild(list);
    });

    var backdrop = el('div', 'ex-sb-backdrop');
    var fab = el('button', 'ex-sb-fab');
    fab.type = 'button';
    fab.setAttribute('aria-controls', 'ex-sb');
    fab.setAttribute('aria-expanded', 'false');
    fab.insertAdjacentHTML('afterbegin', MENU_ICON);
    fab.appendChild(document.createTextNode('Menu'));

    function setOpen(open) {
      nav.classList.toggle('is-open', open);
      backdrop.classList.toggle('is-open', open);
      fab.setAttribute('aria-expanded', String(open));
      if (open) (nav.querySelector('[aria-current="page"]') || nav.querySelector('a')).focus();
    }

    fab.addEventListener('click', function () { setOpen(!nav.classList.contains('is-open')); });
    backdrop.addEventListener('click', function () { setOpen(false); });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && nav.classList.contains('is-open')) {
        setOpen(false);
        fab.focus();
      }
    });

    document.body.appendChild(backdrop);
    document.body.appendChild(nav);
    document.body.appendChild(fab);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', build);
  else build();
})();
