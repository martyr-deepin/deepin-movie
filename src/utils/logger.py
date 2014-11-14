#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2014 Deepin, Inc.
#               2011 ~ 2014 Wang YaoHua
#
# Author:     Wang YaoHua <mr.asianwang@gmail.com>
# Maintainer: Wang YaoHua <mr.asianwang@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import logging
import inspect
import functools

SIMPLE = "_logger_simple_"
DETAIL = "_logger_detail_"

# Color escape string
COLOR_RED='\033[1;31m'
COLOR_GREEN='\033[1;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[1;34m'
COLOR_PURPLE='\033[1;35m'
COLOR_CYAN='\033[1;36m'
COLOR_GRAY='\033[1;37m'
COLOR_WHITE='\033[1;38m'
COLOR_RESET='\033[1;0m'

LOG_COLORS = {
        'DEBUG': '%s',
        'INFO': COLOR_GREEN + '%s' + COLOR_RESET,
        'WARNING': COLOR_YELLOW + '%s' + COLOR_RESET,
        'ERROR': COLOR_RED + '%s' + COLOR_RESET,
        'CRITICAL': COLOR_RED + '%s' + COLOR_RESET,
        'EXCEPTION': COLOR_RED + '%s' + COLOR_RESET,
}

class ColoredFormatter(logging.Formatter):
    '''A colorful formatter.'''

    def __init__(self, fmt = None, datefmt = None):
        logging.Formatter.__init__(self, fmt, datefmt)

    def format(self, record):
        level_name = record.levelname
        msg = logging.Formatter.format(self, record)

        return LOG_COLORS.get(level_name, '%s') % msg

logger = logging.getLogger('DMovie')
logger.setLevel(logging.DEBUG)

ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

formatter = ColoredFormatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

ch.setFormatter(formatter)
logger.addHandler(ch)

def func_logger(level=SIMPLE):
    def wrapper_1(fn):
        def wrapper_0(*args, **kwds):
            if level == SIMPLE:
                logger.debug(fn.func_name)
            else:
                logger.debug(fn.func_name)
                logger.debug(inspect.getcallargs(fn, *args, **kwds))
            return fn(*args, **kwds)
        return wrapper_0
        functools.update_wrapper(wrapper_1, fn)
    return wrapper_1

if __name__ == "__main__":
    @func_logger()
    def test_function(a, b="b"):
        print "test_function inner"

    test_function("a")

    logger.info("hello")
    logger.debug("hello")
    logger.warning("hello")
    logger.error("hello")