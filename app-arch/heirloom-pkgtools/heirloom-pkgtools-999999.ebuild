# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

ECVS_AUTH="pserver"
ECVS_USER="anonymous"
ECVS_SERVER="heirloom.cvs.sourceforge.net:/cvsroot/heirloom"
ECVS_MODULE="heirloom-pkgtools"
ECVS_PASS=""
ECVS_CVS_OPTIONS="-dP"
[[ ${PV} == 999999 ]] && inherit cvs
inherit eutils

DESCRIPTION="The Heirloom Packaging Tools"
HOMEPAGE="http://heirloom.sourceforge.net/pkgtools.html"
[[ ${PV} == 999999 ]] || SRC_URI="http://sourceforge.net/projects/heirloom/files/${PN}/${PV}/${P}.tar.bz2/download -> ${P}.tar.bz2"

LICENSE="CDDL caldera"
SLOT="0"
[[ ${PV} == 999999 ]] || KEYWORDS="~amd64"
IUSE=""

COMMON_DEPEND="
	app-shells/heirloom-sh
"

DEPEND="
	${COMMON_DEPEND}
	sys-devel/heirloom-devtools
"

RDEPEND="
	${COMMON_DEPEND}
"

[[ ${PV} == 999999 ]] && S="${WORKDIR}/${PN}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-open_ocreat-r0.patch || die "Failed to apply ${PN}-open_ocreat-r0.patch"
	insert_at=$( gawk '!/\s*#/{ last=NR } /Do not modify anything below here./{ printf("%s\n",last) } ' "${S}/mk.config" )
	test "${?}" -eq "0" || die "Could not find the position to insert source code in mk.config"
	{
		echo "SHELL=/bin/jsh"
		echo "LEX=/usr/ccs/bin/lex"
		echo "YACC=/usr/ccs/bin/yacc"
		echo "CC=$(tc-getCC)"
		echo
	} | sed -i "${insert_at}r/dev/stdin" "${S}/mk.config"
}

src_install() {
	# dont strip ... - put it here incase something wants real one
	emake "STRIP=true" "ROOT=${D}" install || die
}

pkg_postinst() {
	elog "You may want to add /usr/5bin or /usr/ucb to \$PATH"
	elog "to enable using the apps of heirloom toolchest by default."
	elog "Man pages are installed in /usr/share/man/5man/"
	elog "You may need to set \$MANPATH to access them."
}
