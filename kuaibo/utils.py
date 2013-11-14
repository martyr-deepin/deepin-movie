#! /usr/bin/env python
# -*- coding: utf-8 -*-

import time
import random
import string
import hashlib

# try:
#     import simplejson as json
# except ImportError:    
import json

    
from xdg import get_cache_file    

def parser_json(raw):
    try:
        data = json.loads(raw)
    except Exception, e:    
        print e
        try:
            data = eval(raw, type("Dummy", (dict,), dict(__getitem__=lambda s,n: n))())
        except:    
            data = {}
    return data    

def timestamp():
    return int(time.time() * 1000)


def get_random_t():
    return random.random()


def radix(n, base=36):
    digits = string.digits + string.lowercase
    def short_div(n, acc=list()):
        q, r = divmod(n, base)
        return [r] + acc if q == 0 else short_div(q, [r] + acc)
    return ''.join(digits[i] for i in short_div(n))

def timechecksum():
    return radix(timestamp())

def get_cookie_file(username):
    return get_cache_file(hashlib.md5(username).hexdigest())

def format_size(num, unit='B'):
    next_unit_map = dict(B="K", K="M", M="G", G="T")
    if num > 1024:
        return format_size(num/1024, next_unit_map[unit])
    if num == 0:
        return "0%s  " % unit   # padding
    if unit == 'B':
        return "%.0f%s" % (num, unit)
    return "%.1f%s" % (num, unit)



