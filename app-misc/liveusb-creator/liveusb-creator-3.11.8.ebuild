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

COMMON_DEPEND="${PYTHON_DEPS}
dev-python/PyQt4
sys-devel/gettext"

RDEPEND="${COMMON_DEPEND}
sys-boot/syslinux
app-cdr/isomd5sum
dev-python/urlgrabber
>=dev-python/pyparted-2
dev-python/dbus-python
"
DEPEND="${COMMON_DEPEND}
dev-util/desktop-file-utils
dev-python/setuptools
sys-devel/gettext"

#src_install()
#{
#    dodoc PKG-INFO README.txt
#}

