# encoding: utf-8

'''
Exports your dotjs scripts (in ~/.js) and styles (in ~/.css) to a format
that can be imported by Custom Web. See https://github.com/sharat87/custom-web.

The exported data is printed to stdout.
'''

import os
from glob import glob
from collections import defaultdict
from itertools import chain
import json

data = defaultdict(lambda: {'css': '', 'js': ''})
patterns = ['~/.js/*.js', '~/.css/*.css']

for fname in chain(*(glob(os.path.expanduser(pat)) for pat in patterns)):
    domain, ext = os.path.splitext(os.path.basename(fname))
    with open(fname) as f:
        data[domain][ext[1:]] = f.read()

print(json.dumps({'codes': data}, indent=4, separators=(',', ': '), sort_keys=True))
