//mostly ported from BurgerStation, 17/05/2020

#define TILE_SIZE 32

/client
	var/obj/chat_text/chat_text
	var/list/stored_chat_text = list()

/obj/chat_text
	name = "overlay"
	desc = "overlay object"
	plane = CHAT_PLANE

	icon = null

	var/mob/living/owner

/obj/chat_text/Destroy()
	if (owner && owner.client)
		owner.client.stored_chat_text -= src
		owner = null
	return ..()

/obj/chat_text/New(var/atom/desired_loc,var/desired_text)

	if(isliving(desired_loc))
		owner = desired_loc
		if (!owner.client)
			return
		for(var/obj/chat_text/CT in owner.client.stored_chat_text)
			qdel(CT)

		owner.client.stored_chat_text += src

		forceMove(get_turf(desired_loc))

		maptext_width = TILE_SIZE*ceil(11*0.5)
		maptext_x = -(maptext_width-TILE_SIZE)*0.5
		maptext_y = TILE_SIZE*0.75
		maptext = "<center>[desired_text]</center>"

		spawn(100)
			animate(src,alpha=0,time=10)
			sleep(10)
			if(src)
				qdel(src)

		return ..()
	else
		qdel(src)

	return FALSE
var/global/sound_tts_num = 0

/mob/proc/play_tts(message)
	if (!message || message == "" || !client)
		return
	var/gnd = 1
	if (gender == FEMALE)
		gnd = 0
	sound_tts_num+=1
	var/genUID = sound_tts_num
	shell("sudo python3 tts/amazontts.py \"[message]\" [gnd] [genUID]")
	spawn(1)
		var/fpath = "[genUID].ogg"
		if (fexists(fpath))
			if (client)
				src.playsound_local(loc,fpath,100)
			spawn(50)
				fdel(fpath)
		return
