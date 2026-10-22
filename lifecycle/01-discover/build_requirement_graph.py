"""Build an offline, source-linked bubble graph for the 18 discovery requirements.

Run: python3 lifecycle/01-discover/build_requirement_graph.py
The HTML has no network dependency. Its data comes from the Markdown registers.
"""

from __future__ import annotations

import json
import re
from pathlib import Path


BASE = Path(__file__).resolve().parent

GROUPS = [
    ("Candidate and hiring", "candidate", [1, 2, 15]),
    ("Access and organisations", "access", [3, 4, 5, 6]),
    ("Gig and sourcing", "gig", [7, 8]),
    ("Account and money", "money", [9, 10]),
    ("Engagement and insight", "insight", [11, 12, 16]),
    ("Boundaries and proof", "proof", [13, 14, 17, 18]),
]

SHORT_NAMES = {
    1: "Candidate profile", 2: "Jobs and applications", 3: "Role access",
    4: "Consultants and blocks", 5: "Contact and audit", 6: "Organisations",
    7: "Gig work", 8: "Sourcing", 9: "Seats and sessions",
    10: "Payments and wallet", 11: "Alerts and support", 12: "Analytics",
    13: "External systems", 14: "Evidence and benchmark",
    15: "Extended profile", 16: "Optional insights", 17: "Data rules",
    18: "Module design",
}


def rows(path: Path, prefix: str) -> list[list[str]]:
    result = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith(f"| {prefix}"):
            result.append([cell.strip() for cell in line.strip("|").split("|")])
    return result


def ids(value: str, prefix: str) -> list[str]:
    found = []
    pattern = rf"{prefix}-(\d{{2}})(?:[–-](?:{prefix}-)?(\d{{2}}))?"
    for match in re.finditer(pattern, value):
        first = int(match.group(1))
        last = int(match.group(2) or first)
        found.extend(f"{prefix}-{number:02d}" for number in range(first, last + 1))
    return list(dict.fromkeys(found))


actor_rows = rows(BASE / "actors-goals-features.md", "ACT-")
actors = {row[0]: row[1] for row in actor_rows if len(row) >= 2}
feature_rows = rows(BASE / "actors-goals-features.md", "FEAT-")
features = {row[0]: {"name": row[1], "priority": row[2]} for row in feature_rows if len(row) >= 3}
workflow_text = (BASE / "05-workflows/output-document.md").read_text(encoding="utf-8")
workflows = dict(re.findall(r"^### (WF-\d{2}) — (.+)$", workflow_text, re.M))
workflow_actors: dict[str, set[str]] = {}
workflow_headings = list(re.finditer(r"^### (WF-\d{2}) — .+$", workflow_text, re.M))
for index, heading in enumerate(workflow_headings):
    end = workflow_headings[index + 1].start() if index + 1 < len(workflow_headings) else workflow_text.find("\n## ", heading.end())
    if end < 0:
        end = len(workflow_text)
    body = workflow_text[heading.end():end]
    mentioned = set()
    for actor_group in re.findall(r"ACT-\d{2}(?:/\d{2})*", body):
        mentioned.update(f"ACT-{number}" for number in actor_group.removeprefix("ACT-").split("/"))
    workflow_actors[heading.group(1)] = mentioned

related: dict[str, set[str]] = {f"REQ-{number:02d}": set() for number in range(1, 19)}
for row in rows(BASE / "02-stakeholders/output-document.md", "ACT-"):
    if len(row) < 2:
        continue
    actor_id = ids(row[0], "ACT")
    if not actor_id:
        continue
    for requirement_id in ids(row[1], "REQ"):
        if requirement_id in related:
            related[requirement_id].add(actor_id[0])

group_for = {}
for title, slug, numbers in GROUPS:
    for number in numbers:
        key = f"REQ-{number:02d}"
        assert key not in group_for, key
        group_for[key] = {"title": title, "slug": slug}

requirements = []
for row in rows(BASE / "requirements.md", "REQ-"):
    if len(row) == 2:
        continue  # The second REQ table contains ambiguity notes, not docket rows.
    if len(row) != 7:
        raise ValueError(f"Unexpected requirement columns: {row}")
    key, statement, source, priority, actor_cell, link_cell, evidence = row
    number = int(key[-2:])
    direct_actors = ids(actor_cell, "ACT")
    workflow_id = ids(link_cell, "WF")[0]
    related_actors = sorted((related[key] | workflow_actors[workflow_id]) - set(direct_actors))
    section_numbers = []
    for match in re.finditer(r"sections? (\d+)(?:[–-](\d+))?", source):
        first = int(match.group(1))
        last = int(match.group(2) or first)
        section_numbers.extend(range(first, last + 1))
    sources = [f"Docket section {number}" for number in dict.fromkeys(section_numbers)]
    sources.extend(f"Backlog {code}" for code in re.findall(r"B\d+(?:[–-]B?\d+)?", source))
    feature_id = ids(link_cell, "FEAT")[0]
    requirements.append({
        "id": key,
        "short": SHORT_NAMES[number],
        "statement": statement,
        "source": source,
        "sources": sources,
        "priority": priority,
        "directActors": direct_actors,
        "relatedActors": related_actors,
        "feature": feature_id,
        "workflow": workflow_id,
        "evidence": evidence,
        "group": group_for[key],
    })

assert len(requirements) == 18
assert set(group_for) == {item["id"] for item in requirements}
assert len(actors) == 16 and len(features) == 12 and len(workflows) == 12
for item in requirements:
    assert item["sources"] and item["directActors"]
    assert all(actor in actors for actor in item["directActors"] + item["relatedActors"])
    assert item["feature"] in features and item["workflow"] in workflows

data = {"requirements": requirements, "actors": actors, "features": features, "workflows": workflows, "groups": GROUPS}
payload = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")

template = r'''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Talentra | Requirement connection graph</title>
  <style>
    :root{--ink:#172640;--muted:#52657c;--line:#d7e1ec;--paper:#f3f7fb;--blue:#2168ae;--blue-soft:#eaf3ff;--orange:#af6225;--orange-soft:#fff2e6;--green:#137666;--green-soft:#e4f5ee;--violet:#7153a8;--violet-soft:#f0eafa}
    *{box-sizing:border-box} body{margin:0;color:var(--ink);background:var(--paper);font:15px/1.5 system-ui,-apple-system,Segoe UI,Roboto,sans-serif}button,input,select{font:inherit}button{cursor:pointer}a{color:#155d9e;text-underline-offset:3px}a:focus-visible,button:focus-visible,input:focus-visible,select:focus-visible{outline:3px solid #efae4e;outline-offset:3px}
    .page{max-width:1580px;margin:auto;padding:26px 22px 54px}.top{display:flex;align-items:flex-start;justify-content:space-between;gap:18px;flex-wrap:wrap}.eyebrow{font-weight:850;font-size:.76rem;letter-spacing:.14em;text-transform:uppercase;color:var(--blue)}h1{font-size:clamp(2rem,4vw,3.5rem);line-height:1.06;letter-spacing:-.035em;margin:4px 0 10px}.intro{max-width:820px;color:var(--muted);font-size:1.05rem;margin:0}.top-actions{display:flex;gap:8px;flex-wrap:wrap}.top-actions a,.top-actions button{border:1px solid var(--line);border-radius:9px;padding:9px 12px;background:white;color:var(--ink);text-decoration:none;font-weight:750}.top-actions a:hover,.top-actions button:hover{border-color:var(--blue);background:var(--blue-soft)}
    .metrics{display:flex;gap:8px;flex-wrap:wrap;margin:22px 0}.metric{border:1px solid var(--line);background:white;border-radius:999px;padding:5px 12px;font-weight:750;font-size:.86rem}.metric b{color:var(--blue)}.metric.open b{color:#a15d17}.layout{display:grid;grid-template-columns:minmax(290px,350px) minmax(0,1fr);gap:18px;align-items:start}.selector,.graph-card,.detail{background:white;border:1px solid var(--line);border-radius:18px;box-shadow:0 12px 32px #1c315012}.selector{padding:18px;position:sticky;top:12px;max-height:calc(100vh - 24px);overflow:auto}.selector h2,.graph-card h2,.detail h2{font-size:1.13rem;margin:0 0 11px}.filters{display:grid;gap:8px}.filters input,.filters select{width:100%;padding:10px 11px;border:1px solid #bfcddb;border-radius:9px;background:white;color:var(--ink)}.filter-clear{background:#eff4fa;border:0;border-radius:8px;padding:7px;color:#28557f;font-weight:750}.group{margin-top:17px}.group h3{font-size:.78rem;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin:0 0 8px}.bubble-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px}.req-button{min-height:76px;border:1px solid var(--line);border-radius:14px;padding:9px;background:#f9fbfe;color:var(--ink);text-align:left;display:flex;align-items:center;gap:9px}.req-button:hover{border-color:#7ea7d1;background:#f1f7ff}.req-button.active{border:2px solid var(--blue);background:var(--blue-soft);padding:8px}.req-dot{flex:none;width:41px;height:41px;border-radius:50%;display:grid;place-items:center;color:white;background:var(--blue);font-weight:850;font-size:.76rem;box-shadow:0 3px 7px #24426632}.req-label{font-weight:730;font-size:.83rem;line-height:1.23}.no-results{color:var(--muted);font-size:.9rem;padding:15px 0}
    .right{min-width:0;display:grid;gap:16px}.graph-card{padding:16px 16px 8px}.graph-heading{display:flex;justify-content:space-between;gap:10px;align-items:start;flex-wrap:wrap}.graph-heading p{margin:0;color:var(--muted)}.legend{display:flex;flex-wrap:wrap;gap:6px 13px;margin:8px 0 0;font-size:.78rem;color:var(--muted)}.legend span{display:flex;align-items:center;gap:6px}.swatch{width:9px;height:9px;border-radius:50%;display:inline-block}.graph-wrap{overflow:auto;margin-top:6px}.graph{display:block;width:100%;min-width:690px;max-height:700px;aspect-ratio:940/650}.graph .edge{fill:none;stroke-width:2.6;opacity:.48}.graph .edge.source{stroke:var(--blue)}.graph .edge.actor{stroke:var(--orange)}.graph .edge.feature{stroke:var(--green)}.graph .edge.workflow{stroke:var(--violet)}.graph .edge.related{stroke-dasharray:5 5;opacity:.27}.graph .node-circle{stroke-width:2.5}.graph .source-circle{fill:var(--blue-soft);stroke:#70a2d5}.graph .actor-circle{fill:var(--orange-soft);stroke:#d59a67}.graph .related-circle{fill:#fffaf6;stroke:#d7b89c;stroke-dasharray:4 4}.graph .feature-circle{fill:var(--green-soft);stroke:#53ad91}.graph .workflow-circle{fill:var(--violet-soft);stroke:#a086cb}.graph .req-circle{fill:#2168ae;stroke:#15518a;stroke-width:4;filter:drop-shadow(0 12px 12px #23629c2e)}.graph text{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;fill:var(--ink)}.graph .req-text{fill:white;font-weight:900;font-size:24px}.graph .req-small{fill:#e1edfb;font-size:12px}.graph .node-id{font-weight:850;font-size:11px}.graph .node-label{font-weight:720;font-size:13px}.graph .tiny-label{font-size:10px;fill:var(--muted)}.graph .actor-node{cursor:pointer}.graph .actor-node:hover .node-circle{stroke-width:4}.graph .canvas-label{font-weight:850;letter-spacing:.11em;font-size:11px;fill:#7690a7}.graph .grid-dot{fill:#c4d3e3;opacity:.34}
    .detail{padding:22px}.detail-top{display:flex;justify-content:space-between;gap:12px;align-items:start;flex-wrap:wrap}.tag{display:inline-block;padding:3px 9px;border-radius:999px;background:#edf3fa;color:#295678;font-size:.74rem;font-weight:800}.tag.must{background:#e7f5ed;color:#18624c}.tag.expected{background:#fff1d9;color:#8a5a0f}.tag.stretch{background:#efeafa;color:#654998}.statement{font-size:1.05rem;font-weight:600;margin:13px 0 20px;max-width:90ch}.detail-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.info{border:1px solid var(--line);background:#f9fbfe;border-radius:12px;padding:12px 14px;min-width:0}.info h3{font-size:.78rem;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin:0 0 7px}.info p{margin:0}.chips{display:flex;flex-wrap:wrap;gap:6px}.chip{display:inline-block;padding:4px 8px;border-radius:999px;background:var(--orange-soft);color:#75421e;font-size:.82rem;font-weight:700}.chip.related{background:#f7f2ed;color:#6d5a4b}.info .subnote{font-size:.81rem;color:var(--muted);margin-top:8px}.links{margin-top:16px;display:flex;gap:8px;flex-wrap:wrap}.links a{display:inline-block;padding:7px 10px;border-radius:8px;background:#eaf2fb;text-decoration:none;font-size:.84rem;font-weight:750}.note{margin-top:17px;padding:11px 13px;border-left:4px solid #d28b32;background:#fff8eb;border-radius:7px;color:#61451e;font-size:.87rem}
    @media(max-width:1000px){.layout{grid-template-columns:1fr}.selector{position:static;max-height:none}.bubble-grid{grid-template-columns:repeat(3,minmax(0,1fr))}}@media(max-width:640px){.page{padding:17px 10px 38px}.bubble-grid,.detail-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.req-button{min-height:70px}.req-dot{width:36px;height:36px}.graph-card{padding:12px 7px}.detail{padding:15px}}@media(max-width:450px){.bubble-grid,.detail-grid{grid-template-columns:1fr}.req-button{min-height:52px}}
    @media print{body{background:white}.page{max-width:none;padding:0}.selector,.top-actions,.filters,.links{display:none}.layout{display:block}.graph-card,.detail{box-shadow:none;border:0}.graph{min-width:0}.detail{break-inside:avoid}.note{border:1px solid #ccc}}
  </style>
</head>
<body>
<main class="page">
  <header class="top"><div><div class="eyebrow">Talentra / Stage 1 discovery</div><h1>Requirement connection graph</h1><p class="intro">Choose any requirement bubble. The graph shows which part of the docket it came from, who is involved, the feature it becomes, and the workflow that uses it.</p></div><div class="top-actions"><a href="discovery-visual.html">Five-step overview</a><a href="schema-hierarchy.html">Graphical schema</a><a href="discovery-documents.html?doc=01-requirements%2Foutput-document.md">Read the docket</a><button id="save-svg" type="button">Download graph SVG</button></div></header>
  <div class="metrics"><span class="metric"><b>18</b> requirements</span><span class="metric"><b>16</b> actors</span><span class="metric"><b>12</b> features</span><span class="metric"><b>12</b> workflows</span><span class="metric open"><b>G1 open</b> — design review pending</span></div>
  <div class="layout"><aside class="selector" aria-label="Choose a requirement"><h2>Explore the 18 requirements</h2><div class="filters"><input id="search" type="search" placeholder="Search ID, topic, source or actor" aria-label="Search requirements"><select id="actor-filter" aria-label="Filter by actor"><option value="">All actors</option></select><button class="filter-clear" id="clear-filters" type="button">Clear filters</button></div><div id="requirement-groups"></div></aside>
    <div class="right"><section class="graph-card" aria-label="Connected requirement graph"><div class="graph-heading"><div><h2 id="graph-title">REQ-03 / Role access</h2><p>Solid actor lines: named in the requirement. Dotted lines: linked by the stakeholder trace.</p></div><div class="legend"><span><i class="swatch" style="background:#2168ae"></i>Source</span><span><i class="swatch" style="background:#af6225"></i>Actor</span><span><i class="swatch" style="background:#137666"></i>Feature</span><span><i class="swatch" style="background:#7153a8"></i>Workflow</span></div></div><div class="graph-wrap"><svg class="graph" id="graph" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 940 650" role="img" aria-label="Connections for the selected requirement"></svg></div></section>
      <section class="detail" id="detail" aria-live="polite"><div class="detail-top"><div><span class="tag" id="group-tag"></span><h2 id="detail-title"></h2></div><span class="tag" id="priority-tag"></span></div><p class="statement" id="statement"></p><div class="detail-grid"><div class="info"><h3>Source in the brief</h3><p id="source-text"></p><p class="subnote">The linked PDF is the raw docket; this graph uses the requirement register's source mapping.</p></div><div class="info"><h3>People and systems involved</h3><div class="chips" id="actor-chips"></div><p class="subnote">Filled = named directly in the requirement. Light = linked in the stakeholder trace.</p></div><div class="info"><h3>Feature and workflow</h3><p id="feature-workflow"></p></div><div class="info"><h3>Current evidence or gap</h3><p id="evidence"></p></div></div><div class="links"><a id="source-link" href="../../sources/Talentra-Database-Design-Hackathon-Docket.pdf">Open source PDF</a><a href="discovery-documents.html?doc=requirements.md">Requirement register</a><a href="discovery-documents.html?doc=02-stakeholders%2Foutput-document.md">Actor permissions</a><a href="discovery-documents.html?doc=03-features%2Foutput-document.md">Feature inventory</a><a href="discovery-documents.html?doc=05-workflows%2Foutput-document.md">Workflow cards</a></div><div class="note">This is a traceability view of the discovery documents. An actor link shows involvement or impact; it does not grant access. Gate G1 remains open for source and policy review.</div></section></div>
  </div>
</main>
<script id="graph-data" type="application/json">__GRAPH_DATA__</script>
<script>
const DATA=JSON.parse(document.getElementById('graph-data').textContent);
const requirements=DATA.requirements;
const byId=Object.fromEntries(requirements.map(item=>[item.id,item]));
const ns='http://www.w3.org/2000/svg';
const svg=document.getElementById('graph');
const groupsEl=document.getElementById('requirement-groups');
const searchEl=document.getElementById('search');
const actorFilter=document.getElementById('actor-filter');
let selected=byId[location.hash.slice(1)]||byId['REQ-03'];
function svgElement(name,attrs={},parent=svg){const el=document.createElementNS(ns,name);for(const [key,value] of Object.entries(attrs))el.setAttribute(key,String(value));parent.appendChild(el);return el}
function textNode(x,y,content,cls,anchor='middle',parent=svg){const el=svgElement('text',{x,y,'text-anchor':anchor,class:cls},parent);el.textContent=content;return el}
function bubble(x,y,r,kind,id,label,opts={}){const g=svgElement('g',{class:opts.click?'actor-node':''});svgElement('circle',{cx:x,cy:y,r,class:`node-circle ${kind}-circle ${opts.related?'related-circle':''}`},g);textNode(x,y+4,id,'node-id','middle',g);if(label)textNode(opts.labelX??x,opts.labelY??(y+r+18),label,'node-label',opts.anchor||'middle',g);if(opts.click){g.setAttribute('tabindex','0');g.setAttribute('role','button');g.setAttribute('aria-label',`Filter by actor ${opts.fullLabel||label}`);g.addEventListener('click',()=>filterByActor(id));g.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();filterByActor(id)}})}return g}
function edge(x1,y1,x2,y2,kind,related=false){const bend=(x2-x1)*.47;svgElement('path',{d:`M ${x1} ${y1} C ${x1+bend} ${y1}, ${x2-bend} ${y2}, ${x2} ${y2}`,class:`edge ${kind} ${related?'related':''}`})}
function draw(){svg.replaceChildren();for(let x=20;x<940;x+=36)for(let y=20;y<650;y+=36)svgElement('circle',{cx:x,cy:y,r:1.1,class:'grid-dot'});textNode(42,42,'SOURCE','canvas-label','start');textNode(365,42,'REQUIREMENT','canvas-label','start');textNode(683,42,'ACTORS','canvas-label','start');textNode(94,475,'CAPABILITY','canvas-label','start');textNode(386,475,'PROCESS','canvas-label','start');
  const sources=selected.sources;const sourceY=sources.map((_,i)=>150+i*95);const allActors=[...selected.directActors.map(id=>({id,related:false})),...selected.relatedActors.map(id=>({id,related:true}))];const actorStep=Math.min(66,470/Math.max(1,allActors.length-1));const actorStart=allActors.length===1?290:86;const actorY=allActors.map((_,i)=>actorStart+i*actorStep);
  sources.forEach((_,i)=>edge(178,sourceY[i],353,266,'source'));
  allActors.forEach((actor,i)=>edge(507,287,697,actorY[i],'actor',actor.related));
  edge(381,350,204,521,'feature');edge(442,371,442,521,'workflow');
  sources.forEach((source,i)=>{bubble(133,sourceY[i],39,'source',source.replace('Docket ','').replace('Backlog ',''),source,{labelY:sourceY[i]+58})});
  const core=svgElement('g');svgElement('circle',{cx:435,cy:287,r:84,class:'req-circle'},core);textNode(435,278,selected.id,'req-text','middle',core);textNode(435,306,selected.short.length>27?selected.short.slice(0,25)+'…':selected.short,'req-small','middle',core);
  allActors.forEach((actor,i)=>{const name=DATA.actors[actor.id];bubble(727,actorY[i],27,actor.related?'related':'actor',actor.id,name.length>23?name.slice(0,22)+'…':name,{related:actor.related,click:true,fullLabel:name,labelX:766,labelY:actorY[i]+5,anchor:'start'})});
  bubble(175,548,44,'feature',selected.feature,DATA.features[selected.feature].name.length>30?DATA.features[selected.feature].name.slice(0,29)+'…':DATA.features[selected.feature].name,{labelY:615});
  bubble(442,548,44,'workflow',selected.workflow,DATA.workflows[selected.workflow].length>34?DATA.workflows[selected.workflow].slice(0,33)+'…':DATA.workflows[selected.workflow],{labelY:615});
  svg.setAttribute('aria-label',`${selected.id}: ${selected.short}. ${sources.join(', ')}; actors ${allActors.map(a=>a.id+' '+DATA.actors[a.id]).join(', ')}; ${selected.feature}; ${selected.workflow}`);
}
function actorChip(id,related){const span=document.createElement('span');span.className='chip'+(related?' related':'');span.textContent=`${id} ${DATA.actors[id]}`;return span}
function detail(){document.getElementById('graph-title').textContent=`${selected.id} / ${selected.short}`;document.getElementById('group-tag').textContent=selected.group.title;const p=document.getElementById('priority-tag');p.className='tag '+({M:'must',E:'expected',S:'stretch'}[selected.priority]||'');p.textContent={M:'Mandatory',E:'Expected Tier 2',S:'Optional stretch'}[selected.priority]||selected.priority;document.getElementById('detail-title').textContent=`${selected.id} — ${selected.short}`;document.getElementById('statement').textContent=selected.statement;document.getElementById('source-text').textContent=selected.source;document.getElementById('evidence').textContent=selected.evidence;const chips=document.getElementById('actor-chips');chips.replaceChildren(...selected.directActors.map(id=>actorChip(id,false)),...selected.relatedActors.map(id=>actorChip(id,true)));document.getElementById('feature-workflow').textContent=`${selected.feature}: ${DATA.features[selected.feature].name}. ${selected.workflow}: ${DATA.workflows[selected.workflow]}.`;const first=selected.sources.find(s=>s.startsWith('Docket section'));const section=first?Number(first.match(/\d+/)[0]):1;const page={1:2,2:3,3:4,4:5,5:6,6:7,7:8}[section]||2;document.getElementById('source-link').href=`../../sources/Talentra-Database-Design-Hackathon-Docket.pdf#page=${page}`}
function matches(item){const query=searchEl.value.trim().toLowerCase();const actor=actorFilter.value;if(actor&&![...item.directActors,...item.relatedActors].includes(actor))return false;if(!query)return true;return [item.id,item.short,item.statement,item.source,item.group.title,...[...item.directActors,...item.relatedActors].map(id=>`${id} ${DATA.actors[id]}`)].join(' ').toLowerCase().includes(query)}
function renderList(){groupsEl.replaceChildren();let count=0;for(const [title,slug,numbers] of DATA.groups){const items=numbers.map(n=>byId[`REQ-${String(n).padStart(2,'0')}`]).filter(matches);if(!items.length)continue;count+=items.length;const group=document.createElement('section');group.className='group';const h=document.createElement('h3');h.textContent=`${title} (${items.length})`;group.appendChild(h);const grid=document.createElement('div');grid.className='bubble-grid';for(const item of items){const button=document.createElement('button');button.type='button';button.className='req-button'+(item.id===selected.id?' active':'');button.setAttribute('aria-pressed',String(item.id===selected.id));const dot=document.createElement('span');dot.className='req-dot';dot.textContent=item.id.slice(4);const label=document.createElement('span');label.className='req-label';label.textContent=item.short;button.append(dot,label);button.addEventListener('click',()=>select(item.id));grid.appendChild(button)}group.appendChild(grid);groupsEl.appendChild(group)}if(!count){const empty=document.createElement('p');empty.className='no-results';empty.textContent='No requirement matches this filter.';groupsEl.appendChild(empty)}}
function select(id){selected=byId[id];history.replaceState(null,'',`#${id}`);renderList();draw();detail()}
function filterByActor(id){actorFilter.value=id;renderList()}
Object.entries(DATA.actors).forEach(([id,name])=>{const opt=document.createElement('option');opt.value=id;opt.textContent=`${id} ${name}`;actorFilter.appendChild(opt)});
searchEl.addEventListener('input',renderList);actorFilter.addEventListener('change',renderList);document.getElementById('clear-filters').addEventListener('click',()=>{searchEl.value='';actorFilter.value='';renderList()});window.addEventListener('hashchange',()=>{const id=location.hash.slice(1);if(byId[id])select(id)});
document.getElementById('save-svg').addEventListener('click',()=>{const copy=svg.cloneNode(true);copy.setAttribute('xmlns',ns);const style=document.createElementNS(ns,'style');style.textContent='.edge{fill:none;stroke-width:2.6;opacity:.5}.edge.source{stroke:#2168ae}.edge.actor{stroke:#af6225}.edge.feature{stroke:#137666}.edge.workflow{stroke:#7153a8}.edge.related{stroke-dasharray:5 5;opacity:.3}.node-circle{stroke-width:2.5}.source-circle{fill:#eaf3ff;stroke:#70a2d5}.actor-circle{fill:#fff2e6;stroke:#d59a67}.related-circle{fill:#fffaf6;stroke:#d7b89c;stroke-dasharray:4 4}.feature-circle{fill:#e4f5ee;stroke:#53ad91}.workflow-circle{fill:#f0eafa;stroke:#a086cb}.req-circle{fill:#2168ae;stroke:#15518a;stroke-width:4}text{font-family:Arial,sans-serif;fill:#172640}.req-text{fill:white;font-weight:900;font-size:24px}.req-small{fill:#e1edfb;font-size:12px}.node-id{font-weight:850;font-size:11px}.node-label{font-weight:720;font-size:13px}.canvas-label{font-weight:850;letter-spacing:.11em;font-size:11px;fill:#7690a7}.grid-dot{fill:#c4d3e3;opacity:.34}';copy.insertBefore(style,copy.firstChild);const xml=new XMLSerializer().serializeToString(copy);const url=URL.createObjectURL(new Blob([xml],{type:'image/svg+xml'}));const a=document.createElement('a');a.href=url;a.download=`talentra-${selected.id.toLowerCase()}-graph.svg`;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000)});
select(selected.id);
</script>
</body>
</html>
'''

output = BASE / "requirement-graph.html"
output.write_text(template.replace("__GRAPH_DATA__", payload), encoding="utf-8")
print(f"Wrote {output} with {len(requirements)} requirements, {len(actors)} actors, {len(features)} features and {len(workflows)} workflows")
