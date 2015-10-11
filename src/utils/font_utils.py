#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 ~ 2015 Deepin, Inc.
#               2014 ~ 2015 Wang YaoHua
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

import locale
from ctypes import *

try:
    libfc = cdll.LoadLibrary("libfontconfig.so")
except:
    libfc = cdll.LoadLibrary("libfontconfig.so.1")

# initialize
libfc.FcInit()
libfc.FcPatternCreate.restype = c_void_p
pattern = libfc.FcPatternCreate()
libfc.FcObjectSetBuild.restype = c_void_p
objectSet = libfc.FcObjectSetBuild("family", "familylang",
                                   "lang", "spacing", None)

class FcPattern(Structure):
    _fields_ = [
        ("num", c_int),
        ("size", c_int),
        ("elts_offset", POINTER(c_int)),
        ("ref", c_int)
    ]

class FcFontSet(Structure):
    _fields_ = [
        ("nfont", c_int),
        ("sfont", c_int),
        ("fonts", POINTER(POINTER(FcPattern)))
    ]

class FcStrSet(Structure):
    _fields_ = [
        ("ref", c_int),
        ("num", c_int),
        ("size", c_int),
        ("strs", POINTER(c_char_p))
    ]

class FcLangSet(Structure):
    _fields_ = [
        ("extra", POINTER(FcStrSet)),
        ("map_size", c_uint),
        ("map", c_uint * 8),
    ]

def _familyNameInfo(family, familyLang, locale):
    familyInfo = family.split(",")
    familyLangInfo = familyLang.split(",")

    familyNameEn = familyInfo[0]
    familyNameLocale = familyNameEn

    if "en" in familyLangInfo:
        familyNameEn = familyInfo[familyLangInfo.index("en")]

    for _familyLang in familyLangInfo:
        if _familyLang.startswith(locale):
            familyNameLocale = familyInfo[familyLangInfo.index(_familyLang)]

    return (familyNameEn, familyNameLocale)

def fontsByLocale(locale):
    result = []
    locale = locale.lower().replace("_", "-")

    # get all fonts
    libfc.FcFontList.restype = POINTER(FcFontSet)
    libfc.FcFontList.argtypes = [c_void_p] * 3
    libfc.FcLangSetGetLangs.restype = POINTER(FcStrSet)
    libfc.FcStrListNext.restype = c_char_p
    libfc.FcPatternFormat.restype = c_char_p

    fontSet = libfc.FcFontList(None, pattern, objectSet)
    fontCount = fontSet.contents.nfont

    # iterate on the fonts
    for i in range(fontCount):
        _pattern = fontSet.contents.fonts[i]

        # _family = c_char_p()
        # _familyLang = c_char_p()
        # langSet = POINTER(FcLangSet)()

        # libfc.FcPatternGetString(_pattern, "family", 0, byref(_family))
        # libfc.FcPatternGetString(_pattern, "familylang", 0, byref(_familyLang))
        # libfc.FcPatternGetLangSet(_pattern, "lang", 0, byref(langSet))

        # langStrSet = libfc.FcLangSetGetLangs(langSet)
        # langStrList = libfc.FcStrListCreate(langStrSet)
        # libfc.FcStrListFirst(langStrList)
        # _lang = libfc.FcStrListNext(langStrList)
        # while (_lang):
        #   if _lang.startswith(lang):
        #       print _family.value, _familyLang.value
        #       result.append(_family.value)
        #       break
        #   _lang = libfc.FcStrListNext(langStrList)
        # libfc.FcStrListDone(langStrList)

        family = libfc.FcPatternFormat(_pattern, c_char_p("%{family}"))
        familyLang = libfc.FcPatternFormat(_pattern, c_char_p("%{familylang}"))
        lang = libfc.FcPatternFormat(_pattern, c_char_p("%{lang}"))
        spacing = libfc.FcPatternFormat(_pattern, c_char_p("%{spacing}"))

        isMono = spacing == "100" or "mono" in family.lower()
        isCurrentLangSupport = filter(lambda x: x.startswith(locale), lang.split("|"))
        if isMono or isCurrentLangSupport:
            try:
                en, localized = _familyNameInfo(family, familyLang, locale)
                if not filter(lambda (x, y): x == en, result):
                    result.append([en, localized])
            except:
                pass

    return result

def getSystemFonts():
    return fontsByLocale(locale.getdefaultlocale()[0])