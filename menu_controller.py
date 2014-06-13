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

import os
from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from PyQt5.QtGui import QCursor
from deepin_menu.menu import Menu, CheckableMenuItem

from movie_info import movie_info, get_subtitle_from_movie
from config import *
from i18n import _

frame_sub_menu = [
    CheckableMenuItem("proportion:radio:_p_default", _("Default"), True),
    CheckableMenuItem("proportion:radio:_p_4_3", "4:3"),
    CheckableMenuItem("proportion:radio:_p_16_9", "16:9"),
    CheckableMenuItem("proportion:radio:_p_16_10", "16:10"),
    CheckableMenuItem("proportion:radio:_p_1_85_1", "1.85:1"),
    CheckableMenuItem("proportion:radio:_p_2_35_1", "2.35:1"),
    None,
    CheckableMenuItem("scale:radio:_s_0_5", "0.5"),        
    CheckableMenuItem("scale:radio:_s_1", "1", True),        
    CheckableMenuItem("scale:radio:_s_1_5", "1.5"),        
    CheckableMenuItem("scale:radio:_s_2", "2"),        
    None,
    ("_turn_right", _("Rotate 90 degree clockwise")),
    ("_turn_left", _("Rotate 90 degree counterclockwise")),
    ("_flip_horizontal", _("Flip horizontally")),
    ("_flip_vertial", _("Flip vertically")),
]

sound_sub_menu = [
    ("_sound_channel", _("Sound Channels")),
    ("_sound_channel", _("Sound Tracks")),
    ("_sound_output_mode", _("Output Mode")),
    None,
    ("_sound_increase", _("Volume Up")),
    ("_sound_decrease", _("Volume Down")),
    CheckableMenuItem("_sound_muted", _("Muted"))
]

subtitle_sub_menu = [
    CheckableMenuItem("_subtitle_hide", _("Hide subtitle")),
    None,
    # ("_subtitle_online_match", "自动在线匹配"),
    # ("_subtitle_online_search", "在线查找"),
    ("_subtitle_manual", _("Open manually")),
    ("_subtitle_choose", _("Select file")),
    ("_subtitle_settings", _("Subtitle setting"))
]

play_sequence_sub_menu = [
    CheckableMenuItem("mode_group:radio:in_order", _("Order"), True),
    CheckableMenuItem("mode_group:radio:random", _("Random")),
    CheckableMenuItem("mode_group:radio:single", _("Single")),
    CheckableMenuItem("mode_group:radio:single_cycle", _("Repeat (Single)")),
    CheckableMenuItem("mode_group:radio:playlist_cycle", _("Repeat (Playlist)"))
]

play_sub_menu = [
    ("_play_operation_previous", _("Previous")),
    ("_play_operation_next", _("Next")),
    None,
    ("_play_operation_forward", _("Forward")),
    ("_play_operation_backward", _("Rewind")),
]
    
right_click_menu = [
    ("_open_file", _("Open file")),
    ("_open_dir", _("Open folder")),
    ("_open_url", _("Open URL")),
    None,
    ("_fullscreen_quit", _("Fullscreen/Quit")),
    CheckableMenuItem("_mini_mode", _("Mini mode"), True),
    CheckableMenuItem("_on_top", _("Always on top"), False),
    None,
    ("_play_sequence", _("Play Sequence"), (), play_sequence_sub_menu),
    ("_play", _("Play"), (), play_sub_menu),
    ("_frame", _("Frame"), (), frame_sub_menu),
    ("_sound", _("Sound"), (), sound_sub_menu),
    ("_subtitle", _("Subtitles"), (), subtitle_sub_menu),
    None,
    ("_preferences", _("Options")),
    ("_information", _("Information")),
]

FILE_START_TAG = "[[[[["
FILE_END_TAG = "]]]]]"
def _subtitle_menu_items_from_files(files):
    def checkable_item_from_file(f, flag=[True,]):
        item = CheckableMenuItem(
                "_subtitles:radio:%s%s%s" % (FILE_START_TAG, f, FILE_END_TAG), 
                os.path.basename(f),
                flag[0])
        flag[0] = False
        return item
    return map(checkable_item_from_file, filter(lambda x: x != "", files))

def _subtitle_file_from_menu_item_id(id):
    return id[id.index(FILE_START_TAG) + len(FILE_START_TAG):
                                        id.index(FILE_END_TAG)]

class MenuController(QObject):
    
    clockwiseRotate = pyqtSignal()
    antiClosewiseRotate = pyqtSignal()
    flipHorizontal = pyqtSignal()
    flipVertical = pyqtSignal()
    toggleFullscreen = pyqtSignal()
    screenShot = pyqtSignal()
    scaleChanged = pyqtSignal(float,arguments=["scale"])
    proportionChanged = pyqtSignal(float,float,
        arguments=["propWidth", "propHeight"])
    openDialog = pyqtSignal(str)
    staysOnTop = pyqtSignal(bool,arguments=["onTop"])
    showPreference = pyqtSignal()
    showMovieInformation = pyqtSignal()
    openSubtitleFile = pyqtSignal()
    subtitleSelected = pyqtSignal(str,arguments=["subtitle"])
    
    def __init__(self, window):
        super(MenuController, self).__init__()
        self._window = window

        self._proportion = "proportion:radio:_p_default"
        self._scale = "scale:radio:_s_1"
        
    # if actions-like menu items are clicked, we should send signals to inform 
    # the main controller that actions should be taken, if configs-like menu 
    # items are clicked, we just change the configuration, config.py will takes 
    # care of it for you .
    def _menu_item_invoked(self, _id, _checked):
        if _id == "_turn_right":
            self.clockwiseRotate.emit()
        elif _id == "_turn_left":
            self.antiClosewiseRotate.emit()
        elif _id == "_flip_horizontal":
            self.flipHorizontal.emit()
        elif _id == "_flip_vertial":
            self.flipVertical.emit()
        elif _id == "_fullscreen_quit":
            self.toggleFullscreen.emit()
        elif _id == "_screenshot":
            self.screenShot.emit()
        elif _id == "proportion:radio:_p_default":
            self._proportion = "proportion:radio:_p_default"
            self.proportionChanged.emit(1, 1)
        elif _id == "proportion:radio:_p_4_3":
            self._proportion = "proportion:radio:_p_4_3"
            self.proportionChanged.emit(4, 3)
        elif _id == "proportion:radio:_p_16_9":
            self._proportion = "proportion:radio:_p_16_9"
            self.proportionChanged.emit(16, 9)
        elif _id == "proportion:radio:_p_16_10":
            self._proportion = "proportion:radio:_p_16_10"
            self.proportionChanged.emit(16, 10)
        elif _id == "proportion:radio:_p_1_85_1":
            self._proportion = "proportion:radio:_p_1_85_1"
            self.proportionChanged.emit(1.85, 1)
        elif _id == "proportion:radio:_p_2_35_1":
            self._proportion = "proportion:radio:_p_2_35_1"
            self.proportionChanged.emit(2.35, 1)
        elif _id == "scale:radio:_s_0_5":
            self._scale = "scale:radio:_s_0_5"
            self.scaleChanged.emit(0.5)
        elif _id == "scale:radio:_s_1":
            self._scale = "scale:radio:_s_1"
            self.scaleChanged.emit(1)
        elif _id == "scale:radio:_s_1_5":
            self._scale = "scale:radio:_s_1_5"
            self.scaleChanged.emit(1.5)
        elif _id == "scale:radio:_s_2":
            self._scale = "scale:radio:_s_2"
            self.scaleChanged.emit(2)
        elif _id == "_open_file":
            self.openDialog.emit("file")
        elif _id == "_open_dir":
            self.openDialog.emit("dir")
        elif _id == "_open_url":
            self.openDialog.emit("url")
        elif _id == "_on_top":
            self.staysOnTop.emit(_checked)
        elif _id == "mode_group:radio:in_order":
            config.playerPlayOrderType = ORDER_TYPE_IN_ORDER
        elif _id == "mode_group:radio:random":
            config.playerPlayOrderType = ORDER_TYPE_RANDOM
        elif _id == "mode_group:radio:single":
            config.playerPlayOrderType = ORDER_TYPE_SINGLE
        elif _id == "mode_group:radio:single_cycle":
            config.playerPlayOrderType = ORDER_TYPE_SINGLE_CYCLE
        elif _id == "mode_group:radio:playlist_cycle":
            config.playerPlayOrderType = ORDER_TYPE_PLAYLIST_CYCLE
        elif _id == "_sound_muted":
            config.playerMuted = _checked
        elif _id == "_subtitle_manual":
            self.openSubtitleFile.emit()
        elif _id.startswith("_subtitles:radio"):
            self.subtitleSelected.emit(_subtitle_file_from_menu_item_id(_id))
        elif _id == "_preferences":
            self.showPreference.emit()
        elif _id == "_information":
            self.showMovieInformation.emit()

    @pyqtSlot()
    def show_menu(self):
        self.menu = Menu(right_click_menu)

        self.menu.getItemById("_on_top").checked = self._window.staysOnTop

        self.menu.getItemById("mode_group:radio:in_order").checked = \
            config.playerPlayOrderType == ORDER_TYPE_IN_ORDER
        self.menu.getItemById("mode_group:radio:random").checked = \
            config.playerPlayOrderType == ORDER_TYPE_RANDOM
        self.menu.getItemById("mode_group:radio:single").checked = \
            config.playerPlayOrderType == ORDER_TYPE_SINGLE
        self.menu.getItemById("mode_group:radio:single_cycle").checked = \
            config.playerPlayOrderType == ORDER_TYPE_SINGLE_CYCLE
        self.menu.getItemById("mode_group:radio:playlist_cycle").checked = \
            config.playerPlayOrderType == ORDER_TYPE_PLAYLIST_CYCLE

        self.menu.getItemById("proportion:radio:_p_default").checked = \
            self._proportion == "proportion:radio:_p_default"
        self.menu.getItemById("proportion:radio:_p_4_3").checked = \
            self._proportion == "proportion:radio:_p_4_3"
        self.menu.getItemById("proportion:radio:_p_16_9").checked = \
            self._proportion == "proportion:radio:_p_16_9"
        self.menu.getItemById("proportion:radio:_p_16_10").checked = \
            self._proportion == "proportion:radio:_p_16_10"
        self.menu.getItemById("proportion:radio:_p_1_85_1").checked = \
            self._proportion == "proportion:radio:_p_1_85_1"
        self.menu.getItemById("proportion:radio:_p_2_35_1").checked = \
            self._proportion == "proportion:radio:_p_2_35_1"

        self.menu.getItemById("scale:radio:_s_0_5").checked = \
            self._scale == "scale:radio:_s_0_5"        
        self.menu.getItemById("scale:radio:_s_1").checked = \
            self._scale == "scale:radio:_s_1"      
        self.menu.getItemById("scale:radio:_s_1_5").checked = \
            self._scale == "scale:radio:_s_1_5"        
        self.menu.getItemById("scale:radio:_s_2").checked = \
            self._scale == "scale:radio:_s_2"

        self.menu.getItemById("_sound_muted").checked = config.playerMuted

        self.menu.getItemById("_subtitle_hide").checked = \
            config.playerSubtitleHide
        subtitles = get_subtitle_from_movie(movie_info.movie_file)
        subtitles = _subtitle_menu_items_from_files(subtitles)
        self.menu.getItemById("_subtitle_choose").setSubMenu(Menu(subtitles))

        self.menu.itemClicked.connect(self._menu_item_invoked)
        self.menu.showRectMenu(QCursor.pos().x(), QCursor.pos().y())
        
    @pyqtSlot()
    def show_mode_menu(self):
        self.menu = Menu(play_sequence_sub_menu)
        self.menu.itemClicked.connect(self._menu_item_invoked)

        self.menu.getItemById("mode_group:radio:in_order").checked = \
            config.playerPlayOrderType == ORDER_TYPE_IN_ORDER
        self.menu.getItemById("mode_group:radio:random").checked = \
            config.playerPlayOrderType == ORDER_TYPE_RANDOM
        self.menu.getItemById("mode_group:radio:single").checked = \
            config.playerPlayOrderType == ORDER_TYPE_SINGLE
        self.menu.getItemById("mode_group:radio:single_cycle").checked = \
            config.playerPlayOrderType == ORDER_TYPE_SINGLE_CYCLE
        self.menu.getItemById("mode_group:radio:playlist_cycle").checked = \
            config.playerPlayOrderType == ORDER_TYPE_PLAYLIST_CYCLE
            
        self.menu.showRectMenu(QCursor.pos().x() - 100, QCursor.pos().y())        
