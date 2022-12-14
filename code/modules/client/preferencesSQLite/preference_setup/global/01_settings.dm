/datum/category_item/player_setup_item/player_global/settings
	name = "Settings"
	sort_order = 2

/datum/category_item/player_setup_item/player_global/settings/sanitize_preferences()
	// Ensure our preferences are lists.
	if (!istype(pref.preferences_enabled, /list))
		pref.preferences_enabled = list()
	if (!istype(pref.preferences_disabled, /list))
		pref.preferences_disabled = list()

	// Arrange preferences that have never been enabled/disabled.
	var/list/client_preference_keys = list()
	for (var/cp in get_client_preferences())
		var/datum/client_preference/client_pref = cp
		client_preference_keys += client_pref.key
		if ((client_pref.key in pref.preferences_enabled) || (client_pref.key in pref.preferences_disabled))
			continue

		if (client_pref.enabled_by_default)
			pref.preferences_enabled += client_pref.key
		else
			pref.preferences_disabled += client_pref.key

	// Clean out preferences that no longer exist.
	for (var/key in pref.preferences_enabled)
		if (!(key in client_preference_keys))
			pref.preferences_enabled -= key
	for (var/key in pref.preferences_disabled)
		if (!(key in client_preference_keys))
			pref.preferences_disabled -= key

//	pref.lastchangelog	= sanitize_text(pref.lastchangelog, initial(pref.lastchangelog))
//	pref.default_slot	= sanitize_integer(pref.default_slot, TRUE, config.character_slots, initial(pref.default_slot))

/datum/category_item/player_setup_item/player_global/settings/content(var/mob/user)
	. = list()
	. += "<b><big>Настройки</big></b><br><br>"
	. += "<table>"
	var/mob/pref_mob = preference_mob()
	for (var/cp in get_client_preferences())
		var/datum/client_preference/client_pref = cp
		if (!client_pref.may_toggle(pref_mob))
			continue

		. += "<tr><td>[client_pref.description]: </td>"
		if (pref_mob.is_preference_enabled(client_pref.key))
			. += "<td><b>[client_pref.enabled_description]</b></td> <td><a href='?src=\ref[src];toggle_off=[client_pref.key]'>[client_pref.disabled_description]</a></td>"
		else
			. += "<td><a  href='?src=\ref[src];toggle_on=[client_pref.key]'>[client_pref.enabled_description]</a></td> <td><b>[client_pref.disabled_description]</b></td>"
		. += "</tr>"

	. += "</table>"
	return jointext(., "")

/datum/category_item/player_setup_item/player_global/settings/OnTopic(var/href,var/list/href_list, var/mob/user)
	var/mob/pref_mob = preference_mob()
	if (href_list["toggle_on"])
		. = pref_mob.set_preference(href_list["toggle_on"], TRUE)
	else if (href_list["toggle_off"])
		. = pref_mob.set_preference(href_list["toggle_off"], FALSE)
	if (.)
		return TOPIC_REFRESH

	return ..()
