import QtQuick 2.1

// After some digging you will find that this file is somehow twisted with
// main.qml(where some ids are from), because the content of this file is
// mainly extracted from main.qml :)
Connections {
    target: _menu_controller

    onClockwiseRotate: {
        main_controller.rotateClockwise()
    }
    onAntiClosewiseRotate: {
        main_controller.rotateAnticlockwise()
    }
    onFlipHorizontal: {
        main_controller.flipHorizontal()
    }
    onFlipVertical: {
        main_controller.flipVertical()
    }
    onTogglePlaylist: {
        main_controller.togglePlaylist()
    }
    onToggleFullscreen: {
        main_controller.toggleFullscreen()
    }
    onToggleMiniMode: {
        main_controller.toggleMiniMode()
    }
    onScreenShot: {
        windowView.screenShot()
    }
    onProportionChanged: main_controller.setProportion(propWidth, propHeight)
    onScaleChanged: main_controller.setScale(scale)
    onStaysOnTop: {
        windowView.staysOnTop = onTop
    }
    onOpenDialog: {
        if (arguments[0] == "file") {
            main_controller.openFile()
        } else if (arguments[0] == "dir") {
            main_controller.openDir()
        } else {
            main_controller.openUrl()
        }
    }

    onOpenSubtitleFile: { main_controller.openFileForSubtitle() }

    onSubtitleSelected: { main_controller.setSubtitle(subtitle) }

    onShowPreference: { main_controller.showPreferenceWindow() }

    onShowMovieInformation: {
        player.source && player.hasVideo
        && main_controller.showInformationWindow(player.sourceString)
    }

    onSubtitleVisibleSet: player.subtitleShow = visible

    onPlayPrevious: { main_controller.playPrevious() }
    onPlayNext: { main_controller.playNext() }
    onPlayForward: { main_controller.forward() }
    onPlayBackward: { main_controller.backward() }

    onVolumeUp: { main_controller.increaseVolume() }
    onVolumeDown: { main_controller.decreaseVolume() }
    onVolumeMuted: { main_controller.setMute(muted) }
    onSoundChannelChanged: { main_controller.setSoundChannel(channelLayout) }

    onShowSubtitleSettings: { main_controller.showPreferenceWindow(); preference_window.scrollToSubtitle() }

    onPlaylistPlay: main_controller.playPath(playlist.clickedOnItemUrl)
    onAddItemToPlaylist: main_controller.openFileForPlaylist()
    onAddFolderToPlaylist: main_controller.openDirForPlaylist()
    onRemoveItemFromPlaylist: playlist.removeClickedItem()
    onRemoveInvalidItemsFromPlaylist: playlist.removeInvalidItems(_utils.playlistItemValidation)
    onPlaylistClear: playlist.clear()
    onPlaylistShowClickedItemInFM: playlist.showClickedItemInFM()
    onPlaylistInformation: { main_controller.showInformationWindow(playlist.clickedOnItemUrl) }
    onPlaylistExport: main_controller.exportPlaylist()
    onPlaylistImport: main_controller.importPlaylist()

    onShowManual: main_controller.showManual()
}
