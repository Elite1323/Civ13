////////////////////////FRAMES//////////////////////
/obj/structure/vehicleparts/frame
	name = "steel frame"
	desc = "a steel vehicle frame."
	icon = 'icons/obj/vehicleparts.dmi'
	icon_state = "frame_steel"
	powerneeded = 0
	flammable = FALSE
	layer = 2.98
	var/resistance = 150
	var/obj/structure/vehicleparts/axis/axis = null
	//format: type of wall, opacity, density, armor, current health, can open/close, is open?
	var/list/w_front = list("",FALSE,FALSE,0,40,FALSE,FALSE)
	var/list/w_back = list("",FALSE,FALSE,0,40,FALSE,FALSE)
	var/list/w_left = list("",FALSE,FALSE,0,40,FALSE,FALSE)
	var/list/w_right = list("",FALSE,FALSE,0,40,FALSE,FALSE)

	var/image/roof
	not_movable = TRUE
	not_disassemblable = TRUE
	var/total_weight = 10

	New()
		..()
		roof = image(icon=icon, loc=src, icon_state="roof_steel[rand(1,4)]", layer=8)
		roof.override = TRUE
		spawn(1)
			update_icon()
	relaymove(var/mob/mob, direction)
		..()
		update_icon()
	Move(newloc, direct)
		..()
		update_icon()

/obj/structure/vehicleparts/frame/MouseDrop(var/obj/structure/vehicleparts/frame/VP)
	if (istype(VP, /obj/structure/vehicleparts/frame) && VP.axis && !axis)
		for(var/obj/structure/vehicleparts/frame/FR in range(1,src))
			if (VP.axis.components.len > 25)
				usr << "<span class='notice'>The vehicle is too big already!</span>"
				return
			if (FR != src && FR.axis == VP.axis)
				playsound(loc, 'sound/effects/lever.ogg',100, TRUE)
				usr << "You connect \the [src] to \the [VP.axis]."
				axis = VP.axis
				var/found = FALSE
				for (var/obj/structure/vehicleparts/frame/F in axis.components)
					if (F == src)
						found = TRUE
				if (!found)
					axis.components += src
				anchored = TRUE
				VP.dir = dir
				return
/obj/structure/vehicleparts/frame/MouseDrop_T(var/obj/structure/VP, var/mob/living/user)
	if (istype(VP, /obj/structure/engine/internal) && axis && !axis.engine && !VP.anchored)
		playsound(loc, 'sound/effects/lever.ogg',100, TRUE)
		usr << "You connect \the [VP] to \the [axis]."
		axis.engine = VP
		VP.forceMove(loc)
		VP.anchored = TRUE
		return
	else if (istype(VP, /obj/structure/bed/chair/drivers) && axis && !VP.anchored && !axis.wheel)
		playsound(loc, 'sound/effects/lever.ogg',100, TRUE)
		usr << "You place \the [VP] in \the [axis]."
		VP.forceMove(loc)
		VP.anchored = TRUE
		VP.dir = dir
		var/obj/structure/bed/chair/drivers/VPP = VP
		axis.wheel = VPP.wheel
		axis.wheel.control = src
		return

/obj/structure/vehicleparts/frame/wood
	name = "wood frame"
	desc = "a wood vehicle frame."
	icon_state = "frame_wood"
	flammable = TRUE
	resistance = 90

/obj/structure/vehicleparts/frame/update_icon()
	..()
	overlays.Cut()
	roof = image(icon=icon, loc=src, icon_state="roof_steel[rand(1,4)]", layer=11)
	roof.overlays.Cut()
	var/turf/T = get_turf(src)
	for(var/obj/structure/cannon/C in T)
		var/image/roof_turret = image(icon='icons/obj/vehicles96x96.dmi',loc=src, icon_state="tank_turret_g", layer=11.1, dir=C.dir)
		if (dir == NORTH || dir == SOUTH)
			roof_turret.pixel_y = -48
			roof_turret.pixel_x = -32
		else if (dir == WEST || dir == EAST)
			roof_turret.pixel_x = -48
			roof_turret.pixel_y = -32
		roof.overlays += roof_turret
	for (var/obj/CC in T)
		if (istype(CC, /obj/structure/bed/chair/drivers))
			roof.icon_state = "roof_steel_hatch_driver"
		else if (istype(CC, /obj/structure/bed/chair))
			roof.icon_state = "roof_steel_hatch"
		else if (istype(CC, /obj/structure/engine))
			roof.icon_state = "roof_steel_exhaust"
		else if (istype(CC, /obj/item/weapon/reagent_containers/glass/barrel/fueltank))
			roof.icon_state = "roof_steel_closedhatch"

	switch (dir)
		if (NORTH)
			if (w_left[1] != "")
				var/image/tmpimg3 = image(icon=icon, icon_state="[w_left[1]]_g", layer=10, dir=WEST)
				overlays += tmpimg3
				var/image/doub = tmpimg3
				doub.layer = 11.01
				roof.overlays += doub
			if (w_right[1] != "")
				var/image/tmpimg4 = image(icon=icon, icon_state="[w_right[1]]_g", layer=10, dir=EAST)
				overlays += tmpimg4
				var/image/doub = tmpimg4
				doub.layer = 11.01
				roof.overlays += doub
			if (w_front[1] != "")
				var/image/tmpimg1 = image(icon=icon, icon_state="[w_front[1]]_g", layer=10, dir=NORTH)
				overlays += tmpimg1
				var/image/doub = image(icon=icon, icon_state="c_lim_g", layer=11.01, dir=SOUTH)
				roof.overlays += doub
			if (w_back[1] != "")
				var/image/tmpimg2 = image(icon=icon, icon_state="[w_back[1]]_g", layer=10, dir=SOUTH)
				overlays += tmpimg2
				var/image/doub = tmpimg2
				doub.layer = 11.01
				roof.overlays += doub

		//Front-Right, Front-Left, Back-Right,Back-Left; FR, FL, BR, BL
			if (axis && axis.corners.len >= 4)
				if (axis.corners[1] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=NORTH)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[2] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=WEST)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[3] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=SOUTH)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[4] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=EAST)
					overlays += corn
					roof.overlays += corn

		if (SOUTH)
			if (w_left[1] != "")
				var/image/tmpimg3 = image(icon=icon, icon_state="[w_left[1]]_g", layer=10, dir=EAST)
				overlays += tmpimg3
				var/image/doub = tmpimg3
				doub.layer = 11.01
				roof.overlays += doub
			if (w_right[1] != "")
				var/image/tmpimg4 = image(icon=icon, icon_state="[w_right[1]]_g", layer=10, dir=WEST)
				overlays += tmpimg4
				var/image/doub = tmpimg4
				doub.layer = 11.01
				roof.overlays += doub
			if (w_front[1] != "")
				var/image/tmpimg1 = image(icon=icon, icon_state="[w_front[1]]_g", layer=10, dir=SOUTH)
				overlays += tmpimg1
				var/image/doub = tmpimg1
				doub.layer = 11.01
				roof.overlays += doub
			if (w_back[1] != "")
				var/image/tmpimg2 = image(icon=icon, icon_state="[w_back[1]]_g", layer=10, dir=NORTH)
				overlays += tmpimg2
				var/image/doub = image(icon=icon, icon_state="c_lim_g", layer=11.01, dir=NORTH)
				roof.overlays += doub

		//Front-Right, Front-Left, Back-Right,Back-Left; FR, FL, BR, BL
			if (axis && axis.corners.len >= 4)
				if (axis.corners[1] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=EAST)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[2] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=SOUTH)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[3] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=WEST)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[4] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=NORTH)
					overlays += corn
					roof.overlays += corn
		if (EAST)
			if (w_left[1] != "")
				var/image/tmpimg3 = image(icon=icon, icon_state="[w_left[1]]_g", layer=10, dir=NORTH)
				overlays += tmpimg3
				var/image/doub = tmpimg3
				doub.layer = 11.01
				roof.overlays += doub
			if (w_right[1] != "")
				var/image/tmpimg4 = image(icon=icon, icon_state="[w_right[1]]_g", layer=10, dir=SOUTH)
				overlays += tmpimg4
				var/image/doub = image(icon=icon, icon_state="c_lim_g", layer=11.01, dir=SOUTH)
				roof.overlays += doub
			if (w_front[1] != "")
				var/image/tmpimg1 = image(icon=icon, icon_state="[w_front[1]]_g", layer=10, dir=EAST)
				overlays += tmpimg1
				var/image/doub = tmpimg1
				doub.layer = 11.01
				roof.overlays += doub
			if (w_back[1] != "")
				var/image/tmpimg2 = image(icon=icon, icon_state="[w_back[1]]_g", layer=10, dir=WEST)
				overlays += tmpimg2
				var/image/doub = tmpimg2
				doub.layer = 11.01
				roof.overlays += doub

		//Front-Right, Front-Left, Back-Right,Back-Left; FR, FL, BR, BL
			if (axis && axis.corners.len >= 4)
				if (axis.corners[1] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=SOUTH)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[2] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=NORTH)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[3] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=WEST)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[4] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=EAST)
					overlays += corn
					roof.overlays += corn
		if (WEST)
			if (w_left[1] != "")
				var/image/tmpimg3 = image(icon=icon, icon_state="[w_left[1]]_g", layer=10, dir=SOUTH)
				overlays += tmpimg3
				var/image/doub = image(icon=icon, icon_state="c_lim_g", layer=11.01, dir=SOUTH)
				roof.overlays += doub
			if (w_right[1] != "")
				var/image/tmpimg4 = image(icon=icon, icon_state="[w_right[1]]_g", layer=10, dir=NORTH)
				overlays += tmpimg4
				var/image/doub = tmpimg4
				doub.layer = 11.01
				roof.overlays += doub
			if (w_front[1] != "")
				var/image/tmpimg1 = image(icon=icon, icon_state="[w_front[1]]_g", layer=10, dir=WEST)
				overlays += tmpimg1
				var/image/doub = tmpimg1
				doub.layer = 11.01
				roof.overlays += doub
			if (w_back[1] != "")
				var/image/tmpimg2 = image(icon=icon, icon_state="[w_back[1]]_g", layer=10, dir=EAST)
				overlays += tmpimg2
				var/image/doub = tmpimg2
				doub.layer = 11.01
				roof.overlays += doub

		//Front-Right, Front-Left, Back-Right,Back-Left; FR, FL, BR, BL
			if (axis && axis.corners.len >= 4)
				if (axis.corners[1] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=WEST)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[2] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=EAST)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[3] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=NORTH)
					overlays += corn
					roof.overlays += corn
				else if (axis.corners[4] == src)
					var/image/corn = image(icon=icon, icon_state="corner_g", layer=11.02, dir=SOUTH)
					overlays += corn
					roof.overlays += corn

/obj/structure/vehicleparts/frame/lwall
	w_left = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/rwall
	w_right = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/fwall
	w_front = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/bwall
	w_back = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/ldoor
	w_left = list("c_door",TRUE,TRUE,20,45,TRUE,TRUE)
/obj/structure/vehicleparts/frame/rdoor
	w_right = list("c_door",TRUE,TRUE,20,45,TRUE,TRUE)
/obj/structure/vehicleparts/frame/fdoor
	w_front = list("c_door",TRUE,TRUE,20,45,TRUE,TRUE)
/obj/structure/vehicleparts/frame/bdoor
	w_back = list("c_door",TRUE,TRUE,20,45,TRUE,TRUE)
/obj/structure/vehicleparts/frame/lwall/armored
	w_left = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
/obj/structure/vehicleparts/frame/rwall/armored
	w_right = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
/obj/structure/vehicleparts/frame/fwall/armored
	w_front = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
/obj/structure/vehicleparts/frame/bwall/armored
	w_back = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
/obj/structure/vehicleparts/frame/rb
	w_right = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
	w_back = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/lb
	w_left = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
	w_back = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/rf
	w_right = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
	w_front = list("c_wall",FALSE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/lf
	w_left = list("c_wall",TRUE,TRUE,20,50,FALSE,FALSE)
	w_front = list("c_wall",FALSE,TRUE,20,50,FALSE,FALSE)
/obj/structure/vehicleparts/frame/rb/armored
	w_right = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
	w_back = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
/obj/structure/vehicleparts/frame/lb/armored
	w_left = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
	w_back = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
/obj/structure/vehicleparts/frame/rf/armored
	w_right = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
	w_front = list("c_armoredfront",TRUE,TRUE,55,90,FALSE,FALSE)
/obj/structure/vehicleparts/frame/lf/armored
	w_left = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE)
	w_front = list("c_armoredfront",TRUE,TRUE,55,90,FALSE,FALSE)

/obj/structure/vehicleparts/frame/verb/add_walls()
	set category = null
	set name = "Add walls"
	set src in range(1, usr)

	var/ndir = WWinput(usr, "Which dir to set first?", "Wall Placer", "Cancel", list("North","South","East","West", "Cancel"))
	if (ndir == "Cancel")
		return
	else
		dir = text2dir(ndir)
		var/position = WWinput(usr, "Which position?", "Wall Placer", "Cancel", list("left","right","front","back", "Cancel"))
		if (position == "Cancel")
			return
		else
			position = "w_[position]"
			var/ntype = WWinput(usr, "Which type?", "Wall Placer", "Cancel", list("wall","windshield","window", "armored front", "armoredwall", "door", "windowed door", "Cancel"))
			if (ntype == "Cancel")
				return
			else
				ntype = "c_[type]"
				ntype = replacetext(ntype, " ", "")
				switch(position)
					if ("w_left")
						w_left = vehicle_walls[ntype]
					if ("w_right")
						w_right = vehicle_walls[ntype]
					if ("w_front")
						w_front = vehicle_walls[ntype]
					if ("w_back")
						w_back = vehicle_walls[ntype]
	update_icon()


/obj/structure/vehicleparts/frame/CheckExit(atom/movable/O as mob|obj, target as turf)
	var/chdir = get_dir(O.loc, target)
	switch(chdir)
		if (NORTH,NORTHEAST,NORTHWEST)
			switch(dir)
				if (NORTH)
					if (w_front[1] == "" || w_front[7] == TRUE)
						return TRUE
				if (SOUTH)
					if (w_back[1] == "" || w_back[7] == TRUE)
						return TRUE
				if (WEST)
					if (w_right[1] == "" || w_right[7] == TRUE)
						return TRUE
				if (EAST)
					if (w_left[1] == "" || w_left[7] == TRUE)
						return TRUE
		if (SOUTH,SOUTHEAST,SOUTHWEST)
			switch(dir)
				if (NORTH)
					if (w_back[1] == "" || w_back[7] == TRUE)
						return TRUE
				if (SOUTH)
					if (w_front[1] == "" || w_front[7] == TRUE)
						return TRUE
				if (WEST)
					if (w_left[1] == "" || w_left[7] == TRUE)
						return TRUE
				if (EAST)
					if (w_right[1] == "" || w_right[7] == TRUE)
						return TRUE
		if (WEST,NORTHWEST,SOUTHWEST)
			switch(dir)
				if (NORTH)
					if (w_left[1] == "" || w_left[7] == TRUE)
						return TRUE
				if (SOUTH)
					if (w_right[1] == "" || w_right[7] == TRUE)
						return TRUE
				if (WEST)
					if (w_front[1] == "" || w_front[7] == TRUE)
						return TRUE
				if (EAST)
					if (w_back[1] == "" || w_back[7] == TRUE)
						return TRUE
		if (EAST,NORTHEAST,SOUTHEAST)
			switch(dir)
				if (NORTH)
					if (w_right[1] == "" || w_right[7] == TRUE)
						return TRUE
				if (SOUTH)
					if (w_left[1] == "" || w_left[7] == TRUE)
						return TRUE
				if (WEST)
					if (w_back[1] == "" || w_back[7] == TRUE)
						return TRUE
				if (EAST)
					if (w_front[1] == "" || w_front[7] == TRUE)
						return TRUE
	return FALSE

/obj/structure/vehicleparts/frame/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover, /obj/effect/effect/smoke))
		return FALSE
	else
		switch(mover.dir)
			if (NORTH)
				switch(dir)
					if (NORTH)
						if (w_back[1] == "" || w_back[7] == TRUE)
							return TRUE
					if (SOUTH)
						if (w_front[1] == "" || w_front[7] == TRUE)
							return TRUE
					if (WEST)
						if (w_left[1] == "" || w_left[7] == TRUE)
							return TRUE
					if (EAST)
						if (w_right[1] == "" || w_right[7] == TRUE)
							return TRUE
			if (SOUTH)
				switch(dir)
					if (NORTH)
						if (w_front[1] == "" || w_front[7] == TRUE)
							return TRUE
					if (SOUTH)
						if (w_back[1] == "" || w_back[7] == TRUE)
							return TRUE
					if (WEST)
						if (w_right[1] == "" || w_right[7] == TRUE)
							return TRUE
					if (EAST)
						if (w_left[1] == "" || w_left[7] == TRUE)
							return TRUE
			if (WEST)
				switch(dir)
					if (NORTH)
						if (w_right[1] == "" || w_right[7] == TRUE)
							return TRUE
					if (SOUTH)
						if (w_left[1] == "" || w_left[7] == TRUE)
							return TRUE
					if (WEST)
						if (w_back[1] == "" || w_back[7] == TRUE)
							return TRUE
					if (EAST)
						if (w_front[1] == "" || w_front[7] == TRUE)
							return TRUE
			if (EAST)
				switch(dir)
					if (NORTH)
						if (w_left[1] == "" || w_left[7] == TRUE)
							return TRUE
					if (SOUTH)
						if (w_right[1] == "" || w_right[7] == TRUE)
							return TRUE
					if (WEST)
						if (w_front[1] == "" || w_front[7] == TRUE)
							return TRUE
					if (EAST)
						if (w_back[1] == "" || w_back[7] == TRUE)
							return TRUE
	return FALSE
/obj/structure/vehicleparts/frame/bullet_act(var/obj/item/projectile/mover)
	CanPass(mover)
/obj/structure/vehicleparts/frame/attackby(var/obj/item/I, var/mob/living/carbon/human/H)
	if (istype(I,/obj/item/weapon/key))
		if (w_front[6])
			if (w_front[7])
				visible_message("[H] locks the door.")
				w_front[7] = FALSE
			else
				visible_message("[H] unlocks the door.")
				w_front[7] = TRUE
			H.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if (w_back[6])
			if (w_back[7])
				visible_message("[H] locks the door.")
				w_back[7] = FALSE
			else
				visible_message("[H] unlocks the door.")
				w_back[7] = TRUE
			H.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if (w_left[6])
			if (w_left[7])
				visible_message("[H] locks the door.")
				w_left[7] = FALSE
			else
				visible_message("[H] unlocks the door.")
				w_left[7] = TRUE
			H.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if (w_right[6])
			if (w_right[7])
				visible_message("[H] locks the door.")
				w_right[7] = FALSE
			else
				visible_message("[H] unlocks the door.")
				w_right[7] = TRUE
			H.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	else
		..()
/obj/structure/vehicleparts/frame/proc/CheckPenLoc(var/obj/item/projectile/proj)
	proj.throw_source = proj.starting
	switch(get_dir(proj.throw_source, get_turf(src)))
		if (NORTH)
			switch(dir)
				if (NORTH)
					return w_back
				if (SOUTH)
					return w_front
				if (WEST)
					return w_left
				if (EAST)
					return w_right
		if (SOUTH)
			switch(dir)
				if (NORTH)
					return w_front
				if (SOUTH)
					return w_back
				if (WEST)
					return w_right
				if (EAST)
					return w_left
		if (WEST)
			switch(dir)
				if (NORTH)
					return w_right
				if (SOUTH)
					return w_left
				if (WEST)
					return w_back
				if (EAST)
					return w_front
		if (EAST)
			switch(dir)
				if (NORTH)
					return w_left
				if (SOUTH)
					return w_right
				if (WEST)
					return w_front
				if (EAST)
					return w_back
	return list()

/obj/structure/vehicleparts/frame/proc/CheckPen(var/obj/item/projectile/proj, var/list/penloc = list())
	if (!penloc || !islist(penloc) || penloc.len < 7)
		return FALSE
	proj.throw_source = proj.starting
	if (proj.heavy_armor_penetration > penloc[4])
		return TRUE
	else
		return FALSE
	return FALSE

/obj/structure/vehicleparts/frame/bullet_act(var/obj/item/projectile/proj, var/list/penloc = list())
	if (penloc && islist(penloc) && penloc.len >= 5)
		penloc[5] -= proj.damage * 0.01
		visible_message("<span class = 'warning'>\The [src] hits \the [src]!</span>")
		try_destroy()
		return
	else
		..()

/obj/structure/vehicleparts/frame/proc/try_destroy()
	if (w_left[5] <= 0)
		w_left = list("",FALSE,FALSE,0,40,FALSE,FALSE)
		visible_message("<span class='danger'>The wall gets wrecked!</span>")
	if (w_right[5] <= 0)
		w_right = list("",FALSE,FALSE,0,40,FALSE,FALSE)
		visible_message("<span class='danger'>The wall gets wrecked!</span>")
	if (w_front[5] <= 0)
		w_front = list("",FALSE,FALSE,0,40,FALSE,FALSE)
		visible_message("<span class='danger'>The wall gets wrecked!</span>")
	if (w_back[5] <= 0)
		w_back = list("",FALSE,FALSE,0,40,FALSE,FALSE)
		visible_message("<span class='danger'>The wall gets wrecked!</span>")

/obj/structure/vehicleparts/frame/ex_act(severity)
	switch(severity)
		if (1.0)
			w_left[5]-=rand(17,22)
			w_right[5]-=rand(17,22)
			w_front[5]-=rand(17,22)
			w_back[5]-=rand(17,22)
			try_destroy()
			return
		if (2.0)
			w_left[5]-=rand(7,12)
			w_right[5]-=rand(7,12)
			w_front[5]-=rand(7,12)
			w_back[5]-=rand(7,12)
			try_destroy()
			return
		if (3.0)
			return
//types of walls/borders
//format: type of wall, opacity, density, armor, current health, can open/close, is open?
var/global/list/vehicle_walls = list( \
	"" = list("",FALSE,FALSE,0,40,FALSE,FALSE), \
	"c_wall" = list("c_window",FALSE,TRUE,20,50,FALSE,FALSE), \
	"c_window" = list("c_wall",TRUE,TRUE,10,40,FALSE,FALSE), \
	"c_windshield" = list("c_windshield",FALSE,TRUE,6,35,FALSE,FALSE), \
	"c_armoredfront" = list("c_armoredfront",FALSE,TRUE,45,80,FALSE,FALSE), \
	"c_armoredwall" = list("c_armoredwall",TRUE,TRUE,55,90,FALSE,FALSE), \
	"c_door" = list("c_door",TRUE,TRUE,20,45,TRUE,TRUE), \
	"c_windowdoor" = list("c_windowdoor",FALSE,TRUE,28,60,TRUE,TRUE), \
	 \
)