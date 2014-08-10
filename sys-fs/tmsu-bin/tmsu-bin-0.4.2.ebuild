# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

#inherit eutils

MY_PN=${PN%-bin}
MY_PV=${PV}
MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="Tool for tagging your files and a VFS for tagged view of your files."
HOMEPAGE="http://tmsu.org/"
SRC_URI="
	${SRC_URI}
	amd64? ( https://bitbucket.org/oniony/${MY_PN}/downloads/${MY_PN}-x86_64-${MY_PV}.tgz )
	x86? ( https://bitbucket.org/oniony/${MY_PN}/downloads/${MY_PN}-i686-${MY_PV}.tgz )
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="zsh-completion"

COMMON_DEPEND="
"

RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	sys-apps/findutils
	${COMMON_DEPEND}
"

if use amd64
then
	S="${WORKDIR}/${MY_PN}-x86_64-${MY_PV}"
elif use x86
then
	S="${WORKDIR}/${MY_PN}-i686-${MY_PV}"
fi

DOCS=( "COPYING" "README.md" )

src_unpack()
{
	unpack ${A}
	find . -name '*.gz' -print0 | xargs -0 gunzip
}

src_install()
{
	dodoc "${DOCS[@]}"
	doman man/tmsu.1
	dobin bin/{mount.tmsu,tmsu}
	if use zsh-completion
	then
		insinto /usr/share/zsh/site-functions
		doins misc/zsh/_tmsu
	fi
}
