# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit base qt4-r2 ubuntu-versionator

UURL="mirror://ubuntu/pool/main/s/${PN}"
URELEASE="saucy"
UVER_PREFIX="+13.10.20130918.1"

DESCRIPTION="Single Sign On framework for the Unity desktop"
HOMEPAGE="https://launchpad.net/signon"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.debian.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+debug doc qt5"
RESTRICT="mirror"

DEPEND="dev-qt/qtcore:4
	dev-qt/qtdbus:4
	dev-qt/qtgui:4
	dev-qt/qtsql:4
	dev-qt/qtxmlpatterns:4
	doc? ( app-doc/doxygen )
	qt5? ( dev-qt/qtcore:5
		dev-qt/qtdbus:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtsql:5
		dev-qt/qtxml:5 )"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"

src_prepare() {
	# Fix remotepluginprocess.cpp missing QDebug include on some systems #
	epatch "${FILESDIR}/remotepluginprocess-QDebug-fix.patch"

	# Let portage strip the files #
	sed -e 's:CONFIG         +=:CONFIG += nostrip:g' -i "${S}/common-project-config.pri" || die

	# Ubuntu patchset #
	for patch in $(cat "${WORKDIR}/debian/patches/series" | grep -v \# ); do
		PATCHES+=( "${WORKDIR}/debian/patches/${patch}" )
	done
	base_src_prepare

	use debug && \
		for file in $(grep -r debug * | grep \\.pro | awk -F: '{print $1}' | uniq); do
			sed -e 's:CONFIG -= debug_and_release:CONFIG += debug_and_release:g' \
				-i "${file}"
		done

	use doc || \
		for file in $(grep -r doc/doc.pri * | grep \\.pro | awk -F: '{print $1}'); do
			sed -e '/doc\/doc.pri/d' -i "${file}"
		done
}

src_configure() {
	# Build QT5 support #
	if use qt5; then
		cd "${WORKDIR}"
		cp -rf "${S}" "${S}"-build_qt5
		pushd "${S}"-build_qt5
			/usr/$(get_libdir)/qt5/bin/qmake PREFIX=/usr
		popd
	fi

	# Build QT4 support #
	cd "${WORKDIR}"
	cp -rf "${S}" "${S}"-build_qt4
	pushd "${S}"-build_qt4
		qmake PREFIX=/usr
	popd
}

src_compile() {
	# Build QT5 support #
	if use qt5; then
		pushd "${S}"-build_qt5
			emake
		popd
	fi

	# Build QT4 support #
	pushd "${S}"-build_qt4
		emake
	popd
}

src_install() {
	# Install QT5 support #
	if use qt5; then
		pushd "${S}"-build_qt5
			qt4-r2_src_install
		popd
	fi

	# Install QT4 support #
	pushd "${S}"-build_qt4
		qt4-r2_src_install
	popd
}
