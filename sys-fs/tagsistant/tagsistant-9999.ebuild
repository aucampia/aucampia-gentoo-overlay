# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="A semantic filesystem with."
HOMEPAGE="http://www.tagsistant.net/"
ESVN_REPO_URI="http://svn.gna.org/svn/tagfs/trunk"
inherit subversion

LICENSE="GPL-2"
SLOT="0"
IUSE="libextractor mysql +sqlite"
REQUIRED_USE="|| ( mysql sqlite )"

COMMON_DEPEND="
	dev-libs/glib:2
	sys-fs/fuse
	dev-db/libdbi
	mysql? ( dev-db/libdbi-drivers[mysql] )
	sqlite? ( dev-db/libdbi-drivers[sqlite] )
	libextractor? ( media-libs/libextractor )
"

RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"

DOCS=( "README" "NEWS" "TODO" "AUTHORS" "ChangeLog" "COPYING" "INSTALL" )
