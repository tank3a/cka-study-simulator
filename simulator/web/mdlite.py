"""Tiny self-contained markdown renderer (stdlib only): headings, fences, tables, nested lists, quotes, inline code/bold/italic/links."""
import html
import re

_URL = re.compile(r'(?<![">=(])(https?://[^\s<>)\]"`]+[^\s<>)\]"`.,;:])')


def inline(text):
    text = html.escape(text, quote=False)
    codes = []

    def stash(m):
        codes.append('<code>%s</code>' % m.group(1))
        return '\x00%d\x00' % (len(codes) - 1)
    text = re.sub(r'`([^`]+)`', stash, text)
    # explicit links [t](url)
    def link(m):
        u = m.group(2)
        ext = u.startswith('http')
        return '<a href="%s"%s>%s</a>' % (u, ' target="_blank" rel="noopener noreferrer"' if ext else '', m.group(1))
    text = re.sub(r'\[([^\]]+)\]\(((?:https?://|/)[^)\s]+)\)', link, text)
    text = _URL.sub(lambda m: '<a href="%s" target="_blank" rel="noopener noreferrer">%s</a>' % (m.group(1), m.group(1)), text)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'(?<![\w*])\*([^*\s][^*]*)\*(?![\w*])', r'<em>\1</em>', text)
    return re.sub(r'\x00(\d+)\x00', lambda m: codes[int(m.group(1))], text)


_LI = re.compile(r'^(\s*)([-*]|\d+\.)\s+(.*)$')


def render(md):
    lines = md.replace('\r\n', '\n').split('\n')
    out = []
    i = 0
    n = len(lines)
    para = []

    def flush():
        if para:
            out.append('<p>%s</p>' % inline(' '.join(s.strip() for s in para)))
            para.clear()

    while i < n:
        ln = lines[i]
        fm = re.match(r'^(\s*)```\s*([\w+-]*)\s*$', ln)
        if fm:
            flush()
            ind = len(fm.group(1))
            i += 1
            buf = []
            while i < n and not re.match(r'^\s*```\s*$', lines[i]):
                buf.append(lines[i][ind:] if lines[i][:ind].strip() == '' else lines[i])
                i += 1
            i += 1
            out.append('<pre class="term"><code>%s</code></pre>' % html.escape('\n'.join(buf)))
            continue
        if not ln.strip():
            flush(); i += 1; continue
        hm = re.match(r'^(#{1,6})\s+(.*)$', ln)
        if hm:
            flush()
            lvl = min(len(hm.group(1)) + 1, 6)
            out.append('<h%d>%s</h%d>' % (lvl, inline(hm.group(2)), lvl)); i += 1; continue
        if re.match(r'^\s*(---+|\*\*\*+)\s*$', ln):
            flush(); out.append('<hr>'); i += 1; continue
        if ln.lstrip().startswith('>'):
            flush()
            buf = []
            while i < n and lines[i].lstrip().startswith('>'):
                buf.append(re.sub(r'^\s*>\s?', '', lines[i])); i += 1
            out.append('<blockquote>%s</blockquote>' % render('\n'.join(buf))); continue
        if ln.lstrip().startswith('|') and i + 1 < n and re.match(r'^\s*\|?\s*:?-{2,}', lines[i + 1]):
            flush()
            def cells(s):
                s = s.strip()
                if s.startswith('|'): s = s[1:]
                if s.endswith('|'): s = s[:-1]
                return [c.strip() for c in s.split('|')]
            head = cells(ln); i += 2
            rows = []
            while i < n and lines[i].lstrip().startswith('|'):
                rows.append(cells(lines[i])); i += 1
            t = '<div class="scroll"><table><thead><tr>%s</tr></thead><tbody>' % ''.join('<th>%s</th>' % inline(c) for c in head)
            for r in rows:
                t += '<tr>%s</tr>' % ''.join('<td>%s</td>' % inline(c) for c in r)
            out.append(t + '</tbody></table></div>'); continue
        lm = _LI.match(ln)
        if lm:
            flush()
            # collect list block with nesting by indent
            stack = []  # (indent, kind)
            html_l = []
            while i < n:
                lm = _LI.match(lines[i])
                if not lm:
                    if lines[i].strip() and lines[i].startswith(' ') and html_l and not re.match(r'^\s*```', lines[i]):
                        html_l[-1] += ' ' + inline(lines[i].strip()); i += 1; continue
                    break
                ind = len(lm.group(1).replace('\t', '    '))
                kind = 'ol' if lm.group(2)[0].isdigit() else 'ul'
                while stack and ind < stack[-1][0]:
                    html_l.append('</li></%s>' % stack.pop()[1])
                if stack and ind == stack[-1][0]:
                    html_l.append('</li>')
                elif not stack or ind > stack[-1][0]:
                    attr = ''
                    if kind == 'ol' and lm.group(2) != '1.':
                        attr = ' start="%s"' % lm.group(2)[:-1]
                    html_l.append('<%s%s>' % (kind, attr)); stack.append((ind, kind))
                html_l.append('<li>')
                html_l.append(inline(lm.group(3)))
                i += 1
            while stack:
                html_l.append('</li></%s>' % stack.pop()[1])
            # merge consecutive text chunks that were appended as continuation
            out.append(''.join(html_l)); continue
        para.append(ln); i += 1
    flush()
    return '\n'.join(out)
