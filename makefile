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
	layman:sabayon \
	gpo.zugaina.org:bgo-overlay \
	layman:xarthisius \
	layman:unity-gentoo \


external_list= \
	unity-gentoo:dev-libs/libaccounts-glib \
	unity-gentoo:dev-libs/libsignon-glib \

help:
	@#     ++++++++++++++++++++++++++++++++++++++++
	@#     ========================================
	@#     ================================================================================
	@echo "= $(repo_name) makefile help"
	@echo "== targets"
	@#     ++++++++++++++++++++++++++++++
	@echo -e "repoxml :\r\t\t\t\t\tfetch/update repo xml files"
	@for item in $(repoxml_list); do \
		echo -e "repoxml-$${item} :\r\t\t\t\t\tfetch/update $${item} repo xml file"; \
	done
	@echo -e "overlay :\r\t\t\t\t\tfetch/update all upstream overlays"
	@for item in $(overlay_list); do \
		echo -e "overlay-$${item//*:} :\r\t\t\t\t\tfetch/update $${item} upstream overlay"; \
	done
	@echo -e "external :\r\t\t\t\t\tfetch/update all external ebuilds"
	@for item in $(external_list); do \
		echo -e "external-$${item//*:} :\r\t\t\t\t\tfetch/update $${item} upstream external ebuild"; \
	done


repoxml: $(foreach __item,$(repoxml_list),repoxml-$(__item))
	@echo "$(@) <- $(^)"

$(foreach __item,$(repoxml_list),$(info upstream/repoxml/$(__item)/repositories.xml: repoxml-$(__item)))
$(foreach __item,$(repoxml_list),$(eval upstream/repoxml/$(__item)/repositories.xml: repoxml-$(__item)))

repoxml-%:
	@echo "$(@) <- $(^)"
	@echo "repoxml_$(@:repoxml-%=%)_url=$(repoxml_$(@:repoxml-%=%)_url)"
	mkdir -p upstream/repoxml/$(@:repoxml-%=%)
	curl -L $(repoxml_$(@:repoxml-%=%)_url) -o upstream/repoxml/$(@:repoxml-%=%)/repositories.xml

overlay: $(foreach __item,$(overlay_list),overlay-$(word 2,$(subst :, ,$(__item))))
	@echo "$(@) <- $(^)"

$(foreach __item,$(overlay_list),$(info overlay-$(word 2,$(subst :, ,$(__item))): upstream/repoxml/$(word 1,$(subst :, ,$(__item)))/repositories.xml))
$(foreach __item,$(overlay_list),$(eval overlay-$(word 2,$(subst :, ,$(__item))): upstream/repoxml/$(word 1,$(subst :, ,$(__item)))/repositories.xml))

overlay-%:
	@echo "$(@) <- $(^)"
	@echo "dest: upstream/overlay/$(@:overlay-%=%)/"
	@echo "overlay_$(@:overlay-%=%)_url=$(overlay_$(@:overlay-%=%)_url)"
	@overlay_name=$(@:overlay-%=%); \
	overlay_type=$$( xmllint --xpath "/repositories/repo[name='$${overlay_name}']/source[1]/@type" $(<) 2>/dev/null | head -1 | sed '1aecho $$type'| bash ); \
	overlay_url=$$( xmllint --xpath "/repositories/repo[name='$${overlay_name}']/source[1]/text()" $(<) 2>/dev/null | head -1 ); \
	echo "$${overlay_name}=$${overlay_type}=$${overlay_url}"; \
	mkdir -p upstream/overlay/$${overlay_name}/; \
	case $${overlay_url//:*} in \
		(rsync) rsync -avz $${overlay_url}/ upstream/overlay/$${overlay_name}/;; \
		(git) \
			if [ -d "upstream/overlay/$${overlay_name}/.git" ]; \
			then \
				git -C upstream/overlay/$${overlay_name}/ pull; \
			else \
				git clone $${overlay_url}/ upstream/overlay/$${overlay_name}/; \
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
	mkdir -p $$(@:external-%=%)/
	rsync -v -c -rptgo upstream/overlay/$$(<:overlay-%=%)/$$(@:external-%=%)/ $$(@:external-%=%)/
endef

$(foreach __item,$(external_list),$(info $(call external_template,$(word 2,$(subst :, ,$(__item))))))
$(foreach __item,$(external_list),$(eval $(call external_template,$(word 2,$(subst :, ,$(__item))))))
