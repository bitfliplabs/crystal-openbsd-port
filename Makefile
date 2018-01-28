# $OpenBSD: Makefile.template,v 1.75 2016/03/20 17:19:49 naddy Exp $

ONLY_FOR_ARCHS			 = amd64

V						 = 0.24.1
V_SHARDS				 = 0.7.2
COMMENT					 = A Ruby-like, statically typed, object oriented, language.
DISTNAME				 = crystal-${V}
CATEGORIES				 = lang

HOMEPAGE				 = https://crystal-lang.org/
MAINTAINER				 = Chris Huxtable <chris@huxtable.ca>

# Apache License, v2.0
PERMIT_PACKAGE_CDROM	 = Yes

WANTLIB					+= ${COMPILER_LIBCXX} c event_core event_extra gc iconv
WANTLIB					+= m pcre yaml z

MASTER_SITES			 = https://github.com/crystal-lang/crystal/archive/
MASTER_SITES0			 = https://assets.bitfliplabs.com/crystal/archive/
MASTER_SITES1			 = https://github.com/crystal-lang/shards/archive/
DISTFILES				 = v${V}.tar.gz \
						   v${V}-openbsd.tar.gz:0 \
						   v${V_SHARDS}.tar.gz:1

COMPILER				 = base-clang ports-clang

BUILD_DEPENDS			 = devel/llvm

NO_CONFIGURE			 = Yes

LIB_DEPENDS				 = converters/libiconv \
						   devel/boehm-gc \
						   devel/libevent2 \
						   devel/pcre \
						   devel/libyaml

RUN_DEPENDS				 = devel/llvm

USE_GMAKE				 = Yes

NO_TEST					 = Yes

do-build:
	${CC} -c -o ${WRKSRC}/src/llvm/ext/llvm_ext.o \
		${WRKSRC}/src/llvm/ext/llvm_ext.cc `llvm-config --cxxflags`
	${CC} -c -o ${WRKSRC}/src/ext/sigfault.o ${WRKSRC}/src/ext/sigfault.c

	mkdir -p ${WRKSRC}/.build
	${CC} ${WRKSRC}/../v${V}-openbsd.o -o ${WRKBUILD}/.build/crystal -rdynamic \
		${WRKSRC}/src/ext/sigfault.o \
		${WRKSRC}/src/llvm/ext/llvm_ext.o \
		`(llvm-config --libs --system-libs --ldflags 2> /dev/null)` \
		-lstdc++ -lpcre -lgc -lpthread -levent_core -levent_extra \
		-lssl -liconv

	cd ${WRKSRC} && ${MAKE_PROGRAM} deps && ${MAKE_PROGRAM} release=1 \
		CC=${CC} CRYSTAL_CONFIG_PATH="lib:${TRUEPREFIX}/lib/crystal"
	cd ${WRKSRC}/../shards-${V_SHARDS} && CRYSTAL_PATH=${WRKSRC}/src \
		CRYSTAL_BIN=${WRKSRC}/.build/crystal ${MAKE_PROGRAM} release

do-install:
	${INSTALL_DATA_DIR} ${PREFIX}/lib/crystal
	${INSTALL_PROGRAM} ${WRKSRC}/.build/crystal ${PREFIX}/bin

	cd ${WRKSRC}/src && find * -type d -exec ${INSTALL_DATA_DIR} \
		"${PREFIX}/lib/crystal/{}" \;
	cd ${WRKSRC}/src && find * -type f -exec ${INSTALL_DATA} \
		"{}" "${PREFIX}/lib/crystal/{}" \;

	${INSTALL_PROGRAM} ${WRKSRC}/../shards-${V_SHARDS}/bin/shards \
		${PREFIX}/bin

.include <bsd.port.mk>
