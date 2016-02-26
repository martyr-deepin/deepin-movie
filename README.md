# Deepin Movie

**Description**:  The default media player for Deepin, very beautiful yet very easy to use. QML is used to build its graphical interface combined [QtAV](https://github.com/wang-bin/QtAV) as its multimedia backend. All video formats are supported out of the box.

## Dependencies

### Build dependencies

- python

### Runtime dependencies

- Qt5.3 or above
- mediainfo
- [QtAV](https://github.com/wang-bin/QtAV)
- python-sip
- python-pyqt5
- python-xpyb
- python-magic
- python-xpybutil
- [python-deepin-utils](https://github.com/linuxdeepin/deepin-utils)
- python-peewee
- python-requests
- python-bottle
- python-prctl
- [deepin-menu](https://github.com/linuxdeepin/deepin-menu)
- [deepin-qml-widgets](https://github.com/linuxdeepin/deepin-qml-widgets)
- libfontconfig
- [dleyna-renderer](https://github.com/01org/dleyna-renderer)
- [deepin-dlna-renderer](https://gitcafe.com/Deepin/deepin-dlna-renderer/tree/deepin-movie)

## Installation

After installed all the dependencies listed above, run
> make && make install

## Usage

To simply play a video file. run
> deepin-movie VIDEO_FILE

## Known issues

- command line options are not well supported.

## Getting help

Any usage issues can ask for help via

* [Gitter](https://gitter.im/orgs/linuxdeepin/rooms)
* [IRC channel](https://webchat.freenode.net/?channels=deepin)
* [Forum](https://bbs.deepin.org)
* [WiKi](http://wiki.deepin.org/)

## Getting involved

We encourage you to report issues and contribute changes

* [Contribution guide for users](http://wiki.deepin.org/index.php?title=Contribution_Guidelines_for_Users)
* [Contribution guide for developers](http://wiki.deepin.org/index.php?title=Contribution_Guidelines_for_Developers).

## License

Deepin Movie is licensed under [GPLv3](LICENSE).
