# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

DESCRIPTION="A library that handles multiple microblogging protocols."
HOMEPAGE="http://turpial.org.ve/"
SRC_URI="https://github.com/satanas/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=" ~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	${PYTHON_DEPS}
	>=dev-python/simplejson-1.9.2[${PYTHON_USEDEP}]
	dev-python/oauth[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"

DEPEND="
	${COMMON_DEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

RDEPEND="
	${COMMON_DEPEND}
"

DOCS=( "AUTHORS" "ChangeLog" "COPYING" "README.rst" )
