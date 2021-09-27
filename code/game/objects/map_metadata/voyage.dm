
/obj/map_metadata/voyage
	ID = MAP_VOYAGE
	title = "Voyage"
	no_winner ="The ship is on the way."
//	lobby_icon_state = "imperial"
	caribbean_blocking_area_types = list(/area/caribbean/no_mans_land/invisible_wall/)
	respawn_delay = 0


	faction_organization = list(
		BRITISH)

	roundend_condition_sides = list(
		list(BRITISH) = /area/caribbean/british/ship/lower,
		)
	age = "1713"
	ordinal_age = 3
	faction_distribution_coeffs = list(BRITISH = 1)
	battle_name = "Transatlantic Voyage"
	mission_start_message = "<font size=4>The travel is starting. Hold the ship against the pirates!</font>"
	is_singlefaction = TRUE
	is_RP = TRUE
	var/first_event_done = FALSE
	var/second_event_done = FALSE
	var/third_event_done = FALSE
	var/fourth_event_done = FALSE
	var/fifth_event_done = FALSE
	var/do_first_event = 1000
	var/do_second_event = 1000
	var/do_third_event = 1000
	var/do_fourth_event = 1000
	var/do_fifth_event = 1000
/obj/map_metadata/voyage/check_events()
	if ((world.time >= do_first_event) && !first_event_done)
		world << "Pirates are approaching!"
		first_event_done = TRUE
		spawn(200)
			for (var/obj/effect/area_teleporter/AT)
				if (AT.id == "one")
					AT.Activated()
					world << "Pirates are trying to board the ship!"
					var/tdir = SOUTH
					for(var/obj/structure/grapplehook/G in world)
						if (G.owner == "PIRATES")
							G.dir = tdir
							G.deploy()
					return TRUE
	if ((world.time >= do_second_event) && !second_event_done)
		world << "Pirates are approaching!"
		second_event_done = TRUE
		spawn(200)
			for (var/obj/effect/area_teleporter/AT)
				if (AT.id == "two")
					AT.Activated()
					world << "Pirates are trying to board the ship!"
					var/tdir = SOUTH
					for(var/obj/structure/grapplehook/G in world)
						if (G.owner == "PIRATES")
							G.dir = tdir
							G.deploy()
					return TRUE
	if ((world.time >= do_third_event) && !third_event_done)
		world << "Pirates are approaching!"
		third_event_done = TRUE
		spawn(200)
			for (var/obj/effect/area_teleporter/AT)
				if (AT.id == "three")
					AT.Activated()
					world << "Pirates are trying to board the ship!"
					return TRUE
	if ((world.time >= do_fourth_event) && !fourth_event_done)
		world << "Pirates are approaching!"
		fourth_event_done = TRUE
		spawn(200)
			for (var/obj/effect/area_teleporter/AT)
				if (AT.id == "fourth")
					AT.Activated()
					world << "Pirates are trying to board the ship!"
					return TRUE
	if ((world.time >= do_fifth_event) && !fifth_event_done)
		world << "Pirates are approaching!"
		fifth_event_done = TRUE
		spawn(200)
			for (var/obj/effect/area_teleporter/AT)
				if (AT.id == "fifth")
					AT.Activated()
					world << "Pirates are trying to board the ship!"
					return TRUE
	else return FALSE

/obj/map_metadata/voyage/faction2_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 100000 || admin_ended_all_grace_periods)

/obj/map_metadata/voyage/faction1_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 100000 || admin_ended_all_grace_periods)

/obj/map_metadata/voyage/job_enabled_specialcheck(var/datum/job/J)
	..()
	if (J.is_RP == TRUE)
		. = FALSE
	else if (J.is_army == TRUE)
		. = FALSE
	else if (J.is_prison == TRUE)
		. = FALSE
	else if (J.is_ww1 == TRUE)
		. = FALSE
	else if (J.is_coldwar == TRUE)
		. = FALSE
	else if (J.is_medieval == TRUE)
		. = FALSE
	else if (J.is_marooned == TRUE)
		. = FALSE
	else if (istype(J, /datum/job/pirates/battleroyale))
		. = FALSE
	else if (istype(J, /datum/job/indians/tribes))
		. = FALSE
	else
		. = TRUE

/obj/map_metadata/voyage/New() // since DM doesn't want to attribute random vars at the beggining...
	..()
	do_first_event = rand(600,960)
	do_second_event = do_first_event  + rand(6000,9600)
	do_third_event = do_second_event  + rand(6000,9600)
	do_fourth_event = do_third_event  + rand(5000,8000)
	do_fifth_event = do_fourth_event  + rand(4000,7000)

///////////////Specific objects////////////////////
/obj/structure/voyage_shipwheel
	name = "ship wheel"
	desc = "Used to steer the ship."
	icon = 'icons/obj/vehicles/vehicleparts_boats.dmi'
	icon_state = "ship_wheel"
	layer = 2.99
	var/mob/living/user = null

/obj/structure/voyage_tablemap
	name = "map"
	desc = "A map of the regeion. Used by the captain to plan the next moves."
	icon = 'icons/obj/items.dmi'
	icon_state = "table_map"
	layer = 3.2
	var/mob/living/user = null

/obj/structure/voyage_sextant
	name = "sextant"
	desc = "Used to determine the current latitude and longitude using the sun and stars."
	icon = 'icons/obj/items.dmi'
	icon_state = "sextant_tool"
	layer = 3.2
	var/mob/living/user = null

/obj/structure/closet/crate/chest/treasury/ship
	name = "ship's treasury"
	desc = "Where the ship's treasury is stored."
	faction = "ship"