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
from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal, Qt
from PyQt5.QtGui import QCursor
from deepin_menu.menu import Menu, CheckableMenuItem

from movie_info import movie_info, get_subtitle_from_movie
from config import *
from i18n import _
from utils import utils

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
    ("_turn_right", _("Rotate 90 degree clockwise"), (), (), config.hotkeysFrameSoundRotateClockwise),
    ("_turn_left", _("Rotate 90 degree counterclockwise"), (), (), config.hotkeysFrameSoundRotateAnticlockwise),
    ("_flip_horizontal", _("Flip horizontally")),
    ("_flip_vertial", _("Flip vertically")),
]

sound_sub_menu = [
    # ("_sound_channel", _("Sound Channels")),
    # ("_sound_channel", _("Sound Tracks")),
    # ("_sound_output_mode", _("Output Mode")),
    # None,
    ("_sound_increase", _("Volume Up"), (), (), config.hotkeysFrameSoundIncreaseVolume),
    ("_sound_decrease", _("Volume Down"), (), (), config.hotkeysFrameSoundDecreaseVolume),
    CheckableMenuItem("_sound_muted", _("Muted"), extra=config.hotkeysFrameSoundToggleMute)
]

subtitle_sub_menu = [
    CheckableMenuItem("_subtitle_hide", _("Hide subtitle")),
    None,
    # ("_subtitle_online_match", "自动在线匹配"),
    # ("_subtitle_online_search", "在线查找"),
    ("_subtitle_manual", _("Open manually")),
    ("_subtitle_choose", _("Subtitle selection")),
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
    ("_play_operation_previous", _("Previous"), (), (), config.hotkeysFilesPlayPrevious),
    ("_play_operation_next", _("Next"), (), (), config.hotkeysFilesPlayNext),
    None,
    ("_play_operation_forward", _("Forward"), (), (), config.hotkeysPlayForward),
    ("_play_operation_backward", _("Rewind"), (), (), config.hotkeysPlayBackward),
]

right_click_menu = [
    ("_open_file", _("Open a file"), (), (), config.hotkeysFilesOpenFile),
    ("_open_dir", _("Open a folder")),
    ("_open_url", _("Open URL")),
    None,
    ("_fullscreen_quit", _("Fullscreen"), (), (), config.hotkeysPlayToggleFullscreen),
    ("_mini_mode", _("Mini mode"), (), (), config.hotkeysFrameSoundToggleMiniMode),
    CheckableMenuItem("_on_top", _("Always on top"), False),
    ("_toggle_playlist", _("Playlist"), (), (), config.hotkeysPlayTogglePlaylist),
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

playlist_right_menu = [
    ("_playlist_play", _("Play")),
    ("_playlist_add_item", _("Add file")),
    ("_playlist_add_folder", _("Add folder")),
    None,
    ("_playlist_remove_item", _("Remove from playlist")),
    ("_playlist_remove_invalid", _("Remove invalid file")),
    ("_playlist_export", _("Export")),
    ("_playlist_import", _("Import")),
    ("_playlist_clear", _("Clear playlist")),
    None,
] + play_sequence_sub_menu + [
    None,
    ("_playlist_open_position", _("Open file location")),
    ("_playlist_information", _("Information")),
]

playlist_add_button_menu = (
    ("_playlist_add_item", _("Add file")),
    ("_playlist_add_folder", _("Add folder"))
)

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
    toggleMiniMode = pyqtSignal()
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
    playNext = pyqtSignal()
    playPrevious = pyqtSignal()
    playForward = pyqtSignal()
    playBackward = pyqtSignal()
    volumeUp = pyqtSignal()
    volumeDown = pyqtSignal()
    volumeMuted = pyqtSignal()
    showSubtitleSettings = pyqtSignal()

    playlistPlay = pyqtSignal()
    addItemToPlaylist = pyqtSignal()
    addFolderToPlaylist = pyqtSignal()
    removeItemFromPlaylist = pyqtSignal()
    removeInvalidItemsFromPlaylist = pyqtSignal()
    playlistExport = pyqtSignal()
    playlistImport = pyqtSignal()
    playlistClear = pyqtSignal()
    playlistShowClickedItemInFM = pyqtSignal()
    playlistInformation = pyqtSignal()
    togglePlaylist = pyqtSignal()

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
        elif _id == "_mini_mode":
            self.toggleMiniMode.emit()
        elif _id == "_on_top":
            self.staysOnTop.emit(_checked)
        elif _id == "_toggle_playlist":
        	self.togglePlaylist.emit()
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
        elif _id == "_subtitle_hide":
            self._window.subtitleVisible = not _checked
        elif _id == "_subtitle_manual":
            self.openSubtitleFile.emit()
        elif _id.startswith("_subtitles:radio"):
            self.subtitleSelected.emit(_subtitle_file_from_menu_item_id(_id))
        elif _id == "_play_operation_forward":
            self.playForward.emit()
        elif _id == "_play_operation_backward":
            self.playBackward.emit()
        elif _id == "_play_operation_next":
            self.playNext.emit()
        elif _id == "_play_operation_previous":
            self.playPrevious.emit()
        elif _id == "_sound_increase":
            self.volumeUp.emit()
        elif _id == "_sound_decrease":
            self.volumeDown.emit()
        elif _id == "_sound_muted":
            self.volumeMuted.emit()
        elif _id == "_subtitle_settings":
            self.showSubtitleSettings.emit()
        elif _id == "_preferences":
            self.showPreference.emit()
        elif _id == "_information":
            self.showMovieInformation.emit()

        # playlist menu
        elif _id == "_playlist_play":
            self.playlistPlay.emit()
        elif _id == "_playlist_add_item":
            self.addItemToPlaylist.emit()
        elif _id == "_playlist_add_folder":
            self.addFolderToPlaylist.emit()
        elif _id == "_playlist_remove_item":
            self.removeItemFromPlaylist.emit()
        elif _id == "_playlist_remove_invalid":
            self.removeInvalidItemsFromPlaylist.emit()
        elif _id == "_playlist_clear":
            self.playlistClear.emit()
        elif _id == "_playlist_open_position":
            self.playlistShowClickedItemInFM.emit()
        elif _id == "_playlist_information":
            self.playlistInformation.emit()
        elif _id == "_playlist_export":
            self.playlistExport.emit()
        elif _id == "_playlist_import":
            self.playlistImport.emit()

    @pyqtSlot()
    def show_menu(self):
        self.menu = Menu(right_click_menu)

        hasVideo = movie_info.movie_file != ""
        self.menu.getItemById("_fullscreen_quit").isActive = hasVideo
        self.menu.getItemById("_mini_mode").isActive = hasVideo
        self.menu.getItemById("_play_operation_forward").isActive = hasVideo
        self.menu.getItemById("_play_operation_backward").isActive = hasVideo
        self.menu.getItemById("_frame").isActive = \
            hasVideo and self._window.getState() != Qt.WindowFullScreen
        self.menu.getItemById("_subtitle_hide").isActive = \
            hasVideo and bool(movie_info.subtitle_file)
        self.menu.getItemById("_subtitle_manual").isActive = hasVideo
        self.menu.getItemById("_subtitle_choose").isActive = \
            bool(movie_info.subtitle_file)
        self.menu.getItemById("_information").isActive = hasVideo \
            and movie_info.movie_duration != 0

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
            not self._window.subtitleVisible
        subtitles = get_subtitle_from_movie(movie_info.movie_file)
        subtitles = _subtitle_menu_items_from_files(subtitles)
        self.menu.getItemById("_subtitle_choose").setSubMenu(Menu(subtitles))

        self.menu.getItemById("_fullscreen_quit").text = _("Fullscreen") if \
            self._window.getState() != Qt.WindowFullScreen else _("Exit fullscreen")
        self.menu.getItemById("_mini_mode").text = _("Exit mini mode") if \
            self._window.miniModeState() else _("Mini mode")

        self.menu.itemClicked.connect(self._menu_item_invoked)
        self.menu.showRectMenu(QCursor.pos().x(), QCursor.pos().y())

    @pyqtSlot(bool,str)
    def show_playlist_menu(self, isGroup, url):
        self.menu = Menu(playlist_right_menu)
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

        self.menu.getItemById("_playlist_play").isActive = url != ""
        self.menu.getItemById("_playlist_remove_item").isActive = \
            isGroup or url != ""
        self.menu.getItemById("_playlist_open_position").isActive = url != "" \
            and utils.urlIsNativeFile(url)
        self.menu.getItemById("_playlist_information").isActive = url != "" \
            and utils.fileIsValidVideo(url)

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

        self.menu.showRectMenu(QCursor.pos().x(), QCursor.pos().y())

    @pyqtSlot()
    def show_add_button_menu(self):
        self.menu = Menu(playlist_add_button_menu)
        self.menu.itemClicked.connect(self._menu_item_invoked)

        self.menu.showRectMenu(QCursor.pos().x(), QCursor.pos().y())
