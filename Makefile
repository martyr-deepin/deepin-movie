PREFIX = /usr

all:
	python configure.py
	deepin-generate-mo locale/locale_config.ini

install:
	mkdir -p ${DESTDIR}${PREFIX}/bin
	mkdir -p ${DESTDIR}${PREFIX}/share/locale
	mkdir -p ${DESTDIR}${PREFIX}/share/applications
	mkdir -p ${DESTDIR}${PREFIX}/share/deepin-movie
	mkdir -p ${DESTDIR}${PREFIX}/share/dman/deepin-movie
	mkdir -p ${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps
	cp -r src/* ${DESTDIR}${PREFIX}/share/deepin-movie
	cp -r doc/* ${DESTDIR}${PREFIX}/share/dman/deepin-movie
	rm -rf ${DESTDIR}${PREFIX}/share/deepin-movie/tests
	cp src/views/image/deepin-movie.svg ${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/
	cp deepin-movie.desktop ${DESTDIR}${PREFIX}/share/applications
	cp -r locale/mo/* ${DESTDIR}${PREFIX}/share/locale/
	ln -sf ${PREFIX}/share/deepin-movie/main.py ${DESTDIR}${PREFIX}/bin/deepin-movie
