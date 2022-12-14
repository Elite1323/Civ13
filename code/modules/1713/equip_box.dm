/obj/item/gunbox
	name = "оружейный ящик"
	desc = "Тут лежит оружие."
	icon = 'icons/obj/storage.dmi'
	icon_state = "ammo_can" //temp
	flags = CONDUCT

/obj/item/gunbox/attack_self(mob/living/user)
	var/list/options = list()
	options["Colt Police - revolver"] = list(/obj/item/weapon/gun/projectile/revolver/coltpolicepositive,/obj/item/ammo_magazine/c32,/obj/item/ammo_magazine/c32,/obj/item/ammo_magazine/c32)
	options["Glock 17 - pistol"] = list(/obj/item/weapon/gun/projectile/pistol/glock17,/obj/item/ammo_magazine/glock17,/obj/item/ammo_magazine/glock17,/obj/item/ammo_magazine/glock17)
	options["Peace maker - revolver"] = list(/obj/item/weapon/gun/projectile/revolver/frontier,/obj/item/ammo_magazine/c44,/obj/item/ammo_magazine/c44,/obj/item/ammo_magazine/c44)
	options["Beretta m9 - pistol"] = list(/obj/item/weapon/gun/projectile/pistol/m9beretta,/obj/item/ammo_magazine/m9beretta,/obj/item/ammo_magazine/m9beretta,/obj/item/ammo_magazine/m9beretta)
	options["TT-30 - less than lethal pistol"] = list(/obj/item/weapon/gun/projectile/pistol/tt30,/obj/item/ammo_magazine/tt30ll/rubber,/obj/item/ammo_magazine/tt30ll/rubber,/obj/item/ammo_magazine/tt30ll/rubber)
	var/choice = input(user,"Что берём?") as null|anything in options
	if(src && choice)
		var/list/things_to_spawn = options[choice]
		for(var/new_type in things_to_spawn)
			var/atom/movable/AM = new new_type(get_turf(src))
			if(istype(AM, /obj/item/weapon/gun/))
				to_chat(user, "Достаю [AM] из ящика. [pick("Выглядит солидно.", "Неплохо.", "Надеюсь это стоит больше чем моя зарплата.", "Вот бы второй ящик открыть...", "О да я крут!")]")
		qdel(src)
