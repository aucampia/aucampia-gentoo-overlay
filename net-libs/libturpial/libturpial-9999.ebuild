# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1 git-r3

DESCRIPTION="A library that handles multiple microblogging protocols."
HOMEPAGE="http://turpial.org.ve/"
EGIT_REPO_URI="https://github.com/satanas/libturpial.git"
EGIT_BRANCH="development"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	${PYTHON_DEPS}
	>=dev-python/simplejson-1.9.2[${PYTHON_USEDEP}]
	>=dev-python/oauth-1.0.1[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0.0[${PYTHON_USEDEP}]
"

DEPEND="
	${COMMON_DEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

RDEPEND="
	${COMMON_DEPEND}
"

DOCS=( "AUTHORS" "COPYING" "ChangeLog" "README.rst" )
