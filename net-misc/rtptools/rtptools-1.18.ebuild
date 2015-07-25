# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="A number of small applications that can be used for processing RTP data."
HOMEPAGE="http://www.cs.columbia.edu/irt/software/rtptools/"
SRC_URI="http://www.cs.columbia.edu/irt/software/${PN}/download/${P}.tar.gz"

LICENSE="rtptools"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

COMMON_DEPEND=""

DEPEND="
	${COMMON_DEPEND}
"

RDEPEND="
	${COMMON_DEPEND}
"

DOCS=( "ChangeLog.html" "COPYRIGHT" "README" )
