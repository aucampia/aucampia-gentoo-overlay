# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit python-r1

DESCRIPTION="Utilties for embedding and checking md5sums in ISO9660 images"
HOMEPAGE="https://git.fedorahosted.org/cgit/isomd5sum.git/"
SRC_URI="https://git.fedorahosted.org/cgit/${PN}.git/snapshot/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~mips ~sparc ~x86 ~amd64"
IUSE=""

COMMON_DEPEND="
	${PYTHON_DEPS}
"

DEPEND="
	${COMMON_DEPEND}
"

RDEPEND="
	${COMMON_DEPEND}
"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

src_prepare()
{
	epatch "${FILESDIR}"/${P}-makej.patch
	python_copy_sources
}

src_compile()
{
	emake all-devel all-bin
	python_foreach_impl run_in_build_dir emake all-python
}

src_install()
{
	emake DESTDIR="${D}" install-devel install-bin
	python_foreach_impl run_in_build_dir emake DESTDIR="${D}" install-python

	dodoc README
}
