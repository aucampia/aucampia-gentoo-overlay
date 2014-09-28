# Copyright 2014 Iwan Aucamp
# vim: filetype=make :
# vim: set ts=4 sw=4 :

define newline


endef

colon=:

repo_name=aucampia-gentoo-overlay

repoxml_list= \
	layman \
	gpo.zugaina.org \


repoxml_layman_url=http://www.gentoo.org/proj/en/overlays/repositories.xml
repoxml_gpo.zugaina.org_url=http://gpo.zugaina.org/lst/gpo-repositories.xml

overlay_list= \
	layman:java \
	layman:sabayon \
	layman:xarthisius \
	layman:unity-gentoo \
	layman:sebasmagri \
	layman:last-hope \
	layman:godin \
	layman:squeezebox \
	layman:wichtounet \
	layman:kork \
	layman:eroen \
	layman:ixit \
	gpo.zugaina.org:bgo-overlay \


external_list= \


__external_list= \
	unity-gentoo:dev-libs/libaccounts-glib \
	unity-gentoo:dev-libs/libsignon-glib \
	unity-gentoo:unity-base/signon \
	unity-gentoo:eclass/ubuntu-versionator.eclass \


indent=\t\t\t\t\t\t

help:
	@#     ++++++++++++++++++++++++++++++++++++++++
	@#     ========================================
	@#     ================================================================================
	@echo "= $(repo_name) makefile help"
	@echo
	@echo "== targets"
	@#     ++++++++++++++++++++++++++++++
	@echo
	@echo -e "repoxml\r$(indent)fetch/update repo xml files"
	@for item in $(repoxml_list); do \
		echo -e "repoxml-$${item}\r$(indent)fetch/update $${item} repo xml file"; \
	done
	@echo
	@echo -e "overlay\r$(indent)fetch/update all upstream overlays"
	@for item in $(overlay_list); do \
		echo -e "overlay-$${item//*:}\r$(indent)fetch/update $${item//*:} upstream overlay"; \
	done
	@echo
	@echo -e "external\r$(indent)fetch/update all external resources"
	@for item in $(external_list); do \
		echo -e "external-$${item//*:}\r$(indent)fetch/update $${item//*:} upstream external resource"; \
	done


repoxml: $(foreach __item,$(repoxml_list),repoxml-$(__item))
	@echo "$(@) <- $(^)"

$(foreach __item,$(repoxml_list),$(info ../aucampia-gentoo-overlay.misc/upstream/repoxml/$(__item)/repositories.xml: repoxml-$(__item)))
$(foreach __item,$(repoxml_list),$(eval ../aucampia-gentoo-overlay.misc/upstream/repoxml/$(__item)/repositories.xml: repoxml-$(__item)))

repoxml-%:
	@echo "$(@) <- $(^)"
	@echo "repoxml_$(@:repoxml-%=%)_url=$(repoxml_$(@:repoxml-%=%)_url)"
	mkdir -p ../aucampia-gentoo-overlay.misc/upstream/repoxml/$(@:repoxml-%=%)
	curl --insecure -L $(repoxml_$(@:repoxml-%=%)_url) -o ../aucampia-gentoo-overlay.misc/upstream/repoxml/$(@:repoxml-%=%)/repositories.xml

overlay: $(foreach __item,$(overlay_list),overlay-$(word 2,$(subst :, ,$(__item))))
	@echo "$(@) <- $(^)"

$(foreach __item,$(overlay_list),$(info overlay-$(word 2,$(subst :, ,$(__item))): ../aucampia-gentoo-overlay.misc/upstream/repoxml/$(word 1,$(subst :, ,$(__item)))/repositories.xml))
$(foreach __item,$(overlay_list),$(eval overlay-$(word 2,$(subst :, ,$(__item))): ../aucampia-gentoo-overlay.misc/upstream/repoxml/$(word 1,$(subst :, ,$(__item)))/repositories.xml))

overlay-%:
	@echo "$(@) <- $(^)"
	@echo "dest: ../aucampia-gentoo-overlay.misc/upstream/overlay/$(@:overlay-%=%)/"
	@echo "overlay_$(@:overlay-%=%)_url=$(overlay_$(@:overlay-%=%)_url)"
	@overlay_name=$(@:overlay-%=%); \
	overlay_type=$$( xmllint --xpath "/repositories/repo[name='$${overlay_name}']/source[1]/@type" $(<) 2>/dev/null | head -1 | sed '1aecho $$type'| bash ); \
	overlay_url=$$( xmllint --xpath "/repositories/repo[name='$${overlay_name}']/source[1]/text()" $(<) 2>/dev/null | head -1 ); \
	echo "$${overlay_name}=$${overlay_type}=$${overlay_url}"; \
	mkdir -p ../aucampia-gentoo-overlay.misc/upstream/overlay/$${overlay_name}/; \
	case $${overlay_type} in \
		(rsync) rsync -avz $${overlay_url}/ ../aucampia-gentoo-overlay.misc/upstream/overlay/$${overlay_name}/;; \
		(git) \
			if [ -d "../aucampia-gentoo-overlay.misc/upstream/overlay/$${overlay_name}/.git" ]; \
			then \
				git -C ../aucampia-gentoo-overlay.misc/upstream/overlay/$${overlay_name}/ pull; \
			else \
				git clone $${overlay_url}/ ../aucampia-gentoo-overlay.misc/upstream/overlay/$${overlay_name}/; \
			fi;; \
	esac

external: $(foreach __item,$(external_list),external-$(word 2,$(subst :, ,$(__item))))
	@echo "$(@) <- $(^)"

$(foreach __item,$(external_list),$(info external-$(word 2,$(subst :, ,$(__item))): overlay-$(word 1,$(subst :, ,$(__item)))))
$(foreach __item,$(external_list),$(eval external-$(word 2,$(subst :, ,$(__item))): overlay-$(word 1,$(subst :, ,$(__item)))))


define external_template
external-$(1):
	@echo "$$(@) <- $$(^)"
	@echo "external=$$(@:external-%=%)"
	@echo "overlay=$$(<:overlay-%=%)"
	mkdir -p $$(dir $$(@:external-%=%))
	rsync -v -c -rptgo ../aucampia-gentoo-overlay.misc/upstream/overlay/$$(<:overlay-%=%)/$$(@:external-%=%) $$(dir $$(@:external-%=%))
endef

$(foreach __item,$(external_list),$(info $(call external_template,$(word 2,$(subst :, ,$(__item))))))
$(foreach __item,$(external_list),$(eval $(call external_template,$(word 2,$(subst :, ,$(__item))))))
