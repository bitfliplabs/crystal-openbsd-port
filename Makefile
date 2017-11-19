# $OpenBSD: Makefile.template,v 1.75 2016/03/20 17:19:49 naddy Exp $

ONLY_FOR_ARCHS			  = amd64

#							|----------------------------------------------------------|
COMMENT					  = A Ruby-like, statically typed, object oriented, language.

VERSION					  = 0.23.1
VERSION_SHARDS			  = 0.7.1
DISTNAME				  = crystal-${VERSION}
PKGNAME					  = crystal-${VERSION}

CATEGORIES				  = lang
HOMEPAGE				  = https://crystal-lang.org/
MAINTAINER				  = Chris Huxtable <chris@bitfliplabs.com>

# Apache License, v2.0
PERMIT_PACKAGE_CDROM	  = Yes
PERMIT_PACKAGE_FTP		  = Yes
PERMIT_DISTFILES_FTP	  = Yes

WANTLIB					 += c event_core event_extra gc iconv m pcre pthread z

MASTER_SITES			  = https://github.com/crystal-lang/crystal/archive/
MASTER_SITES0			  = https://assets.bitfliplabs.com/crystal/archive/
MASTER_SITES1			  = https://github.com/crystal-lang/shards/archive/
DISTFILES				  = ${VERSION}.tar.gz \
							crystal-${VERSION}-${MACHINE_ARCH}-openbsd61.tar.gz:0 \
							v${VERSION_SHARDS}.tar.gz:1

NO_CONFIGURE			  = Yes
USE_GMAKE				  = Yes

LIB_DEPENDS				  = converters/libiconv \
							devel/boehm-gc \
							devel/libevent2 \
							devel/llvm \
							devel/pcre \
							devel/libyaml			# Required for Shards

BUILD_DEPENDS			  = shells/bash
RUN_DEPENDS				  = shells/bash

CRYSTAL_CC				  = clang-5.0


do-build:
	${CRYSTAL_CC} -c -o ${WRKSRC}/src/llvm/ext/llvm_ext.o ${WRKSRC}/src/llvm/ext/llvm_ext.cc `llvm-config --cxxflags`
	${CRYSTAL_CC} -c -o ${WRKSRC}/src/ext/sigfault.o ${WRKSRC}/src/ext/sigfault.c `llvm-config --cflags`

	# Crystal
	mkdir ${WRKSRC}/.build
	${CRYSTAL_CC} ${WRKSRC}/../crystal-${VERSION}-${MACHINE_ARCH}-openbsd61.o -o ${WRKSRC}/.build/crystal -rdynamic ${WRKSRC}/src/ext/sigfault.o ${WRKSRC}/src/llvm/ext/llvm_ext.o `(llvm-config --libs --system-libs --ldflags 2> /dev/null)` -lstdc++ -lpcre -lgc -lpthread -levent_core -levent_extra -lssl -liconv

	cd ${WRKSRC} && gmake deps && gmake release=1 CC=${CRYSTAL_CC}  CRYSTAL_CONFIG_PATH="lib:/usr/local/lib/crystal"

	# Shards
	cd ${WRKSRC}/../shards-${VERSION_SHARDS} && CRYSTAL_BIN=${WRKSRC}/.build/crystal gmake release

do-install:
	# Library
	${INSTALL_DATA_DIR} ${PREFIX}/lib/crystal

	# Crystal
	${INSTALL_PROGRAM} ${WRKSRC}/.build/crystal ${PREFIX}/bin
	cp -R ${WRKSRC}/src/* ${PREFIX}/lib/crystal/.

	# Shards
	${INSTALL_PROGRAM} ${WRKSRC}/../shards-${VERSION_SHARDS}/bin/shards ${PREFIX}/bin

.include <bsd.port.mk>
