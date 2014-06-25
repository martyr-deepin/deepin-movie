#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2012 Deepin, Inc.
#               2011 ~ 2012 Wang Yong
#
# Author:     Wang Yong <lazycat.manatee@gmail.com>
# Maintainer: Wang Yong <lazycat.manatee@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY"," without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import json
import subprocess

import gio
from PyQt5.QtWidgets import QApplication
from PyQt5.QtGui import QKeySequence
from PyQt5.QtCore import QObject, pyqtSlot, pyqtProperty
from PyQt5.QtDBus import QDBusInterface, QDBusConnection

from subtitles import *

all_supported_video_exts = [ "*.3g2","*.3gp","*.3gp2","*.3gpp","*.amv",
                            "*.asf","*.avi","*.bin","*.divx","*.drc",
                            "*.dv","*.f4v","*.flv","*.gvi","*.gxf","*.iso",
                            "*.m1v","*.m2v","*.m2t","*.m2ts","*.m4v","*.mkv",
                            "*.mov","*.mp2","*.mp2v","*.mp4","*.mp4v","*.mpe",
                            "*.mpeg","*.mpeg1","*.mpeg2","*.mpeg4","*.mpg",
                            "*.mpv2","*.mts","*.mtv","*.mxf","*.mxg","*.nsv",
                            "*.nuv","*.ogg","*.ogm","*.ogv","*.ogx","*.ps",
                            "*.rec","*.rm","*.rmvb","*.tod","*.ts","*.tts",
                            "*.vob","*.vro","*.webm","*.wm","*.wmv","*.wtv",
                            "*.xesc"]

all_supported_mime_types = [
    "video/dv", "video/mpeg", "video/x-mpeg", "video/msvideo", 
    "video/quicktime", "video/x-anim", "video/x-avi", "video/x-ms-asf", 
    "video/x-ms-wmv", "video/x-msvideo", "video/x-nsv", "video/x-flc",
    "video/x-fli", "video/x-flv", "video/vnd.rn-realvideo", "video/mp4", 
    "video/mp4v-es", "video/mp2t", "application/ogg", "application/x-ogg", 
    "video/x-ogm+ogg", "audio/x-vorbis+ogg", "application/x-matroska", 
    "audio/x-matroska", "video/x-matroska", "video/webm", "audio/webm", 
    "audio/x-mp3", "audio/x-mpeg", "audio/mpeg", "audio/x-wav", "audio/x-mpegurl",
    "audio/x-scpls", "audio/x-m4a", "audio/x-ms-asf", "audio/x-ms-asx", 
    "audio/x-ms-wax", "application/vnd.rn-realmedia", "audio/x-real-audio", 
    "audio/x-pn-realaudio", "application/x-flac", "audio/x-flac", 
    "application/x-shockwave-flash", "misc/ultravox", 
    "audio/vnd.rn-realaudio", "audio/x-pn-aiff", "audio/x-pn-au", 
    "audio/x-pn-wav", "audio/x-pn-windows-acm", "image/vnd.rn-realpix", 
    "audio/x-pn-realaudio-plugin", "application/x-extension-mp4", 
    "audio/mp4", "audio/amr", "audio/amr-wb", "x-content/video-vcd",
    "x-content/video-svcd", "x-content/video-dvd", "x-content/audio-cdda", 
    "x-content/audio-player", "application/xspf+xml", "x-scheme-handler/mms",
    "x-scheme-handler/rtmp", "x-scheme-handler/rtsp",
]

def _longest_match(*strs):
    shortest_str = min(strs, key=len)
    if all(x.startswith(shortest_str) for x in strs):
        yield shortest_str
    else:
        for idx, chr in enumerate(shortest_str):
            if all(x[idx] == chr for x in strs):
                yield chr
            else:
                break

def longest_match(*strs):
    return "".join(list(_longest_match(*strs)))

def file_is_video_type(f):
    name, ext = os.path.splitext(f)
    return ext and "*%s" % ext in all_supported_video_exts

def optimizeSerieName(serieName):
    sep_chars = ("-", "_", ".", " ")
    idxes = filter(lambda x: x > 0, map(lambda x: serieName.rfind(x), sep_chars))
    idx = min(idxes) if idxes else len(serieName)
    return serieName[0: idx]

def getEpisode(serieName, serie):
    # serie = serie.lstrip(serieName) lstrip is not reliable on Chinese
    serie = serie[len(serieName):]
    result = []
    numFound = False
    for ch in serie:
        if ch.isdigit():
            numFound = True
            result.append(ch)
        elif numFound:
            break
    return int("".join(result))

def sortSeries(serieName, series):
    epi_name_tuples = [(getEpisode(serieName, serie), serie) for serie in series]
    return [ x[1] for x in sorted(epi_name_tuples, key=lambda x: x[0])]

class Utils(QObject):

    """docstring for Utils"""

    def __init__(self):
        super(Utils, self).__init__()

    @pyqtProperty(str, constant=True)
    def homeDir(self):
        return os.path.expanduser("~")

    @pyqtSlot(str, result=bool)
    def pathIsFile(self, path):
        return os.path.isfile(path)

    @pyqtSlot(str, result=bool)
    def pathIsDir(self, path):
        return os.path.isdir(path)

    @pyqtSlot(str, result="QVariant")
    def getAllFilesInDir(self, dir):
        dir = dir[7:] if dir.startswith("file://") else dir
        result = []
        for entry in os.listdir(dir):
            try:
                file_abs_path = os.path.join(dir, entry) 
                if os.path.isfile(file_abs_path):
                    result.append(file_abs_path)   
            except Exception:
                pass
        return result

    @pyqtSlot(str, result="QVariant")
    def getAllVideoFilesInDir(self, dir):
        allFiles = self.getAllFilesInDir(dir)
        return filter(lambda x: file_is_video_type(x), allFiles)

    @pyqtSlot(str, result=str)
    def getSeriesByName(self, name):
        name = name[7:] if name.startswith("file://") else name
        dir = os.path.dirname(name)
        allFiles = self.getAllVideoFilesInDir(dir)
        if len(allFiles) < 2: return json.dumps({"name": "", "items": allFiles})

        allFiles = [os.path.basename(x) for x in allFiles]
        nameFilter = min((longest_match(x, os.path.basename(name)) for x in allFiles),
                         key=len)
        nameFilter = optimizeSerieName(nameFilter)

        result = filter(lambda x: nameFilter in x, allFiles) if nameFilter else (name,)
        result = sortSeries(nameFilter, result) if len(result) > 1 else result
        result = [os.path.join(dir, x) for x in result]

        return json.dumps({"name":nameFilter, "items":result})

    @pyqtSlot()
    def enable_zone(self):
        try:
            iface = QDBusInterface(
                "com.deepin.daemon.Zone", "/com/deepin/daemon/Zone", '', QDBusConnection.sessionBus())
            iface.asyncCall("EnableZoneDetected", True)
        except:
            pass

    @pyqtSlot()
    def disable_zone(self):
        try:
            iface = QDBusInterface(
                "com.deepin.daemon.Zone", "/com/deepin/daemon/Zone", '', QDBusConnection.sessionBus())
            iface.asyncCall("EnableZoneDetected", False)
        except:
            pass

    @pyqtSlot(int, int, str, result=bool)
    def checkKeySequenceEqual(self, modifier, key, targetKeySequence):
        return QKeySequence(modifier + key) == QKeySequence(targetKeySequence)

    @pyqtSlot(int, int, result=str)
    def keyEventToQKeySequenceString(self, modifier, key):
        return QKeySequence(modifier + key).toString()

    @pyqtSlot(str)
    def copyToClipboard(self, text):
        clipboard = QApplication.clipboard()
        clipboard.clear(mode=clipboard.Clipboard)
        clipboard.setText(text, mode=clipboard.Clipboard)

    @pyqtSlot(str,result=bool)
    def fileIsSubtitle(self, file_path):
        return get_file_type(file_path) in (FILE_TYPE_ASS, FILE_TYPE_SRT)

    @pyqtSlot(str,result=bool)
    def fileIsValidVideo(self, file_path):
        file_path = file_path[7:] if file_path.startswith("file://") else file_path
        if os.path.exists(file_path):
            f = gio.File(file_path.encode("utf-8"))
            info = f.query_info("standard::content-type")
            return info.get_content_type() in all_supported_mime_types
        else: return False

    @pyqtSlot(str)
    def showFileInFM(self, file_path):
        if not file_path: return
        file_path = file_path[7:] if file_path.startswith("file://") else file_path
        subprocess.Popen(["xdg-open", "%s" % os.path.dirname(file_path)])

utils = Utils()
if __name__ == '__main__':
    lst = [
        "权力的游戏.Game.of.Thrones.S04E01.中英字幕.HDTVrip.720x400.mp4",
        "权力的游戏.Game.of.Thrones.S04E02.中英字幕.HDTVrip.720x400.mp4",
        "权力的游戏.Game.of.Thrones.S04E03.中英字幕.HDTVrip.720x400.mp4",
        "权力的游戏.Game.of.Thrones.S04E04.中英字幕.HDTVrip.720x400.mp4",
        "权力的游戏.Game.of.Thrones.S04E05.中英字幕.HDTVrip.720x400.mp4",
        "权力的游戏.Game.of.Thrones.S04E06.中英字幕.HDTVrip.720x400.mp4",
        "权力的游戏.Game.of.Thrones.S04E07.中英字幕.HDTVrip.720x400.mp4",
        "权力的游戏.Game.of.Thrones.S04E07.中英字幕.HDTVrip.624x352.mp4",
    ]

    print "*" * 80
    print longest_match(*lst)
    print "*" * 80
    print utils.getSeriesByName("/home/hualet/Videos/1000种死法第五季/1000种死法第五季-第5集.rmvb")
    print "*" * 80
    print optimizeSerieName("1000种死法第五季-第")
    print "*" * 80
    print utils.fileIsValidVideo("/home/hualet/Desktop/情感化设计.jpg")
