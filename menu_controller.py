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
from deepin_menu.menu import Menu, CheckboxMenuItem

frame_sub_menu = [
    ("_p_default", "Default"),
    ("_p_4_3", "4:3"),
    ("_p_16_9", "16:9"),
    ("_p_16_10", "16:10"),
    ("_p_1_85_1", "1.85:1"),
    ("_p_2_35_1", "2.35:1"),
    None,
    ("_s_0_5", "0.5"),        
    ("_s_1", "1"),        
    ("_s_1_5", "1.5"),        
    ("_s_2", "2"),        
    None,
    ("_turn_right", "Rotate 90 degree"),
    ("_turn_left", "Rotate -90 degree"),
    ("_flip_horizontal", "Flip Horizontally"),
    ("_flip_vertial", "Flip Vertically"),
]
    
right_click_menu = [
    ("_open_file", "Open File"),
    ("_open_dir", "Open Directory"),
    ("_open_url", "Open URL"),
    None,
    ("_fullscreen_quit", "Fullscreen/Quit Fullscreen"),
    None,
    CheckboxMenuItem("_on_top", "On Top", True),
    ("_play_sequence", "Play Sequence"),
    ("_play", "Play"),
    ("_screenshot", "ScreenShot"),
    ("_frame", "Frame", (), frame_sub_menu),
    ("_sound", "Sound"),
    ("_subtitle", "Subtitle"),
    ("_share", "Share", (), [("_share_to_dtalk", "DTalk"), 
                             ("_share_to_s_weibo", "Sina Weibo"),
                             ("_share_to_t_weibo", "Tencent Weibo"),]),
    ("_information", "Information"),
    ("_preferences", "Preferences"),
]

class MenuController(QObject):
    
    clockwiseRotate = pyqtSignal()
    antiClosewiseRotate = pyqtSignal()
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
        
    def _menu_item_invoked(self, _id, _checked):
        if _id == "_turn_right":
            self.clockwiseRotate.emit()
        elif _id == "_turn_left":
            self.antiClosewiseRotate.emit()
        elif _id == "_fullscreen_quit":
            self.toggleFullscreen.emit()
        elif _id == "_screenshot":
            self.screenShot.emit()
        elif _id == "_p_default":
            self.proportionChanged.emit(1, 1)
        elif _id == "_p_4_3":
            self.proportionChanged.emit(4, 3)
        elif _id == "_p_16_9":
            self.proportionChanged.emit(16, 9)
        elif _id == "_p_16_10":
            self.proportionChanged.emit(16, 10)
        elif _id == "_p_1_85_1":
            self.proportionChanged.emit(1.85, 1)
        elif _id == "_p_2_35_1":
            self.proportionChanged.emit(2.35, 1)
        elif _id == "_s_0_5":
            self.scaleChanged.emit(0.5)
        elif _id == "_s_1":
            self.scaleChanged.emit(1)
        elif _id == "_s_1_5":
            self.scaleChanged.emit(1.5)
        elif _id == "_s_2":
            self.scaleChanged.emit(2)
        elif _id == "_open_file":
            self.openDialog.emit("file")
        elif _id == "_open_dir":
            self.openDialog.emit("dir")
        elif _id == "_open_url":
            self.openDialog.emit("url")
        elif _id == "_on_top":
            self.staysOnTop.emit(_checked)

    def _getMenuItems(self):
        right_click_menu[6] = CheckboxMenuItem("_on_top", "On Top", 
            self._window.staysOnTop)
        return right_click_menu

    @pyqtSlot()
    def show_menu(self):
        self.menu = Menu(self._getMenuItems())
        self.menu.itemClicked.connect(self._menu_item_invoked)
        self.menu.showRectMenu(QCursor.pos().x(), QCursor.pos().y())
