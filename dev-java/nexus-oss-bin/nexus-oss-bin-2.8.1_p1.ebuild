# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit java-pkg-2 user eutils systemd

MY_PV=${PV%_p*}-`printf "%02d" "${PV//*_p/}"`
MY_PN=nexus
MY_P=${MY_PN}-${MY_PV}

extra_PN=nexus-gentoo-extra
extra_PV=0.1.1
extra_P=${extra_PN}-${extra_PV}

S="${WORKDIR}/${MY_P}"
extra_S="${WORKDIR}/${extra_P}"

DESCRIPTION="A repository management system"
HOMEPAGE="http://www.sonatype.org/nexus/"
SRC_URI="
	http://www.sonatype.org/downloads/${MY_P}-bundle.tar.gz
	https://github.com/aucampia/${extra_PN}/archive/${extra_PV}.tar.gz -> ${extra_P}.tar.gz
"

LICENSE="sonatype-fpl-nexus-2.x EPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

COMMON_DEPEND="
	>=virtual/jre-1.7
"

RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"

DOCS="LICENSE.txt NOTICE.txt"

PATCHES=( "${FILESDIR}/nexus-2.8.1_p1-distarch.patch" )

my_user="${MY_PN}"
my_group="${my_user}"

if [[ "${SLOT%/*}" == "0" ]] ; then
	my_slot_postfix=""
else
	my_slot_postfix="-${SLOT%/*}"
fi

my_svcname="${MY_PN}${my_slot_postfix}"

pkg_setup() {
	enewgroup "${my_group}"
	enewuser "${my_user}" -1 -1 -1 "${my_group}"
}

src_configure() {
	sed -i \
		-e "s:@JAVA_PKG_NAME@:${PN}${my_slot_postfix}:g" \
		"${extra_S}/openrc/${MY_PN}."{initd,confd}
}

src_install() {
	newinitd "${extra_S}/openrc/${MY_PN}.initd" "${my_svcname}"
	newconfd "${extra_S}/openrc/${MY_PN}.confd" "${my_svcname}"
	#systemd_newunit "${extra_S}/systemd/${MY_PN}.service" "${my_svcname}.service"

	eshopts_push -s extglob
	local jar
	for jar in lib/*.jar
	do
		local newjar="${jar}"
		newjar="${newjar%%-[0-9]*[0-9].jar}.jar"
		newjar="${newjar#lib/}"
		java-pkg_newjar "${jar}" "${newjar}"
	done
	eshopts_pop

	insinto "/etc/${my_svcname}/"
	doins "${extra_S}/etc/"*

	insinto "/usr/share/${my_svcname}/webapps"
	doins -r nexus

	local udir
	for udir in "/var/"{log,tmp,lib}"/${my_svcname}"
	do
		dodir "${udir}"
		fperms ugo=rX,u+w "${udir}"
		fowners "${my_user}:${my_group}" "${udir}"
	done

	dodoc ${DOCS}
}
