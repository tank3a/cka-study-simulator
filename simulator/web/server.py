#!/usr/bin/env python3
"""CKA simulator study dashboard. stdlib only. Binds 127.0.0.1. See simulator/README.md (web section)."""
import argparse
import html
import json
import os
import re
import secrets
import shlex
import shutil
import socket
import subprocess
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import data as D          # noqa: E402
import mdlite             # noqa: E402

E = html.escape
ANSI = re.compile(r'\x1b\[[0-9;?]*[A-Za-z]')
EXAM = os.path.join(D.SIM, 'bin', 'exam')
STATE_SHARE = os.path.join(D.SIM, 'state', 'share')

CFG = dict(dry=False, port=8765, ttyd_port=7681, token='', term_token='')
DATA = D.Data()
LOCK = threading.Lock()          # one live action at a time
GRADED = set()                   # question ids graded at least once since server start
TTYD = {'proc': None}

CSS = r'''
:root{--paper:#f2f5f6;--panel:#fff;--ink:#12232b;--ink-soft:#4a5d66;--rule:#d5dde1;--accent:#1d5fa8;--accent-ink:#fff;--accent-wash:#e3edf8;--term-bg:#10222b;--term-ink:#d8e6ec;--term-dim:#7f98a3;--good:#1f7a4d;--good-wash:#def1e6;--warn:#9a6200;--warn-wash:#fbefd2;--bad:#a93a3a;--bad-wash:#f8e0e0;--font-body:"IBM Plex Sans KR","Apple SD Gothic Neo","Malgun Gothic",system-ui,sans-serif;--font-mono:"IBM Plex Mono",ui-monospace,"SF Mono",Menlo,monospace}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){color-scheme:dark;--paper:#0e1a20;--panel:#14242c;--ink:#e3edf1;--ink-soft:#9db0b8;--rule:#26393f;--accent:#6fa8e6;--accent-ink:#0e1a20;--accent-wash:#1a2f45;--term-bg:#08131a;--term-ink:#d8e6ec;--term-dim:#6f8892;--good:#5fc592;--good-wash:#16372a;--warn:#e0b04f;--warn-wash:#3a2f14;--bad:#ec8b8b;--bad-wash:#3d1f1f}}
:root[data-theme="dark"]{color-scheme:dark;--paper:#0e1a20;--panel:#14242c;--ink:#e3edf1;--ink-soft:#9db0b8;--rule:#26393f;--accent:#6fa8e6;--accent-ink:#0e1a20;--accent-wash:#1a2f45;--term-bg:#08131a;--term-ink:#d8e6ec;--term-dim:#6f8892;--good:#5fc592;--good-wash:#16372a;--warn:#e0b04f;--warn-wash:#3a2f14;--bad:#ec8b8b;--bad-wash:#3d1f1f}
*{box-sizing:border-box}
body{margin:0;background:var(--paper);color:var(--ink);font-family:var(--font-body);font-size:15px;line-height:1.65;padding-left:max(16px,env(safe-area-inset-left,0px));padding-right:max(16px,env(safe-area-inset-right,0px));padding-block:0 80px}
.wrap{max-width:1000px;margin:0 auto;display:flex;flex-direction:column;gap:28px;padding-top:24px}
nav{background:var(--panel);border-bottom:1px solid var(--rule);margin:0 -16px;padding:10px 16px;display:flex;gap:18px;align-items:center;flex-wrap:wrap;position:sticky;top:0;z-index:5}
nav .brand{font-family:var(--font-mono);font-weight:600;letter-spacing:.04em}
nav a{text-decoration:none;color:var(--ink-soft)}nav a:hover{color:var(--accent)}
nav .sp{flex:1}
h1,h2,h3,h4,h5{text-wrap:balance;line-height:1.3;margin:0}
h1{font-size:30px;font-weight:700;letter-spacing:-.01em}
h2{font-size:21px;font-weight:700;padding-bottom:8px;border-bottom:2px solid var(--ink)}
h3{font-size:16px;font-weight:600}h4,h5{font-size:15px;font-weight:600;margin-top:14px}
p{margin:0 0 8px;max-width:76ch}a{color:var(--accent)}
code,.mono{font-family:var(--font-mono);font-size:.92em}
code{background:var(--accent-wash);padding:1px 6px;border-radius:3px}
.label{font-family:var(--font-mono);font-size:11.5px;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-soft)}
.soft{color:var(--ink-soft)}
.facts{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));border:1px solid var(--rule);background:var(--panel)}
.facts div{padding:10px 14px;border-right:1px solid var(--rule);display:flex;flex-direction:column}
.facts b{font-family:var(--font-mono);font-size:20px;font-weight:600}.facts span{font-size:12.5px;color:var(--ink-soft)}
.card{background:var(--panel);border:1px solid var(--rule);padding:16px 18px;display:flex;flex-direction:column;gap:10px}
.card.done{opacity:.6}
.cardhead{display:flex;gap:10px;align-items:baseline;flex-wrap:wrap}
.cardhead h2{border:0;padding:0;font-size:19px}
.concept{border-top:1px dashed var(--rule);padding-top:8px;display:flex;flex-direction:column;gap:5px}
.concept .cn{font-weight:600}
.chips{display:flex;flex-wrap:wrap;gap:6px}
a.chip{display:inline-flex;gap:6px;align-items:center;border:1px solid var(--rule);background:var(--paper);padding:2px 8px;border-radius:4px;text-decoration:none;color:var(--ink);font-family:var(--font-mono);font-size:12px}
a.chip:hover{border-color:var(--accent)}a.chip b{color:var(--accent)}
.pill{display:inline-block;font-family:var(--font-mono);font-size:11px;padding:0 7px;border-radius:10px;white-space:nowrap;line-height:1.6}
.pill.good{background:var(--good-wash);color:var(--good)}.pill.warn{background:var(--warn-wash);color:var(--warn)}.pill.bad{background:var(--bad-wash);color:var(--bad)}.pill.mute{background:var(--accent-wash);color:var(--accent)}.pill.grey{background:var(--rule);color:var(--ink-soft)}
.scroll{overflow-x:auto;border:1px solid var(--rule);background:var(--panel)}
table{border-collapse:collapse;width:100%;font-size:14px}
th,td{text-align:left;padding:8px 12px;border-bottom:1px solid var(--rule);vertical-align:top}
th{font-family:var(--font-mono);font-size:11.5px;letter-spacing:.06em;text-transform:uppercase;color:var(--ink-soft);font-weight:500;background:var(--paper);white-space:nowrap}
tr:last-child td{border-bottom:0}
pre.term,.term{background:var(--term-bg);color:var(--term-ink);font-family:var(--font-mono);font-size:13px;line-height:1.7;padding:12px 16px;overflow-x:auto;border-radius:4px;margin:0;white-space:pre}
pre.term code{background:none;padding:0;color:inherit}
.md{background:var(--panel);border:1px solid var(--rule);padding:16px 20px}
.md ul,.md ol{margin:4px 0 10px;padding-left:22px}.md li{margin:2px 0}
.md pre{margin:8px 0 12px}.md blockquote{margin:8px 0;padding:4px 14px;border-left:3px solid var(--accent);color:var(--ink-soft)}
.md h2{font-size:18px}.md h3{font-size:16px;margin-top:12px}
button,.btn{font:inherit;font-size:14px;padding:6px 14px;border-radius:4px;border:1px solid var(--accent);background:var(--accent);color:var(--accent-ink);cursor:pointer;text-decoration:none;display:inline-block}
button.sec{background:var(--panel);color:var(--accent)}
button:disabled{opacity:.45;cursor:not-allowed}
button:focus-visible,a:focus-visible,select:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
.actions{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
.banner{border:1px solid var(--warn);background:var(--warn-wash);padding:10px 14px}
.banner.bad{border-color:var(--bad);background:var(--bad-wash)}
.out{display:none}.out.on{display:block}
iframe.termf{width:100%;height:520px;border:1px solid var(--rule);background:#000}
.filters{display:flex;gap:10px;flex-wrap:wrap}select,input[type=search]{font:inherit;padding:5px 8px;background:var(--panel);color:var(--ink);border:1px solid var(--rule);border-radius:4px}
.cols{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:14px}
details>summary{cursor:pointer;color:var(--accent)}
@media (max-width:600px){h1{font-size:24px}}
'''

JS = r'''
(function(){
var t=null;try{t=localStorage.getItem('cka-web-theme')}catch(e){}
if(t)document.documentElement.setAttribute('data-theme',t);
window.toggleTheme=function(){var cur=document.documentElement.getAttribute('data-theme');
 var dark=cur?cur==='dark':window.matchMedia('(prefers-color-scheme: dark)').matches;
 var n=dark?'light':'dark';document.documentElement.setAttribute('data-theme',n);try{localStorage.setItem('cka-web-theme',n)}catch(e){}};
document.querySelectorAll('input.daydone').forEach(function(b){var s={};try{s=JSON.parse(localStorage.getItem('cka-web-days')||'{}')}catch(e){}
 b.checked=!!s[b.dataset.day];b.closest('.card').classList.toggle('done',b.checked);
 b.addEventListener('change',function(){s[b.dataset.day]=b.checked;b.closest('.card').classList.toggle('done',b.checked);try{localStorage.setItem('cka-web-days',JSON.stringify(s))}catch(e){}});});
})();
'''

QJS = r'''
(function(){
var QID=document.body.dataset.qid, $=function(i){return document.getElementById(i)};
var graded=document.body.dataset.graded==='1';
function post(url,body){return fetch(url,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:body||''}).then(function(r){return r.json().catch(function(){return {error:'HTTP '+r.status}})})}
function show(txt,cls){var o=$('out');o.className='out on term';o.textContent=txt}
function esc(s){var d=document.createElement('div');d.textContent=s==null?'':String(s);return d.innerHTML}
function table(rs){if(!rs||!rs.length)return '';var p=0,t=0;rs.forEach(function(r){t+=r.points||0;if(r.pass)p+=r.points||0});
 var h='<div class="label">Result: '+p+' / '+t+' points</div><div class="scroll"><table><thead><tr><th>check</th><th>result</th><th>pts</th><th>detail</th></tr></thead><tbody>';
 rs.forEach(function(r){h+='<tr><td>'+esc(r.check)+'</td><td><span class="pill '+(r.pass?'good':'bad')+'">'+(r.pass?'PASS':'FAIL')+'</span></td><td class="mono">'+esc(r.points)+'</td><td class="soft">'+(r.pass?'':esc(r.detail))+'</td></tr>'});
 return h+'</tbody></table></div>'}
function act(name,btn){
 var old=btn.textContent;btn.disabled=true;btn.textContent=old+' ...';$('res').innerHTML='';
 post('/api/'+name+'/'+QID).then(function(j){
  btn.disabled=false;btn.textContent=old;
  if(j.error&&!j.argv){show(j.error);return}
  show((j.dry_run?'[dry-run] would run: ':'$ ')+j.cmd+'\n'+(j.output||'')+(j.error?'\n'+j.error:'')+(j.rc!=null&&!j.dry_run?'\n[exit '+j.rc+']':''));
  if(name==='grade'){ $('res').innerHTML=table(j.results); graded=true; $('sol').disabled=false; }
 }).catch(function(e){btn.disabled=false;btn.textContent=old;show('request failed: '+e)});}
['start','grade','reset'].forEach(function(n){var b=$('b-'+n);if(b)b.addEventListener('click',function(){act(n,b)})});
var gu=$('giveup'),sol=$('sol');
function sync(){sol.disabled=!(graded||gu.checked)}
gu.addEventListener('change',sync);sync();
sol.addEventListener('click',function(){sol.disabled=true;
 post('/api/solution/'+QID,'ack='+(graded?'graded':'giveup')).then(function(j){
  if(j.error){$('solbox').innerHTML='<div class="banner bad">'+esc(j.error)+'</div>';sol.disabled=false;return}
  $('solbox').innerHTML='<div class="md">'+j.html+'</div>'});});
var tb=$('b-term');
if(tb)tb.addEventListener('click',function(){
 post('/api/term/start').then(function(j){var p=$('termpanel');p.hidden=false;
  if(j.error||j.fallback){p.innerHTML='<div class="banner">'+esc(j.error||'')+'</div>'+(j.cmd?'<pre class="term">'+esc(j.cmd)+'</pre>':'')+'<p class="soft">Fallback: run <code>bin/sim term</code> in a normal terminal.</p>';return}
  if(j.dry_run){p.innerHTML='<div class="banner">dry-run: would run</div><pre class="term">'+esc(j.cmd)+'</pre>';return}
  p.innerHTML='<iframe class="termf" src="'+esc(j.url)+'" title="exam-term"></iframe><p class="soft">Embedded ttyd on 127.0.0.1. <button class="sec" id="b-tstop">Stop terminal</button></p>';
  $('b-tstop').addEventListener('click',function(){post('/api/term/stop').then(function(){p.hidden=true;p.innerHTML=''})});});});
})();
'''

# ----------------------------------------------------------------- helpers

def pill(cls, text, title=''):
    return '<span class="pill %s"%s>%s</span>' % (cls, ' title="%s"' % E(title) if title else '', E(text))


def fid_pill(q):
    k = q['fid']
    cls = {'high': 'good', 'partial': 'warn', 'medium': 'warn', 'low': 'bad'}.get(k, 'grey')
    return pill(cls, k if k != 'unknown' else '?', q['fidelity'])


def ver_pill(sid, ver, have):
    if not have:
        return pill('grey', 'unverified', 'docs/VERIFICATION.md not present')
    st, note = ver.get(sid, ('UNTESTED', 'no entry in VERIFICATION.md'))
    cls = {'VERIFIED': 'good', 'PARTIAL': 'warn', 'FAILED': 'bad'}.get(st, 'grey')
    return pill(cls, st.lower(), note)


def chip(sid, hint='', ver=None, have=False):
    qid = DATA.short_map.get(sid)
    if not qid:
        return '<span class="chip pill grey">%s</span>' % E(sid)
    q = DATA.questions[qid]
    warn = ''
    hard = [c for k, c in q['conflicts'] if k in ('hard', 'ordering', 'row')]
    if hard:
        warn = pill('warn', '! conflict', ' | '.join(hard)[:500])
    return '<a class="chip" href="/q/%s" title="%s"><b>%s</b> w%s %s %s %s %s%s</a>' % (
        E(qid), E(q['title']), sid, E(str(q['weight'])), E(q['difficulty']), fid_pill(q), warn, ver_pill(sid, ver, have), hint)


def page(title, body, extra_js='', body_attr=''):
    tokline = ''
    return '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>%s</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans+KR:wght@400;500;600;700&display=swap">
<style>%s</style></head><body%s>
<div class="wrap"><nav><span class="brand">CKA SIM</span><a href="/">14-day plan</a><a href="/concepts">Concepts</a><a href="/terminal">Terminal</a><span class="sp"></span>%s<a href="#" onclick="toggleTheme();return false">theme</a></nav>
%s
</div><script>%s</script><script>%s</script></body></html>''' % (
        E(title), CSS, body_attr, ('<span class="pill warn">DRY-RUN</span>' if CFG['dry'] else ''), body, JS, extra_js)


def md_block(md):
    return '<div class="md">%s</div>' % mdlite.render(md)


def sub_label(code):
    s = DATA.secs.get(code)
    return '%s %s' % (code, s['title']) if s else code


# ----------------------------------------------------------------- pages

def concept_block(c, ver, have, day=None):
    gap = pill('warn', 'no high-fidelity', 'all questions partial/low') if c['fclass'] == 'nohigh' else ''
    if day is None:
        chips = ''.join(chip(sid, ver=ver, have=have) for sid, _ in c['qs'])
        rest = ''
    else:
        mine = [sid for sid, _ in c['qs'] if sid in day['plan_qs']]
        other = [sid for sid, _ in c['qs'] if sid not in day['plan_qs']]
        chips = ''.join(chip(sid, ver=ver, have=have) for sid in mine) or '<span class="soft">이 날짜 계획에 배정된 문제 없음</span>'
        rest = ''
        if other:
            def homeday(sid):
                ds = DATA.q_days.get(sid)
                return ('Day %s' % ','.join(str(x) for x in ds)) if ds else '날짜 미배정'
            rest = '<details><summary class="soft">같은 개념의 추가 연습 %d개 (다른 날 범위, 지금은 건너뛰어도 됩니다)</summary><div class="chips">%s</div><div class="soft" style="font-size:12px">%s</div></details>' % (
                len(other), ''.join(chip(sid, ver=ver, have=have) for sid in other),
                E(' / '.join('%s: %s' % (sid, homeday(sid)) for sid in other)))
    return '<div class="concept"><div><span class="cn">%s</span> <span class="label">%s</span> %s</div><div class="chips">%s</div>%s</div>' % (
        E(c['name']), E(c['code']), gap, chips, rest)


def day_card(d, ver, have, full=False):
    subs = ' '.join(pill('mute', s, DATA.secs[s]['title'] if s in DATA.secs else '') for s in d['subs']) if len(d['subs']) <= 8 else pill('mute', '%d sub-competencies' % len(d['subs']))
    plan = ''.join(chip(s, ver=ver, have=have) for s in d['plan_qs'])
    inner_concepts = ''.join(concept_block(c, ver, have, d if d['n'] <= 10 else None) for c in d['concepts'])
    if d['n'] >= 11 and not full:
        cb = '<details><summary>%d related concepts</summary>%s</details>' % (len(d['concepts']), inner_concepts)
    else:
        cb = inner_concepts
    return '''<section class="card" id="day%d"><div class="cardhead"><h2><a href="/day/%d" style="color:inherit;text-decoration:none">Day %d</a> &middot; %s</h2>%s
<label class="soft" style="margin-left:auto"><input type="checkbox" class="daydone" data-day="%d"> done</label></div>
<div class="soft">%s</div>
<div class="label">Plan questions</div><div class="chips">%s</div>
<div class="soft" style="font-size:13px">%s</div>
<div><a class="btn sec" href="/day/%d/notes">study notes</a> <span class="soft">(%d concepts)</span></div>
%s</section>''' % (d['n'], d['n'], d['n'], E(d['slice']), subs, d['n'], E(d['tools']), plan, E(d['qraw']), d['n'], len(d['concepts']), cb)


def p_home():
    ver, have = DATA.verification()
    vc = {}
    for q in DATA.questions.values():
        vc[ver.get(q['short'], ('UNTESTED', ''))[0] if have else 'unverified'] = vc.get(ver.get(q['short'], ('UNTESTED', ''))[0] if have else 'unverified', 0) + 1
    facts = '<div class="facts"><div><b>%d</b><span>days</span></div><div><b>%d</b><span>concepts</span></div><div><b>%d</b><span>questions</span></div><div><b>%s</b><span>verification</span></div></div>' % (
        len(DATA.days), len(DATA.concepts), len(DATA.questions),
        E(' '.join('%s:%d' % (k.lower()[:4], v) for k, v in sorted(vc.items()))))
    login = '' if cookie_ok_now.val else '<div class="banner">Action buttons and the terminal need the launch URL with <code>?token=...</code> (printed by <code>bin/web</code>). Open it once; a cookie keeps you signed in.</div>'
    body = '<header><h1>CKA 14-day plan</h1><p class="soft">Generated from study-guide.md (section 5), COVERAGE.md, INDEX.md and docs/VERIFICATION.md on every request.</p></header>%s%s%s' % (
        login, facts, ''.join(day_card(d, ver, have) for d in DATA.days))
    return page('CKA study dashboard', body)


def p_day(n):
    d = next((x for x in DATA.days if x['n'] == n), None)
    if not d:
        return None
    ver, have = DATA.verification()
    return page('Day %d' % n, '<p><a href="/">&larr; plan</a></p>' + day_card(d, ver, have, full=True))


NOTES_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'study-notes')


def linkify_q(html):
    def sub(m):
        sid = m.group(0)
        qid = DATA.short_map.get(sid)
        return '<a href="/q/%s">%s</a>' % (E(qid), sid) if qid else sid
    out = []
    for part in re.split(r'(<a\b.*?</a>|<[^>]+>)', html, flags=re.S):
        out.append(part if part.startswith('<') else re.sub(r'\bq[0-9]{2,3}\b', sub, part))
    return ''.join(out)


def p_notes(n):
    d = next((x for x in DATA.days if x['n'] == n), None)
    if not d:
        return None
    ver, have = DATA.verification()
    toc = ' '.join('<a class="chip" href="#%s"><b>%s</b> %s</a>' % (s, s, E(DATA.secs[s]['title'] if s in DATA.secs else '')) for s in d['subs'])
    plan = ''.join(chip(s, ver=ver, have=have) for s in d['plan_qs']) or '<span class="soft">이 날짜에 배정된 문제 없음</span>'
    parts = ['<p><a href="/">&larr; plan</a> &middot; <a href="/day/%d">Day %d</a></p><h1>Day %d study notes</h1><p class="soft">%s</p>'
             '<section class="card"><div class="label">오늘 범위</div><div class="chips">%s</div><div class="label">오늘 풀 문제 (이 날짜 계획)</div><div class="chips">%s</div>'
             '<p class="soft" style="font-size:13px">각 항목 아래 &lsquo;연습 문제&rsquo;의 &lsquo;추가 연습&rsquo;은 다른 날 범위와 겹치는 문제입니다. 오늘은 건너뛰어도 됩니다.</p></section>' % (n, n, n, E(d['slice']), toc, plan)]
    for s in d['subs']:
        sec = DATA.secs.get(s)
        f = os.path.join(NOTES_DIR, s + '.md')
        if os.path.isfile(f):
            body = open(f, encoding='utf-8').read()
            body = re.sub(r'^# .*\n', '', body, count=1)
            body = re.sub(r'^(#{2,3}) ', lambda m: '#' + m.group(1) + ' ', body, flags=re.M)
            if n >= 11:  # review days cover many sub-competencies: keep the page light, open one at a time
                parts.append('<details id="%s"><summary><b>%s. %s</b></summary>%s</details>' % (s, s, E(sec['title'] if sec else ''), linkify_q(md_block(body))))
            else:
                parts.append('<h2 id="%s">%s. %s</h2>%s' % (s, s, E(sec['title'] if sec else ''), linkify_q(md_block(body))))
        elif sec:
            parts.append('<h2 id="%s">%s. %s</h2><p class="soft">(상세 노트 파일 study-notes/%s.md 없음: 요약만 표시)</p>%s' % (s, s, E(sec['title']), s, md_block(sec['md'])))
    return page('Day %d notes' % n, '\n'.join(parts))


def p_concepts():
    ver, have = DATA.verification()
    doms = sorted({c['domain'] for c in DATA.concepts})
    rows = []
    for c in DATA.concepts:
        fid = {'high': 'all high', 'mixed': 'mixed', 'nohigh': 'no high'}[c['fclass']]
        cls = {'high': 'good', 'mixed': 'warn', 'nohigh': 'bad'}[c['fclass']]
        rows.append('<tr data-domain="%s" data-fid="%s" data-low="%d"><td>%s</td><td class="label">%s</td><td>%s</td><td>%s</td><td><div class="chips">%s</div></td></tr>' % (
            E(c['domain']), c['fclass'], 1 if c['haslow'] else 0, E(c['name']), E(c['code']), E(c['domain']), pill(cls, fid),
            ''.join(chip(s, ver=ver, have=have) for s, _ in c['qs'])))
    flt = '<div class="filters"><select id="fd"><option value="">all domains</option>%s</select><select id="ff"><option value="">any fidelity</option><option value="high">all high</option><option value="mixed">mixed</option><option value="nohigh">no high-fidelity</option><option value="low">has low</option></select><input type="search" id="fq" placeholder="search"><span class="soft" id="cnt"></span></div>' % ''.join('<option>%s</option>' % E(x) for x in doms)
    js = '''(function(){var rs=[].slice.call(document.querySelectorAll('#ct tbody tr'));function f(){var d=fd.value,t=ff.value,q=fq.value.toLowerCase(),n=0;rs.forEach(function(r){var ok=(!d||r.dataset.domain===d)&&(!t||(t==='low'?r.dataset.low==='1':r.dataset.fid===t))&&(!q||r.textContent.toLowerCase().indexOf(q)>=0);r.hidden=!ok;if(ok)n++});cnt.textContent=n+' concepts'}
fd.onchange=ff.onchange=fq.oninput=f;f()})();'''
    body = '<h1>Concepts (%d)</h1>%s<div class="scroll"><table id="ct"><thead><tr><th>concept</th><th>sub</th><th>domain</th><th>fidelity</th><th>questions</th></tr></thead><tbody>%s</tbody></table></div>' % (len(DATA.concepts), flt, ''.join(rows))
    return page('Concepts', body, js)


def subst(md, q):
    host = ('ssh ' + q['host']) if q['host'] else ''
    return md.replace('{{context}}', q['context']).replace('{{namespace}}', q['namespace'] or 'default').replace('{{host}}', host)


def reset_help(q):
    lvl = q['reset']
    how = {'ns': '이 문제의 네임스페이스와 클러스터 범위 객체를 지우고 다시 만듭니다. 몇 초 걸립니다.',
           'cluster-soft': '이 문제가 건드리는 노드의 설정 파일(kubelet, static Pod 매니페스트 등)을 처음 상태로 복원하고 다시 만듭니다. 30~60초 걸리고, 그동안 해당 클러스터가 잠시 불안정할 수 있습니다.',
           'cluster-hard': '클러스터를 지우고 새로 만듭니다. 1~2분 걸리며 클러스터 안의 다른 작업도 모두 사라집니다.'}.get(lvl, '')
    hard = [c for k, c in q['conflicts'] if k in ('hard', 'ordering', 'row')]
    warn = ('<p><b>같이 풀면 안 되는 문제 / 순서 제약</b></p><ul>%s</ul>' % ''.join('<li>%s</li>' % E(c[:300]) for c in hard)) if hard else ''
    return ('<ul><li><b>Reset</b> (이 문제 화면의 버튼 또는 <code>bin/exam reset 1</code>): 이 문제만 처음 상태로 되돌립니다. 이 문제의 단계: <code>%s</code>. %s</li>'
            '<li><b>Start this question</b>: 새 문제를 시작하기 전에 직전 세션이 바꿔 둔 것(노드 label/taint, kubelet·매니페스트 수정 등)을 먼저 되돌립니다. 다른 문제 때문에 환경이 이상하면 먼저 <code>bin/exam cleanup</code>을 실행하세요.</li>'
            '<li>이상이 계속되면 <code>bin/sim doctor</code>로 점검하고, 클러스터를 통째로 새로 만들려면 <code>bin/sim recreate k8s</code> (또는 ek8s)를 실행합니다.</li></ul>%s') % (E(lvl), E(how), warn)


def p_question(qid):
    q = DATA.questions[qid]
    ver, have = DATA.verification()
    qd = os.path.join(D.QDIR, qid)
    qmd = subst(D.read(os.path.join(qd, 'question.md')), q)
    st, note = ver.get(q['short'], ('UNTESTED', 'no entry')) if have else ('unverified', 'docs/VERIFICATION.md absent')
    cons = [DATA.concepts[i] for i in DATA.q_concepts.get(q['short'], [])]
    days = DATA.q_days.get(q['short'], [])
    meta = ('<div class="facts"><div><b>%s</b><span>weight</span></div><div><b>%s</b><span>difficulty</span></div><div><b>%s min</b><span>time hint</span></div><div><b>%s</b><span>context</span></div><div><b>%s</b><span>reset level</span></div></div>' % (
        E(str(q['weight'])), E(q['difficulty']), E(str(q['time'] or '?')), E(q['context'] or '?'), E(q['reset'])))
    pills = ' '.join([fid_pill(q), ver_pill(q['short'], ver, have), pill('bad', 'destructive') if q['destructive'] == 'true' else '', pill('grey', q['domain'])])
    conf = ''
    if q['conflicts']:
        li = ''.join('<li><span class="label">%s</span> %s</li>' % (E(k), mdlite.inline(c)) for k, c in q['conflicts'])
        conf = '<div class="banner"><strong>Set conflicts / constraints</strong><ul>%s</ul></div>' % li
    doc = ''
    if q['doc'].startswith('http'):
        doc = '<p>Official doc: <a href="%s" target="_blank" rel="noopener noreferrer">%s</a></p>' % (E(q['doc']), E(q['doc']))
    cons_html = ''.join('<li>%s <span class="label">%s</span></li>' % (E(c['name']), E(c['code'])) for c in cons) or '<li class="soft">none</li>'
    cli = '''# 1. seed the task, start a practice session (host)
bin/exam practice %(id)s
# 2. work inside the exam terminal
bin/sim term
%(ctx)s
# 3. grade with full detail (host, or `exam check 1` inside the terminal)
bin/exam check 1
# 4. re-seed the task
bin/exam reset 1
# 5. peek at the solution (host only)
bin/exam solution 1 --force''' % dict(id=qid, ctx=('kubectl config use-context ' + q['context'] + ('    # then: ssh ' + q['host'] if q['host'] else '')) if q['context'] else '')
    hasss = qid in GRADED
    body = '''<p><a href="/concepts">&larr; concepts</a> &middot; <a href="/">plan</a></p>
<header><h1>%s</h1><div class="soft mono">%s</div><p>%s</p></header>
%s%s
<h2>Question</h2><div class="md">%s</div>
<h2>Actions</h2>
<div class="actions"><button id="b-start">Start this question</button><button id="b-term" class="sec">Open terminal</button><button id="b-grade">Grade</button><button id="b-reset" class="sec">Reset</button></div>
<details><summary class="soft">처음부터 다시 풀기 / 다른 문제에 영향을 줄 때</summary>%s</details>
<div id="out" class="out"></div><div id="res"></div>
<div id="termpanel" hidden></div>
<h2>Solution</h2>
<div class="actions"><button id="sol" class="sec" disabled>Show solution</button><label><input type="checkbox" id="giveup"> I give up, show it anyway</label></div>
<div id="solbox"></div>
<h2>Details</h2>
<div class="cols"><div class="card"><h3>Concepts</h3><ul>%s</ul><h3>Plan days</h3><p>%s</p></div>
<div class="card"><h3>Verification</h3><p>%s</p><p class="soft">%s</p></div></div>
%s
<h2>CLI equivalents</h2><pre class="term"><code>%s</code></pre>
%s''' % (E(q['title']), E(qid), pills, meta, conf, mdlite.render(qmd), reset_help(q), cons_html,
         ', '.join('<a href="/day/%d">Day %d</a>' % (d, d) for d in days) or '<span class="soft">not in a plan day list</span>',
         E(st.lower()), E(note), doc, E(cli),
         '<div class="banner">Dry-run mode: buttons only show the command that would run.</div>' if CFG['dry'] else '')
    return page(qid, body, QJS, ' data-qid="%s" data-graded="%d"' % (E(qid), 1 if hasss else 0))


def ttyd_path():
    p = shutil.which('ttyd')
    if p:
        return p
    for c in ('/opt/homebrew/bin/ttyd', '/usr/local/bin/ttyd'):
        if os.path.exists(c):
            return c
    return None


def ttyd_argv(path):
    return [path, '-i', '127.0.0.1', '-p', str(CFG['ttyd_port']), '-b', '/' + CFG['term_token'], '-W',
            'docker', 'exec', '-it', '-u', 'candidate', '-w', '/home/candidate', 'exam-term', 'tmux', 'new-session', '-A', '-s', 'exam']


def p_terminal():
    path = ttyd_path()
    cmd = shlex.join(ttyd_argv(path or 'ttyd'))
    if not path:
        inner = '<div class="banner"><strong>ttyd is not installed.</strong> Install it with <code>brew install ttyd</code> and reload. Until then use a normal terminal:</div><pre class="term">bin/sim term</pre>'
    else:
        inner = '<p>ttyd found at <code>%s</code>. Press <em>Open terminal</em> on any question page, or here:</p><div class="actions"><button id="b-term">Start terminal</button></div><div id="termpanel" hidden></div><pre class="term">%s</pre>' % (E(path), E(cmd))
    js = '''(function(){var $=function(i){return document.getElementById(i)};var b=$('b-term');if(!b)return;
function esc(s){var d=document.createElement('div');d.textContent=s==null?'':String(s);return d.innerHTML}
function post(u){return fetch(u,{method:'POST',credentials:'same-origin'}).then(function(r){return r.json()})}
b.onclick=function(){post('/api/term/start').then(function(j){var p=$('termpanel');p.hidden=false;
if(j.error||j.fallback||j.dry_run){p.innerHTML='<div class="banner">'+esc(j.error||(j.dry_run?'dry-run: would run':''))+'</div><pre class="term">'+esc(j.cmd||'bin/sim term')+'</pre>';return}
p.innerHTML='<iframe class="termf" src="'+esc(j.url)+'"></iframe>'}).catch(function(e){alert(e)})}})();'''
    return page('Terminal', '<h1>Exam terminal</h1><p class="soft">Web terminal into the exam-term container (user candidate, tmux session exam), the same as <code>bin/sim term</code>.</p>' + inner, js)


# ----------------------------------------------------------------- actions

def run_argv(argv, timeout=1500):
    cmd = shlex.join(argv)
    if CFG['dry']:
        return dict(argv=argv, cmd=cmd, dry_run=True, rc=None, output='(nothing executed)')
    if not LOCK.acquire(blocking=False):
        return dict(argv=argv, cmd=cmd, error='another action is still running', rc=None)
    try:
        r = subprocess.run(argv, cwd=D.SIM, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=timeout)
        return dict(argv=argv, cmd=cmd, dry_run=False, rc=r.returncode, output=ANSI.sub('', r.stdout + r.stderr))
    except subprocess.TimeoutExpired:
        return dict(argv=argv, cmd=cmd, error='timeout', rc=None)
    except OSError as e:
        return dict(argv=argv, cmd=cmd, error=str(e), rc=None)
    finally:
        LOCK.release()


def session_matches(qid):
    try:
        with open(os.path.join(STATE_SHARE, 'session.json')) as f:
            s = json.load(f)
        return s.get('questions') == [qid]
    except (OSError, ValueError):
        return False


def load_results(qid):
    try:
        with open(os.path.join(STATE_SHARE, 'results', qid + '.json')) as f:
            r = json.load(f)
        return [x for x in r if isinstance(x, dict)]
    except (OSError, ValueError):
        return []


def do_action(name, qid):
    if name == 'start':
        return run_argv([EXAM, 'practice', qid])
    if name in ('grade', 'reset'):
        if not CFG['dry'] and not session_matches(qid):
            return dict(error='No practice session for this question. Press "Start this question" first.', argv=None)
        r = run_argv([EXAM, 'check' if name == 'grade' else 'reset', '1'])
        if name == 'grade':
            GRADED.add(qid)
            r['results'] = load_results(qid)
            if CFG['dry'] and not r['results']:
                r['output'] += '\n(no previous result file; real grading is not run in dry-run)'
        else:
            GRADED.discard(qid)
        return r
    return dict(error='unknown action')


def term_start():
    path = ttyd_path()
    argv = ttyd_argv(path or 'ttyd')
    cmd = shlex.join(argv)
    if not path:
        return dict(fallback=True, error='ttyd is not installed. Run: brew install ttyd', cmd='bin/sim term')
    if CFG['dry']:
        return dict(dry_run=True, cmd=cmd + '   (preceded by: %s daemon-ensure)' % EXAM)
    url = 'http://127.0.0.1:%d/%s/' % (CFG['ttyd_port'], CFG['term_token'])
    p = TTYD['proc']
    if p and p.poll() is None:
        return dict(url=url, cmd=cmd)
    s = socket.socket()
    s.settimeout(0.5)
    if s.connect_ex(('127.0.0.1', CFG['ttyd_port'])) == 0:
        s.close()
        return dict(error='port %d is already in use by another process' % CFG['ttyd_port'], fallback=True, cmd='bin/sim term')
    s.close()
    if subprocess.run(['docker', 'inspect', '-f', '{{.State.Running}}', 'exam-term'], capture_output=True, text=True).stdout.strip() != 'true':
        return dict(error='exam-term is not running (bin/sim up)', fallback=True, cmd='bin/sim term')
    subprocess.run([EXAM, 'daemon-ensure'], cwd=D.SIM, stdin=subprocess.DEVNULL, capture_output=True)
    TTYD['proc'] = subprocess.Popen(argv, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(0.8)
    if TTYD['proc'].poll() is not None:
        return dict(error='ttyd exited immediately', fallback=True, cmd=cmd)
    return dict(url=url, cmd=cmd)


def term_stop():
    p = TTYD['proc']
    if p and p.poll() is None:
        p.terminate()
    TTYD['proc'] = None
    return dict(ok=True)


# ----------------------------------------------------------------- http

class _Flag(threading.local):
    val = False


cookie_ok_now = _Flag()


class H(BaseHTTPRequestHandler):
    server_version = 'ckaweb'

    def log_message(self, fmt, *a):
        if os.environ.get('CKA_WEB_LOG'):
            sys.stderr.write('%s\n' % (fmt % a))

    def _host_ok(self):
        h = self.headers.get('Host', '')
        return h in ('127.0.0.1:%d' % CFG['port'], 'localhost:%d' % CFG['port'])

    def _cookie_ok(self):
        for part in self.headers.get('Cookie', '').split(';'):
            k, _, v = part.strip().partition('=')
            if k == 'cka_tok' and secrets.compare_digest(v, CFG['token']):
                return True
        return False

    def _send(self, code, body, ctype='text/html; charset=utf-8', extra=()):
        b = body.encode('utf-8') if isinstance(body, str) else body
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(b)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Referrer-Policy', 'no-referrer')
        for k, v in extra:
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(b)

    def _json(self, code, obj):
        self._send(code, json.dumps(obj), 'application/json')

    def _err(self, code, msg):
        self._send(code, page('Error', '<h1>%d</h1><p>%s</p><p><a href="/">home</a></p>' % (code, E(msg))))

    def do_GET(self):
        if not self._host_ok():
            return self._err(403, 'bad Host header')
        u = urlparse(self.path)
        qs = parse_qs(u.query)
        if 'token' in qs:
            ok = secrets.compare_digest(qs['token'][0], CFG['token'])
            if not ok:
                return self._err(403, 'bad token')
            return self._send(302, '', extra=[('Location', u.path or '/'), ('Set-Cookie', 'cka_tok=%s; Path=/; HttpOnly; SameSite=Strict' % CFG['token'])])
        cookie_ok_now.val = self._cookie_ok()
        DATA.refresh()
        path = u.path
        try:
            if path == '/':
                return self._send(200, p_home())
            m = re.fullmatch(r'/day/(\d{1,2})(/notes)?', path)
            if m:
                r = (p_notes if m.group(2) else p_day)(int(m.group(1)))
                return self._send(200, r) if r else self._err(404, 'no such day')
            if path == '/concepts':
                return self._send(200, p_concepts())
            m = re.fullmatch(r'/q/([^/]+)', path)
            if m:
                qid = m.group(1)
                if not D.QID_RE.match(qid):
                    return self._err(400, 'invalid question id')
                if qid not in DATA.questions and qid in DATA.short_map:
                    return self._send(302, '', extra=[('Location', '/q/' + DATA.short_map[qid])])
                if qid not in DATA.questions:
                    return self._err(404, 'no such question')
                return self._send(200, p_question(qid))
            if path == '/terminal':
                if not self._cookie_ok():
                    return self._err(403, 'open the launch URL with ?token= first')
                return self._send(200, p_terminal())
            if path == '/healthz':
                return self._json(200, dict(ok=True, dry_run=CFG['dry']))
        except Exception as e:  # keep the server alive on partial/odd source files
            return self._err(500, 'render error: %r' % e)
        return self._err(404, 'not found')

    def do_POST(self):
        if not self._host_ok():
            return self._json(403, dict(error='bad Host header'))
        origin = self.headers.get('Origin')
        if origin is not None and origin not in ('http://127.0.0.1:%d' % CFG['port'], 'http://localhost:%d' % CFG['port']):
            return self._json(403, dict(error='cross-origin request rejected'))
        if origin is None and self.headers.get('Sec-Fetch-Site', 'same-origin') not in ('same-origin', 'none'):
            return self._json(403, dict(error='cross-site request rejected'))
        if not self._cookie_ok():
            return self._json(403, dict(error='missing token: open the launch URL printed by bin/web'))
        try:
            ln = min(int(self.headers.get('Content-Length', '0') or 0), 4096)
        except ValueError:
            ln = 0
        body = parse_qs(self.rfile.read(ln).decode('utf-8', 'replace')) if ln else {}
        path = urlparse(self.path).path
        DATA.refresh()
        if path == '/api/term/start':
            return self._json(200, term_start())
        if path == '/api/term/stop':
            return self._json(200, term_stop())
        m = re.fullmatch(r'/api/(start|grade|reset|solution)/([^/]+)', path)
        if not m:
            return self._json(404, dict(error='not found'))
        name, qid = m.groups()
        if not D.QID_RE.match(qid) or qid not in DATA.questions:
            return self._json(400, dict(error='invalid question id'))
        if name == 'solution':
            ack = (body.get('ack') or [''])[0]
            if not (ack == 'giveup' or (ack == 'graded' and qid in GRADED)):
                return self._json(403, dict(error='Press Grade at least once, or tick the give-up box.'))
            md = subst(D.read(os.path.join(D.QDIR, qid, 'solution.md')), DATA.questions[qid])
            return self._json(200, dict(html=mdlite.render(md) if md else '<p>No solution.md.</p>'))
        return self._json(200, do_action(name, qid))


def summary():
    DATA.refresh()
    ver, have = DATA.verification()
    nconf = sum(len(q['conflicts']) > 0 for q in DATA.questions.values())
    lines = ['days: %d' % len(DATA.days), 'concepts: %d' % len(DATA.concepts), 'questions: %d (indexed in INDEX.md: %d)' % (len(DATA.questions), sum(q['indexed'] for q in DATA.questions.values())),
             'study-guide sub-competency sections: %d' % len(DATA.secs), 'questions with conflict warnings: %d' % nconf,
             'VERIFICATION.md: %s' % (('present, %d entries' % len(ver)) if have else 'absent (shown as unverified)'),
             'ttyd: %s' % (ttyd_path() or 'NOT FOUND (brew install ttyd); web terminal falls back to bin/sim term')]
    for d in DATA.days:
        lines.append('  day %2d  subs=%-3d concepts=%-3d plan questions=%d  %s' % (d['n'], len(d['subs']), len(d['concepts']), len(d['plan_qs']), d['slice']))
    unmapped = [q for q in DATA.questions if DATA.questions[q]['short'] not in DATA.q_concepts]
    lines.append('questions not in any concept: %d' % len(unmapped))
    return '\n'.join(lines)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--port', type=int, default=8765)
    ap.add_argument('--ttyd-port', type=int, default=7681)
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--no-open', action='store_true')
    a = ap.parse_args()
    if a.check:
        print(summary())
        return 0
    CFG.update(dry=a.dry_run, port=a.port, ttyd_port=a.ttyd_port, token=secrets.token_urlsafe(24), term_token=secrets.token_urlsafe(16))
    try:
        srv = ThreadingHTTPServer(('127.0.0.1', a.port), H)
    except OSError as e:
        print('cannot bind 127.0.0.1:%d: %s' % (a.port, e), file=sys.stderr)
        return 1
    url = 'http://127.0.0.1:%d/?token=%s' % (a.port, CFG['token'])
    print('CKA study dashboard%s\n  %s' % (' (DRY-RUN: actions are only echoed)' if a.dry_run else '', url), flush=True)
    if not a.no_open and sys.platform == 'darwin':
        subprocess.Popen(['open', url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        term_stop()
    return 0


if __name__ == '__main__':
    sys.exit(main())
