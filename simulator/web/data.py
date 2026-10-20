"""Parsers: everything is derived from study-guide.md, COVERAGE.md, INDEX.md, question folders and docs/VERIFICATION.md."""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SIM = os.path.dirname(HERE)
CKA = os.path.dirname(SIM)
GUIDE = os.path.join(CKA, 'study-guide.md')
QDIR = os.path.join(SIM, 'questions')
COVERAGE = os.path.join(QDIR, 'COVERAGE.md')
INDEX = os.path.join(QDIR, 'INDEX.md')
VERIF = os.path.join(SIM, 'docs', 'VERIFICATION.md')
QID_RE = re.compile(r'^q[0-9]{2,3}(-[a-z0-9-]+)?$')


def read(p):
    try:
        with open(p, encoding='utf-8') as f:
            return f.read()
    except OSError:
        return ''


def yaml_simple(text):
    d = {}
    for ln in text.splitlines():
        m = re.match(r'^([A-Za-z_]+):\s*(.*?)\s*(?:\s#.*)?$', ln)
        if m:
            v = m.group(2).strip('"\'')
            d[m.group(1)] = '' if v in ('null', '~') else v
    return d


def fid_class(s):
    s = (s or '').lower()
    for k in ('high', 'partial', 'low', 'medium'):
        if s.startswith(k):
            return k
    return 'unknown'


def short(qid):
    return qid.split('-')[0]


def parse_index():
    """question rows + consolidated conflicts"""
    txt = read(INDEX)
    rows = {}
    for ln in txt.splitlines():
        if not re.match(r'^\|\s*q[0-9]{2,3}-', ln):
            continue
        s = ln.strip()[1:-1] if ln.strip().endswith('|') else ln.strip()[1:]
        c = [x.strip() for x in s.split(' | ')]
        if len(c) < 10:
            continue
        if len(c) > 10:
            c = c[:9] + [' | '.join(c[9:])]
        rows[c[0]] = dict(id=c[0], title=c[1], domain=c[2], concept=c[3], sub=c[4], doc=c[8], conflicts=c[9])
    # consolidated conflict items
    items = []
    on = False
    kind = 'hard'
    for ln in txt.splitlines():
        if ln.startswith('## '):
            on = 'Set conflicts' in ln
            continue
        if not on:
            continue
        if ln.startswith('Hard conflicts'):
            kind = 'hard'
        elif ln.startswith('Ordering'):
            kind = 'ordering'
        elif ln.startswith('Shared state'):
            kind = 'shared'
        m = re.match(r'^\d+\.\s+(.*)$', ln)
        if m:
            items.append((kind, m.group(1)))
    return rows, items


def parse_coverage():
    concepts = []
    for ln in read(COVERAGE).splitlines():
        if not ln.startswith('| ') or ln.startswith('| concept') or ln.startswith('|---'):
            continue
        c = [x.strip() for x in ln.strip().strip('|').split(' | ')]
        if len(c) != 7:
            continue
        qs = re.findall(r'(q[0-9]{2,3})\s+([HPLM])', c[3])
        if not qs:
            continue
        concepts.append(dict(name=c[0], sub=c[1], code=c[1].split()[0], domain=c[2],
                             qs=qs, count=int(c[4]) if c[4].isdigit() else len(qs)))
    return concepts


def expand_subs(text, allcodes):
    codes = []
    if re.search(r'전\s*영역', text):
        return list(allcodes)
    for m in re.finditer(r'([A-E])(\d)\s*~\s*([A-E])(\d)', text):
        if m.group(1) == m.group(3):
            for k in range(int(m.group(2)), int(m.group(4)) + 1):
                codes.append('%s%d' % (m.group(1), k))
    rest = re.sub(r'([A-E])(\d)\s*~\s*([A-E])(\d)', ' ', text)
    for m in re.finditer(r'(?<![A-Za-z0-9])([A-E])(\d)(?![0-9])', rest):
        codes.append(m.group(1) + m.group(2))
    seen = []
    for c in codes:
        if c in allcodes and c not in seen:
            seen.append(c)
    return seen


def parse_guide():
    txt = read(GUIDE)
    lines = txt.splitlines()
    # section 3 sub-competency blocks
    secs = {}
    cur = None
    in3 = False
    for ln in lines:
        if ln.startswith('## '):
            in3 = ln.startswith('## 3.')
            cur = None
            continue
        if not in3:
            continue
        m = re.match(r'^####\s+([A-E]\d)\.\s+(.*)$', ln)
        if m:
            cur = m.group(1)
            secs[cur] = dict(code=cur, title=m.group(2), body=[])
            continue
        if ln.startswith('###'):
            cur = None
            continue
        if cur:
            secs[cur]['body'].append(ln)
    for s in secs.values():
        s['md'] = '\n'.join(s['body']).strip()
    # plan table
    days = []
    in5 = False
    for ln in lines:
        if ln.startswith('## '):
            in5 = ln.startswith('## 5.')
            continue
        if in5:
            m = re.match(r'^\|\s*(\d+)\s*\|(.*)\|\s*$', ln)
            if m:
                c = [x.strip() for x in m.group(2).split('|')]
                if len(c) >= 4:
                    days.append(dict(n=int(m.group(1)), slice=c[0], subs_raw=c[1], tools=c[2], qraw=c[3]))
    return secs, days


def parse_verification():
    """returns {short_id: (status, note)}; tolerant of missing/partial content."""
    txt = read(VERIF)
    out = {}
    if not txt:
        return out, False
    for ln in txt.splitlines():
        ids = re.findall(r'\bq[0-9]{2,3}\b', ln)
        if not ids:
            continue
        sts = [{'VERIFIED-PARTIAL': 'PARTIAL', 'FAILED-UNFIXED': 'FAILED', 'DEFERRED-SERIAL': 'DEFERRED'}.get(w, w)
               for w in re.findall(r'\b(VERIFIED-PARTIAL|FAILED-UNFIXED|DEFERRED-SERIAL|VERIFIED|PARTIAL|FAILED|UNTESTED)\b', ln.upper())]
        if not sts or len(set(sts)) >= 3:
            continue
        note = re.sub(r'\s+', ' ', ln.strip().strip('|')).strip()[:300]
        for i in ids[:1] if ln.lstrip().startswith('|') or ln.lstrip()[:1] in '-*#' else ids:
            out[i] = (sts[0], note)
    return out, True


class Data:
    def __init__(self):
        self.stamp = None
        self.load()

    def srcs(self):
        return [GUIDE, COVERAGE, INDEX, QDIR]

    def _stamp(self):
        s = []
        for p in self.srcs():
            try:
                s.append(os.stat(p).st_mtime_ns)
            except OSError:
                s.append(0)
        return tuple(s)

    def refresh(self):
        if self._stamp() != self.stamp:
            self.load()

    def load(self):
        self.stamp = self._stamp()
        rows, items = parse_index()
        self.conflict_items = items
        self.questions = {}
        try:
            names = sorted(os.listdir(QDIR))
        except OSError:
            names = []
        for nme in names:
            d = os.path.join(QDIR, nme)
            if not QID_RE.match(nme) or nme.startswith('q00') or not os.path.isfile(os.path.join(d, 'question.yaml')):
                continue
            y = yaml_simple(read(os.path.join(d, 'question.yaml')))
            r = rows.get(nme, {})
            self.questions[nme] = dict(
                id=nme, short=short(nme), title=y.get('title') or r.get('title', nme),
                domain=r.get('domain') or y.get('domain', ''), weight=y.get('weight', '?'),
                difficulty=y.get('difficulty', '?'), fidelity=y.get('fidelity') or '', fid=fid_class(y.get('fidelity')),
                context=y.get('context', ''), host=y.get('host', ''), namespace=y.get('namespace', ''),
                destructive=y.get('destructive', 'false'), reset=y.get('reset', 'ns'), time=y.get('time_hint_min', ''),
                requires=y.get('requires', ''), doc=r.get('doc', ''), col_conflict=r.get('conflicts', '—'),
                sub=r.get('sub', ''), indexed=nme in rows, conflicts=[])
        self.short_map = {q['short']: q['id'] for q in self.questions.values()}
        # conflicts from consolidated list + per-row column
        for kind, text in items:
            for sid in set(re.findall(r'\bq[0-9]{2,3}\b', text)):
                q = self.questions.get(self.short_map.get(sid, ''))
                if q is not None:
                    q['conflicts'].append((kind, text))
        for q in self.questions.values():
            c = q['col_conflict']
            if c and c not in ('—', '-', ''):
                q['conflicts'].append(('row', c))
        self.concepts = parse_coverage()
        self.secs, self.days = parse_guide()
        allcodes = list(self.secs.keys())
        # reverse: concepts per question
        self.q_concepts = {}
        for ci, c in enumerate(self.concepts):
            c['idx'] = ci
            for sid, f in c['qs']:
                self.q_concepts.setdefault(sid, []).append(ci)
            fs = [f for _, f in c['qs']]
            c['fclass'] = 'high' if all(f == 'H' for f in fs) else ('nohigh' if 'H' not in fs else 'mixed')
            c['haslow'] = 'L' in fs
        for d in self.days:
            d['subs'] = expand_subs(d['subs_raw'], allcodes)
            d['plan_qs'] = []
            for sid in re.findall(r'\bq[0-9]{2,3}\b', d['qraw']):
                if sid in self.short_map and sid not in d['plan_qs']:
                    d['plan_qs'].append(sid)
            d['concepts'] = [c for c in self.concepts if c['code'] in d['subs']]
        self.q_days = {}
        for d in self.days:
            for sid in d['plan_qs']:
                self.q_days.setdefault(sid, []).append(d['n'])

    def verification(self):
        return parse_verification()
