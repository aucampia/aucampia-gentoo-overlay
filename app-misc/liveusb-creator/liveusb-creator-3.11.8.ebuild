# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

DESCRIPTION="Cross-platform tool for installing live operating systems on USB flash drives."
HOMEPAGE="https://fedorahosted.org/liveusb-creator/"
SRC_URI="https://fedorahosted.org/releases/l/i/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~mips ~sparc ~x86 ~amd64"
IUSE=""

COMMON_DEPEND="${PYTHON_DEPS}"

RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

#src_install()
#{
#    dodoc PKG-INFO README.txt
#}

