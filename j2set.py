#!/usr/bin/python
#
# j2set.py - Converts JUNOS bracket-style configuration into "display set" style
# Author   - Berislav Todorovic <btodorovic@juniper.net>
#

import re
import sys

if (len(sys.argv) < 2):
    file = open('/dev/stdin', 'r')
else:
    file = open(sys.argv[1], 'r')

ann = 0
quote = 0
comment = 0
buffer = ''
config = []
set = []

for line in file.readlines():
    line = re.sub(r'\r+$', '', line)
    line = re.sub(r'^\s+', '', line)

    for ch in line:
        if ch == '\n':
	    comment = 0
	    break
        if ch == '#' and not quote:
	    comment = 1
	    continue
        if ch == '*' and prevchar == '/' and not quote and not ann:
	    ann = 1
	    prevchar = ch
	    buffer = ''
	    continue
        if ch == '"' and not ann:
	    quote ^= 1
	    buffer += ch
	    prevchar = ch
	    continue
        if ch == '/' and prevchar == '*' and not quote and ann:
	    ann = 0
	    prevchar = ch
	    buffer = ''
	    continue
        if comment or ann:
	    continue
        if ch == ' ' and prevchar == ' ' and not quote:
	    continue
        if ch == '{' and not quote:
	    config.append(buffer)
	    buffer = ''
	    continue
        if ch == '}' and not quote:
	    config.pop()
	    continue
        if ch == ';' and not quote:
	    set_cmd = 'set '
	    for level in config:
	        set_cmd += level
	    set_cmd += buffer
	    set.append(set_cmd)
	    buffer = ''
	    continue
        if (ord(ch)<32 or ord(ch)>127):
	    continue

        buffer += ch
        prevchar = ch

prev_cmd = ''
for cmd in set:
    if ('inactive:') in cmd:
	w = cmd.split(' ')
	inactive_term = w[w.index('inactive:')+1]
	cmd = re.sub('^set', 'deactivate', cmd)
	cmd = re.sub('inactive:.*$', '', cmd)
	cmd += inactive_term
    if cmd != prev_cmd:
        print cmd
    prev_cmd = cmd
