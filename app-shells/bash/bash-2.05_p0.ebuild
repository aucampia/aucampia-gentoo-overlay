# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic toolchain-funcs

PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_PV=${MY_PV/_/-}
MY_P=${PN}-${MY_PV}
[[ ${PV} != *_p* ]] && PLEVEL=0
patches() {
	local opt=$1 plevel=${2:-${PLEVEL}} pn=${3:-${PN}} pv=${4:-${MY_PV}}
	[[ ${plevel} -eq 0 ]] && return 1
	eval set -- {1..${plevel}}
	set -- $(printf "${pn}${pv/\.}-%03d " "$@")
	if [[ ${opt} == -s ]] ; then
		echo "${@/#/${DISTDIR}/}"
	else
		local u
		for u in ftp://ftp.cwru.edu/pub/bash mirror://gnu/${pn} ; do
			printf "${u}/${pn}-${pv}-patches/%s " "$@"
		done
	fi
}

READLINE_VER="4.1"

DESCRIPTION="The standard GNU Bourne again shell"
HOMEPAGE="https://www.gnu.org/software/bash/"
SRC_URI="mirror://gnu/bash/${MY_P}.tar.gz $(patches)"
# http://ftp.gnu.org/gnu/bash/${MY_P}.tar.gz 

LICENSE="GPL-2"
SLOT="${MY_PV}"
KEYWORDS="~amd64"
IUSE="afs +net +readline doc"

DEPEND=">=sys-libs/ncurses-5.2-r2
	readline? ( >=sys-libs/readline-${READLINE_VER} )
	doc? ( app-text/texi2html app-text/ghostscript-gpl )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if is-flag -malign-double ; then #7332
		eerror "Detected bad CFLAGS '-malign-double'.  Do not use this"
		eerror "as it breaks LFS (struct stat64) on x86."
		die "remove -malign-double from your CFLAGS mr ricer"
	fi
}

src_unpack() {
	unpack ${MY_P}.tar.gz
}

src_prepare() {
	# Include official patches
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)

	# Clean out local libs so we know we use system ones
	#rm -rf lib/{readline,termcap}/*
	#touch lib/{readline,termcap}/Makefile.in # for config.status
	#sed -ri -e 's:\$[(](RL|HIST)_LIBSRC[)]/[[:alpha:]]*.h::g' Makefile.in || die

	epatch_user
}

src_configure() {

	# Force pgrp synchronization
	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=81653
	export bash_cv_pgrp_pipe=yes

	# For descriptions of these, see config-top.h
	# bashrc/#26952 bash_logout/#90488 ssh/#24762
	append-cppflags \
		-DDEFAULT_PATH_VALUE=\'\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\' \
		-DSTANDARD_UTILS_PATH=\'\"/bin:/usr/bin:/sbin:/usr/sbin\"\' \
		-DSYS_BASHRC=\'\"/etc/bash/bashrc\"\' \
		-DSYS_BASH_LOGOUT=\'\"/etc/bash/bash_logout\"\' \
		-DNON_INTERACTIVE_LOGIN_SHELLS \
		-DSSH_SOURCE_BASHRC

	# Don't even think about building this statically without
	# reading Bug 7714 first.  If you still build it statically,
	# don't come crying to us with bugs ;).
	#use static && export LDFLAGS="${LDFLAGS} -static"

	# Historically, we always used the builtin readline, but since
	# our handling of SONAME upgrades has gotten much more stable
	# in the PM (and the readline ebuild itself preserves the old
	# libs during upgrades), linking against the system copy should
	# be safe.
	# Exact cached version here doesn't really matter as long as it
	# is at least what's in the DEPEND up above.
	export ac_cv_rl_version=${READLINE_VER}

	# Force linking with system curses ... the bundled termcap lib
	# sucks bad compared to ncurses.  For the most part, ncurses
	# is here because readline needs it.  But bash itself calls
	# ncurses in one or two small places :(.
		
	#	--with-glibc-malloc \

	tc-export AR #444070
	econf \
		--with-installed-readline=/ \
		--with-curses \
		$(use_with afs) \
		$(use_enable net net-redirections) \
		--disable-profiling \
		--without-gnu-malloc \
		$(use_enable readline) \
		$(use_enable readline history) \
		$(use_enable readline bang-history)

}

src_compile() {
	emake -j1 #102426
	use doc && 
	{
		emake TEXI2HTML=texi2html doc
		for ps in doc/*.ps
		do
			ps2pdf "${ps}" "${ps%.ps}.pdf" || die "failed to convert ${ps} to ${ps%.ps}.pdf: ${?}"
		done
	}
}

src_install() {
	into /
	newbin bash bash-${SLOT}
	newbin bashbug bashbug-${SLOT}

	newman doc/bash.1 bash-${SLOT}.1
	newman doc/bashbug.1 bashbug-${SLOT}.1

	insinto /usr/share/info
	newins doc/bashref.info bash-${SLOT}.info
	dosym bash-${SLOT}.info /usr/share/info/bashref-${SLOT}.info

	use doc && {
		#insinto "/usr/share/${PF}"
		#newins doc/*.{ps,dvi,html,pdf}
		dodoc doc/*.{ps,dvi,html,pdf}
	}

	dodoc README NEWS AUTHORS CHANGES COMPAT Y2K doc/FAQ doc/INTRO
}
