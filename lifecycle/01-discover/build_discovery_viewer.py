"""Build an offline HTML viewer for the Stage 1 Markdown deliverables.

Run from any directory with: python3 lifecycle/01-discover/build_discovery_viewer.py
Requires markdown-it-py, which is used only when regenerating the HTML.
"""

from __future__ import annotations

import html
import os
import re
from pathlib import Path
from urllib.parse import quote, unquote

from markdown_it import MarkdownIt


BASE = Path(__file__).resolve().parent
STEPS = [
    ("01-requirements", "Requirement analysis"),
    ("02-stakeholders", "Stakeholders and roles"),
    ("03-features", "Feature discovery"),
    ("04-nfr", "NFR discovery"),
    ("05-workflows", "Workflow analysis"),
]
KINDS = [
    ("output-schema.md", "Output schema", "A"),
    ("schema-rating-scorecard.md", "Scorecard", "B"),
    ("output-document.md", "Output document", "C"),
]
SUPPORT = [
    ("presenter-notes.md", "Presenter notes"),
    ("dbeaver-hierarchy.md", "DBeaver schema walkthrough"),
    ("requirements.md", "Requirements register"),
    ("actors-goals-features.md", "Actors and features"),
    ("nfr-workflows.md", "NFR and workflow registers"),
    ("test-case-graph.md", "Test-case graph"),
    ("decisions-and-gaps.md", "Decisions and G1 gate"),
    ("../../phase5/local/validation-report.md", "Local seed validation"),
]

documents = [(f"{step}/{filename}", title, kind, step) for step, title in STEPS for filename, kind, _ in KINDS]
documents += [(path, title, "Supporting evidence", "support") for path, title in SUPPORT]
paths = {str((BASE / path).resolve()): path for path, *_ in documents}

markdown = MarkdownIt("default", {"html": False}).enable("table")
original_fence = markdown.renderer.rules["fence"]


def render_fence(tokens, index, options, env):
    token = tokens[index]
    if token.info.strip() == "mermaid":
        source = html.escape(token.content)
        return (
            '<details class="diagram-source"><summary>Workflow diagram notation</summary>'
            '<p>The flow and exception tables around this diagram are formatted below. '
            'Open this source when reviewing exact diagram branches.</p>'
            f'<pre><code>{source}</code></pre></details>'
        )
    return original_fence(tokens, index, options, env)


markdown.renderer.rules["fence"] = render_fence


def rewrite_links(rendered: str, source: Path) -> str:
    def replace(match):
        raw = html.unescape(match.group(1))
        if raw.startswith(("https://", "http://", "mailto:", "#")):
            return match.group(0)
        path_part, separator, fragment = raw.partition("#")
        destination = (source.parent / unquote(path_part)).resolve()
        if str(destination) in paths:
            target = "?doc=" + quote(paths[str(destination)], safe="")
        else:
            target = os.path.relpath(destination, BASE)
        if separator:
            target += "#" + fragment
        return f'href="{html.escape(target, quote=True)}"'

    return re.sub(r'href="([^"]+)"', replace, rendered)


sidebar = []
for number, (step, title) in enumerate(STEPS, start=1):
    links = []
    for filename, label, letter in KINDS:
        key = f"{step}/{filename}"
        links.append(f'<a data-doc-link="{key}" href="?doc={quote(key, safe="")}"><b>{letter}</b> {label}</a>')
    sidebar.append(f'<section class="nav-group"><h2><span>{number:02}</span> {html.escape(title)}</h2>{"".join(links)}</section>')

articles = []
for key, title, kind, step in documents:
    source = (BASE / key).resolve()
    rendered = rewrite_links(markdown.render(source.read_text(encoding="utf-8")), source)
    label = "Supporting evidence" if step == "support" else f"Step {step[:2]} · {next(name for slug, name in STEPS if slug == step)}"
    articles.append(
        f'<article class="document" data-doc="{html.escape(key, quote=True)}" hidden>'
        f'<div class="doc-kicker">{html.escape(label)} / {html.escape(kind)}</div>'
        f'<div class="prose">{rendered}</div>'
        f'<footer class="doc-footer"><a href="{html.escape(os.path.relpath(source, BASE), quote=True)}">View original Markdown source</a>'
        '<span>All status claims retain the source document’s evidence limits.</span></footer></article>'
    )

support_links = "".join(
    f'<a data-doc-link="{html.escape(path, quote=True)}" href="?doc={quote(path, safe="")}">{html.escape(title)}</a>'
    for path, title in SUPPORT
)

page = f'''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Talentra · Discovery documents</title>
  <style>
    :root {{ --ink:#172640; --muted:#52647e; --line:#d3dfeb; --blue:#1769aa; --paper:#f5f8fc; }}
    * {{ box-sizing:border-box; }}
    body {{ margin:0; background:var(--paper); color:var(--ink); font:16px/1.58 system-ui,-apple-system,Segoe UI,Roboto,sans-serif; }}
    a {{ color:#0b609c; text-underline-offset:3px; }}
    a:focus-visible {{ outline:3px solid #e4a12b; outline-offset:3px; }}
    .shell {{ display:grid; grid-template-columns:280px minmax(0,1fr); min-height:100vh; }}
    .sidebar {{ background:#172640; color:white; padding:24px 16px; overflow:auto; max-height:100vh; position:sticky; top:0; }}
    .brand {{ display:block; color:white; text-decoration:none; font-weight:850; letter-spacing:.02em; font-size:1.15rem; padding:5px 8px 18px; }}
    .return {{ display:block; padding:10px 12px; margin:0 5px 24px; border-radius:9px; background:#315577; color:white; text-decoration:none; font-weight:700; }}
    .return:hover {{ background:#3a678f; }}
    .nav-group {{ margin:0 0 18px; }}
    .nav-group h2 {{ margin:0 0 6px; padding:0 8px; color:#d5e4f5; font-size:.86rem; line-height:1.35; }}
    .nav-group h2 span {{ display:inline-block; color:#8fc4f0; margin-right:4px; }}
    .sidebar a[data-doc-link] {{ display:block; padding:7px 9px; margin:2px 0; color:#dbeafa; text-decoration:none; border-radius:8px; font-size:.88rem; }}
    .sidebar a[data-doc-link] b {{ display:inline-grid; place-items:center; width:21px; height:21px; margin-right:5px; border-radius:5px; background:#44627e; color:white; font-size:.72rem; }}
    .sidebar a[data-doc-link]:hover, .sidebar a[data-doc-link].selected {{ background:#355f87; color:white; }}
    .support {{ border-top:1px solid #49627d; padding-top:17px; }}
    .main {{ min-width:0; padding:26px 34px 70px; }}
    .toolbar {{ max-width:1060px; margin:0 auto 17px; display:flex; align-items:center; justify-content:space-between; gap:12px; }}
    .crumb {{ color:var(--muted); font-size:.89rem; font-weight:750; }}
    .top-actions a {{ display:inline-block; padding:7px 10px; border:1px solid var(--line); border-radius:8px; background:white; text-decoration:none; font-weight:700; font-size:.85rem; }}
    .document {{ max-width:1060px; margin:auto; padding:32px clamp(20px,4vw,54px); background:white; border:1px solid var(--line); border-radius:16px; box-shadow:0 10px 30px rgba(28,49,75,.07); }}
    .doc-kicker {{ font-size:.77rem; font-weight:800; letter-spacing:.1em; text-transform:uppercase; color:#1769aa; }}
    .prose h1 {{ margin:6px 0 18px; font-size:clamp(1.6rem,3.1vw,2.4rem); line-height:1.17; letter-spacing:-.025em; }}
    .prose h2 {{ margin:34px 0 12px; padding-bottom:7px; border-bottom:2px solid #e8eef5; font-size:1.35rem; }}
    .prose h3 {{ margin:25px 0 9px; font-size:1.1rem; }}
    .prose p {{ margin:12px 0; max-width:85ch; }}
    .prose li {{ margin:5px 0; }}
    .prose ul, .prose ol {{ padding-left:23px; }}
    .prose table {{ display:block; overflow-x:auto; width:100%; border-collapse:collapse; margin:17px 0 26px; font-size:.92rem; }}
    .prose th, .prose td {{ min-width:105px; border:1px solid var(--line); padding:9px 10px; text-align:left; vertical-align:top; }}
    .prose th {{ background:#eaf2f9; color:#254968; font-weight:800; }}
    .prose tbody tr:nth-child(even) {{ background:#f8fbfe; }}
    .prose code {{ padding:1px 4px; border-radius:4px; background:#ecf2f8; font-size:.88em; }}
    .prose pre {{ overflow:auto; padding:15px; border-radius:10px; background:#172640; color:#eaf4ff; font-size:.85rem; line-height:1.5; }}
    .prose pre code {{ padding:0; color:inherit; background:none; }}
    .prose blockquote {{ margin:18px 0; padding:2px 15px; border-left:4px solid #68a2ce; background:#f5f9fd; color:#34516b; }}
    .prose .diagram-source {{ margin:20px 0; padding:13px 16px; border:1px solid var(--line); border-radius:10px; background:#f7fafd; }}
    .prose .diagram-source summary {{ cursor:pointer; color:#165b92; font-weight:800; }}
    .doc-footer {{ display:flex; flex-wrap:wrap; justify-content:space-between; gap:12px; margin-top:30px; padding-top:16px; border-top:1px solid var(--line); color:var(--muted); font-size:.83rem; }}
    .doc-footer a {{ font-weight:750; }}
    @media(max-width:830px) {{ .shell {{ display:block; }} .sidebar {{ max-height:none; position:static; }} .nav-group {{ display:inline-block; width:45%; vertical-align:top; }} .main {{ padding:15px 10px 45px; }} .document {{ padding:22px 17px; }} }}
    @media(max-width:520px) {{ .nav-group {{ width:100%; }} .toolbar {{ padding:0 5px; }} }}
    @media print {{ body {{ background:white; }} .shell {{ display:block; }} .sidebar,.toolbar,.doc-footer {{ display:none; }} .main {{ padding:0; }} .document {{ border:0; box-shadow:none; max-width:none; padding:0; }} .document[hidden] {{ display:none!important; }} }}
  </style>
</head>
<body>
  <div class="shell">
    <aside class="sidebar" aria-label="Discovery document navigation">
      <a class="brand" href="discovery-visual.html">TALENTRA / DISCOVERY</a>
      <a class="return" id="return-map" href="discovery-visual.html">← Back to five-step visual</a>
      {''.join(sidebar)}
      <section class="nav-group support"><h2>Supporting records</h2>{support_links}</section>
    </aside>
    <main class="main">
      <div class="toolbar"><span class="crumb" id="current-label">Discovery document</span><div class="top-actions"><a id="toolbar-map" href="discovery-visual.html">Visual map</a> <a href="requirement-graph.html">Requirement graph</a> <a href="schema-hierarchy.html">Graphical schema</a></div></div>
      {''.join(articles)}
    </main>
  </div>
  <script>
    const pages = [...document.querySelectorAll('.document')];
    const links = [...document.querySelectorAll('[data-doc-link]')];
    const allowed = new Set(pages.map(page => page.dataset.doc));
    function showDocument(key) {{
      const selected = allowed.has(key) ? key : '01-requirements/output-document.md';
      pages.forEach(page => {{ page.hidden = page.dataset.doc !== selected; }});
      links.forEach(link => {{ link.classList.toggle('selected', link.dataset.docLink === selected); }});
      document.getElementById('current-label').textContent = selected.replaceAll('/', ' / ').replace('.md', '');
      document.title = 'Talentra · ' + selected.split('/').pop().replace('.md', '');
      const step = selected.match(/^0([1-5])-/)?.[1];
      const mapHref = 'discovery-visual.html' + (step ? '#step-' + step : '');
      document.getElementById('return-map').href = mapHref;
      document.getElementById('toolbar-map').href = mapHref;
      window.scrollTo(0, 0);
    }}
    showDocument(new URLSearchParams(location.search).get('doc'));
    window.addEventListener('popstate', () => showDocument(new URLSearchParams(location.search).get('doc')));
    document.addEventListener('click', event => {{
      const anchor = event.target.closest('a[data-doc-link], .prose a[href^="?doc="]');
      if (!anchor || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
      const href = anchor.getAttribute('href');
      if (!href || !href.startsWith('?doc=')) return;
      event.preventDefault();
      const key = new URLSearchParams(href.slice(1)).get('doc');
      history.pushState(null, '', href);
      showDocument(key);
    }});
  </script>
</body>
</html>
'''

output = BASE / "discovery-documents.html"
output.write_text(page, encoding="utf-8")
print(f"Wrote {output} with {len(documents)} formatted documents")
