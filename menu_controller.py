#! /usr/bin/env python
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

from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from PyQt5.QtGui import QCursor
from deepin_menu.menu import Menu, CheckableMenuItem

from config import *

frame_sub_menu = [
    CheckableMenuItem("proportion:radio:_p_default", "Default", True),
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
    ("_turn_right", "Rotate 90 degree"),
    ("_turn_left", "Rotate -90 degree"),
    ("_flip_horizontal", "Flip Horizontally"),
    ("_flip_vertial", "Flip Vertically"),
]

sound_sub_menu = [
    ("_sound_channel", "Sound Channels"),
    ("_sound_channel", "Sound Tracks"),
    ("_sound_output_mode", "Output Mode"),
    None,
    ("_sound_increase", "Increase Volume"),
    ("_sound_decrease", "Decrease Volume"),
    CheckableMenuItem("_sound_muted", "Muted")
]

subtitle_sub_menu = [
    CheckableMenuItem("_subtitle_hide", "Hide Subtitle"),
    None,
    ("_subtitle_online_match", "自动在线匹配"),
    ("_subtitle_online_search", "在线查找"),
    ("_subtitle_manual", "手动载入"),
    ("_subtitle_choose", "字幕选择"),
    ("_subtitle_settings", "字幕设置")
]

play_sequence_sub_menu = [
    CheckableMenuItem("mode_group:radio:in_order", "顺序播放", True),
    CheckableMenuItem("mode_group:radio:random", "随机播放"),
    CheckableMenuItem("mode_group:radio:single", "单个播放"),
    CheckableMenuItem("mode_group:radio:single_cycle", "单个循环"),
    CheckableMenuItem("mode_group:radio:playlist_cycle", "列表循环")
]

play_sub_menu = [
    ("_play_operation_previous", "Previous"),
    ("_play_operation_next", "Next"),
    None,
    ("_play_operation_forward", "Forward"),
    ("_play_operation_backward", "Backward"),
]
    
right_click_menu = [
    ("_open_file", "Open File"),
    ("_open_dir", "Open Directory"),
    ("_open_url", "Open URL"),
    None,
    ("_fullscreen_quit", "Fullscreen/Quit Fullscreen"),
    CheckableMenuItem("_mini_mode", "Mini Mode", True),
    CheckableMenuItem("_on_top", "On Top", False),
    None,
    ("_play_sequence", "Play Sequence", (), play_sequence_sub_menu),
    ("_play", "Play", (), play_sub_menu),
    ("_frame", "Frame", (), frame_sub_menu),
    ("_sound", "Sound", (), sound_sub_menu),
    ("_subtitle", "Subtitle", (), subtitle_sub_menu),
    ("_information", "Information"),
    ("_preferences", "Preferences"),
]

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

        self.menu.itemClicked.connect(self._menu_item_invoked)
        self.menu.showRectMenu(QCursor.pos().x(), QCursor.pos().y())
        
    @pyqtSlot()
    def show_mode_menu(self):
        self.menu = Menu(play_sequence_sub_menu)
        self.menu.showRectMenu(QCursor.pos().x() - 100, QCursor.pos().y())        
