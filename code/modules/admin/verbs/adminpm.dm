//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in mob_list)
	set category = null
	set name = "Admin PM Mob"
	if (!holder)
		src << "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>"
		return
	if ( !ismob(M) || !M.client )	return
	cmd_admin_pm(M.client,null)


//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Админ"
	set name = "Admin PM"
	if (!holder)
		src << "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>"
		return
	var/list/client/targets[0]
	for (var/client/T)
		if (T.mob)
			if (isnewplayer(T.mob))
				targets["(New Player) - [T]"] = T
			else if (isghost(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)



//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client

/client/proc/cmd_admin_pm(var/client/C, var/msg = null)
	if (prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>"
		return

	if (!istype(C,/client))
		if (holder)	src << "<font color='red'>Error: Private-Message: Client not found.</font>"
		else		src << "<font color='red'>Error: Private-Message: Client not found. They may have lost connection, so try using an adminhelp!</font>"
		return

	//get message text, limit it's length.and clean/escape html
	if (!msg)
		msg = input(src,"Message:", "Private message to [key_name(C, FALSE, holder ? TRUE : FALSE)]") as text|null

		if (!msg)	return
		if (!C)
			if (holder)	src << "<font color='red'>Error: Admin-PM: Client not found.</font>"
			else		src << "<font color='red'>Error: Private-Message: Client not found. They may have lost connection, so try using an adminhelp!</font>"
			return

	if (handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	msg = sanitize(msg)
	if (!msg)	return

	var/recieve_pm_type = "Player"
	if (holder)
		//mod PMs are maroon
		//PMs sent from admins and mods display their rank
		if (holder)
			if (!C.holder && holder && holder.fakekey)
				recieve_pm_type = "Admin"
			else
				recieve_pm_type = holder.rank

	else if (!C.holder)
		src << "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>"
		return

	var/recieve_message

	if (holder && !C.holder)
		recieve_message = "<span class='pm'><span class='howto'><b>-- Click the [recieve_pm_type]'s name to reply --</b></span></span>\n"
		if (C.adminhelped)
			C << recieve_message
			C.adminhelped = FALSE

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if (config.popup_admin_pm)
			spawn(0)	//so we don't hold the caller proc up
				var/sender = src
				var/sendername = key
				var/reply = sanitize(input(C, msg,"[recieve_pm_type] PM from [sendername]", "") as text|null)		//show message and await a reply
				if (C && reply)
					if (sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return
	src << "<span class='pm'><span class='out'>" + create_text_tag("pm_out_alt", "PM", src) + " to <span class='name'>[get_options_bar(C, holder ? TRUE : FALSE, holder ? TRUE : FALSE, TRUE)]</span>: <span class='message'>[msg]</span></span></span>"
	C << "<span class='pm'><span class='in'>" + create_text_tag("pm_in", "", C) + " <b>\[[recieve_pm_type] PM\]</b> <span class='name'>[get_options_bar(src, C.holder ? TRUE : FALSE, C.holder ? TRUE : FALSE, TRUE)]</span>: <span class='message'>[msg]</span></span></span>"

	discord_adminpm_log(key_name(src),msg,key_name(C))

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	if (C.is_preference_enabled(/datum/client_preference/holder/play_adminhelp_ping))
		C << 'sound/effects/adminhelp.ogg'

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")


	//we don't use message_admins here because the sender/receiver might get it too
	for (var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if (X == C || X == src)
			continue
		if (X.key != key && X.key != C.key && (X.holder.rights & R_ADMIN|R_MOD|R_MENTOR))
			X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[key_name(src, X, FALSE)]</span> to <span class='name'>[key_name(C, X, FALSE)]</span>: <span class='message'>[msg]</span></span></span>"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///when the sender is at the discord (and thus not a client):
/client
	var/pm_sender = "admins" //this is a fucking horrible hack but fuck this

/proc/cmd_admin_pm_fromdiscord(var/client/C, var/msg = null, var/sender_name = "admins")
	//get message text, limit it's length.and clean/escape html
	if (!msg)
		msg = input(src,"Message:", "Private message to [C.ckey]") as text|null

		if (!msg)	return
		if (!C)	return

	C.pm_sender = sender_name

	msg = sanitize(msg)
	if (!msg)	return

	if (C.adminhelped)
		C << "<span class='pm'><span class='howto'><b>-- Click the Admins's name to reply --</b></span></span>\n"
		C.adminhelped = FALSE
	C << "<span class='pm'><span class='in'>" + create_text_tag("pm_in", "", C) + " <b>\[Admin PM\]</b> <a href='?priv_msg_discord=\ref[sender_name]'>[sender_name] (discord)</span></a>: <span class='message'>[msg]</span></span></span>"

	discord_adminpm_log(sender_name,msg,key_name(C))

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	if (C.is_preference_enabled(/datum/client_preference/holder/play_adminhelp_ping))
		C << 'sound/effects/adminhelp.ogg'

	log_admin("FROM-DISCORD-PM: [sender_name]->[key_name(C)]: [msg]")


	//we don't use message_admins here because the sender/receiver might get it too
	for (var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient

		if ((X.holder.rights & R_ADMIN|R_MOD|R_MENTOR))
			X.pm_sender = sender_name
			X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'><a href='?priv_msg_discord=\ref[sender_name]'>[sender_name] (discord)</span></a> to <span class='name'>[key_name(C, X, FALSE)]</span>: <span class='message'>[msg]</span></span></span>"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///when the receiver is an admin in the discord:
/client/proc/cmd_admin_pm_todiscord(var/target = "admins",var/msg = null)
	if (prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>"
		return


	//get message text, limit it's length.and clean/escape html
	if (!msg)
		msg = input(src,"Message:", "Private message to [target]") as text|null

		if (!msg)	return

	if (handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	msg = sanitize(msg)
	if (!msg)	return

	src << "<span class='pm'><span class='out'>" + create_text_tag("pm_out_alt", "PM", src) + " to <span class='name'>[target]</span>: <span class='message'>[msg]</span></span></span>"

	discord_adminpm_log(key_name(src),msg,target)

	log_admin("TO-DISCORD-PM: [key_name(src)]->[target]: [msg]")


	//we don't use message_admins here because the sender/receiver might get it too
	for (var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if ( X == src)
			continue
		if (X.key != key && (X.holder.rights & R_ADMIN|R_MOD|R_MENTOR))
			X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[key_name(src, X, FALSE)]</span> to <span class='name'>[target] (discord)</span>: <span class='message'>[msg]</span></span></span>"
