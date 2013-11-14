#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os

PROGRAM_NAME = "deepin-movie-plugins"

_home = os.path.expanduser('~')
xdg_cache_home = os.environ.get('XDG_CACHE_HOME') or \
            os.path.join(_home, '.cache')

def get_cache_file(path):
    ''' get cache file. '''
    cachefile = os.path.join(xdg_cache_home, PROGRAM_NAME, path)
    cachedir = os.path.dirname(cachefile)
    if not os.path.isdir(cachedir):
        os.makedirs(cachedir)
    return cachefile    
