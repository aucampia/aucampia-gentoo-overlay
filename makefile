# vim: filetype=make :
# vim: set ts=4 sw=4 :
repo_name=aucampia-gentoo-overlay

repoxml_list=layman gpo.zugaina.org
repoxml_layman_url=http://www.gentoo.org/proj/en/overlays/repositories.xml
repoxml_gpo.zugaina.org_url=http://gpo.zugaina.org/lst/gpo-repositories.xml

overlay_list=sabayon bgo-overlay xarthisius unity-gentoo

help:
	@#     ++++++++++++++++++++++++++++++++++++++++
	@#     ========================================
	@#     ================================================================================
	@echo "= $(repo_name) makefile help"
	@echo "== targets"
	@#     ++++++++++++++++++++++++++++++
	@echo -e "repoxml :\r\t\t\t\tfetch repo xml files"
	@for item in $(repoxml_list); do \
		echo -e "repoxml-$${item} :\r\t\t\t\tfetch $${item} repo xml file"; \
	done
	@echo -e "overlay :\r\t\t\t\tfetch/update all upstream overlays"
	@for item in $(overlay_list); do \
		echo -e "overlay.$${item} :\r\t\t\t\tfetch/update $${item} upstream overlay"; \
	done


repoxml: $(foreach repoxml_item,$(repoxml_list),repoxml-$(repoxml_item))
	@echo "$(@) <- $(^)"

repoxml-%:
	@echo "$(@) <- $(^)"
	@echo "repoxml_$(patsubst repoxml-%,%,$(@))_url=$(repoxml_$(patsubst repoxml-%,%,$(@))_url)"
	mkdir -p upstream/repoxml/$(patsubst repoxml-%,%,$(@))
	cd upstream/repoxml/$(patsubst repoxml-%,%,$(@)) && curl -OJ $(repoxml_$(patsubst repoxml-%,%,$(@))_url)
	

#$(info $(foreach overlay_item,$(overlay_list),overlay-$(overlay_item)))

overlay: $(foreach overlay_item,$(overlay_list),overlay-$(overlay_item))
	@echo "$(@) <- $(^)"

overlay-%:
	@echo "$(@) <- $(^)"
	@#echo "overlay_$(patsubst overlay-%,%,$(@))_url=$(overlay_$(patsubst overlay-%,%,$(@))_url)"
	@overlay_name=$(patsubst overlay-%,%,$(@)); \
	overlay_type=$$( xmllint --xpath "/repositories/repo[name='$${overlay_name}']/source[1]/@type" upstream/repoxml/*/*.xml 2>/dev/null | head -1 | sed '1aecho $$type'| bash ); \
	overlay_url=$$( xmllint --xpath "/repositories/repo[name='$${overlay_name}']/source[1]/text()" upstream/repoxml/*/*.xml 2>/dev/null | head -1 ); \
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

