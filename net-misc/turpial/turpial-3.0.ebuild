# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

MY_PN="Turpial"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A lightweight and beautiful microblogging client written in Python"
HOMEPAGE="http://turpial.org.ve/"
SRC_URI="https://github.com/satanas/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
#SRC_URI="https://github.com/satanas/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=" ~amd64 ~x86"
IUSE="gtk qt4"

#REQUIRED_USE="|| ( gtk qt4 )"

COMMON_DEPEND="
	${PYTHON_DEPS}
	>=net-libs/libturpial-0.8.0[${PYTHON_USEDEP}]
	>=dev-python/notify-python-0.1.1[${PYTHON_USEDEP}]
	>=dev-python/gst-python-0.10[${PYTHON_USEDEP}]
	>=dev-python/Babel-0.9.1[${PYTHON_USEDEP}]
	gtk? ( dev-python/pygtk:2[${PYTHON_USEDEP}] dev-python/gtkspell-python dev-python/pywebkitgtk[${PYTHON_USEDEP}] )
	qt4? ( dev-python/PyQt4 )
"

DEPEND="
	${COMMON_DEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

RDEPEND="
	${COMMON_DEPEND}
"

DOCS=( "AUTHORS" "ChangeLog" "COPYING" "README.rst" "THANKS" "TRANSLATORS" )

PATCHES=( "${FILESDIR}/turpial-3.0-destop.patch" )

S="${WORKDIR}/${MY_P}"
