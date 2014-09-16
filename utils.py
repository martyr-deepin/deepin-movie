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
from ConfigParser import ConfigParser

import gio
from PyQt5.QtWidgets import QApplication
from PyQt5.QtGui import QKeySequence
from PyQt5.QtCore import QObject, QThread, pyqtSignal, pyqtSlot, pyqtProperty

from subtitles import *
from dbus_interfaces import screenSaverInterface

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

all_supported_mime_types = []
sep_chars = ("-", "_", ".", " ")

with open("/usr/share/applications/deepin-movie.desktop") as app_info:
    cp = ConfigParser()
    cp.readfp(app_info)
    all_supported_mime_types = cp.get("Desktop Entry", "MimeType").split(";")

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

def optimizeSerieName(serieName):
    global sep_chars
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
    return int("".join(result)) if result else 0

def sortSeries(serieName, series):
    epi_name_tuples = [(getEpisode(serieName, serie), serie) for serie in series]
    return [ x[1] for x in sorted(epi_name_tuples, key=lambda x: x[0])]

def getFileMimeType(filename):
    f = None
    try:
        f = gio.File(filename)
    except Exception:
        try:
            f = gio.File(filename.encode("utf-8"))
        except Exception:
            return None
    info = f.query_info("standard::content-type") if f else None
    return info.get_content_type() if info else None

class FindVideoThread(QThread):
    videoFound = pyqtSignal(str, arguments=["path",])
    findVideoDone = pyqtSignal(str, arguments=["path",])

    def __init__(self, dir):
        super(FindVideoThread, self).__init__()
        self._dir = dir
        self._first_video = None

    def _get_all_videos_in_dir_recursively(self, dir):
        for _file in utils.getAllFilesInDir(dir):
            if utils.fileIsValidVideo(_file):
                self._first_video = self._first_video or _file
                self.videoFound.emit(_file)
            elif os.path.isdir(_file):
                self._get_all_videos_in_dir_recursively(_file)

    def run(self):
        self._get_all_videos_in_dir_recursively(self._dir)
        self.findVideoDone.emit(self._first_video)
        self._first_video = None

class Utils(QObject):
    videoFound = pyqtSignal(str, arguments=["path",])
    findVideoDone = pyqtSignal(str, arguments=["path",])

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

    @pyqtSlot(str, result=bool)
    def urlIsNativeFile(self, url):
        return os.path.exists(url.replace("file://", ""))

    @pyqtSlot(str, result="QVariant")
    def getAllFilesInDir(self, dir):
        dir = dir[7:] if dir.startswith("file://") else dir
        result = []
        for entry in os.listdir(dir):
            try:
                file_abs_path = os.path.join(dir, entry)
                # to test if the file path is encoding recognizable
                os.path.isfile(file_abs_path)
                result.append(file_abs_path)
            except Exception:
                # bypass the files whose path is not encoding recognizable
                pass
        return result

    @pyqtSlot(str, result="QVariant")
    def getAllVideoFilesInDir(self, dir):
        allFiles = self.getAllFilesInDir(dir)
        return filter(lambda x: self.fileIsValidVideo(x), allFiles)

    @pyqtSlot(str, result="QVariant")
    def getAllVideoFilesInDirRecursively(self, dir):
        self._thread = FindVideoThread(dir)
        self._thread.videoFound.connect(self.videoFound)
        self._thread.findVideoDone.connect(self.findVideoDone)
        self._thread.start()

    @pyqtSlot(str, result=str)
    def getSeriesByName(self, name):
        global sep_chars
        name = name[7:] if name.startswith("file://") else name
        dir = os.path.dirname(name)
        allFiles = self.getAllVideoFilesInDir(dir)
        if len(allFiles) < 2: return json.dumps({"name": "", "items": allFiles})

        allFiles = [os.path.basename(x) for x in allFiles]
        allMatches = (longest_match(x, os.path.basename(name)) for x in allFiles)
        matchesFilter = lambda x: x and x != os.path.basename(name) and (len(x) > 5 or any(map(lambda ch: ch in x, sep_chars)))
        filteredMatches = filter(matchesFilter, allMatches)
        nameFilter = min(filteredMatches, key=len) if filteredMatches else ""
        # can't do this here, because the following three steps relies on the
        # uglier but yet more specific version of the nameFilter.
        # serieName = optimizeSerieName(nameFilter)

        result = filter(lambda x: nameFilter in x, allFiles) if nameFilter else (name,)
        result = sortSeries(nameFilter, result) if len(result) > 1 else result
        result = [os.path.join(dir, x) for x in result]

        serieName = optimizeSerieName(nameFilter)

        return json.dumps({"name":serieName, "items":result})

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
    def fileIsPlaylist(self, file_path):
        mime_type = getFileMimeType(file_path)
        return file_path.endswith(".dmpl") and mime_type == "application/xml"

    @pyqtSlot(str,result=bool)
    def fileIsSubtitle(self, file_path):
        return get_file_type(file_path) in (FILE_TYPE_ASS, FILE_TYPE_SRT)

    @pyqtSlot(str,result=bool)
    def fileIsValidVideo(self, file_path):
        if file_path.startswith("file://"):
            file_path = file_path[7:]
        mime_type = getFileMimeType(file_path)
        if os.path.exists(file_path) and mime_type:
            return mime_type in all_supported_mime_types
        else: return False

    @pyqtSlot(str)
    def showFileInFM(self, file_path):
        if not file_path: return
        file_path = file_path[7:] if file_path.startswith("file://") \
                                    else file_path
        subprocess.Popen(["xdg-open", "%s" % os.path.dirname(file_path)])

    @pyqtSlot()
    def screenSaverInhibit(self):
        screenSaverInterface.inhibit()

    @pyqtSlot()
    def screenSaverUninhibit(self):
        screenSaverInterface.uninhibit()

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
