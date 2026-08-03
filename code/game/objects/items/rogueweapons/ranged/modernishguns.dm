// 'modern' firearms of WARMONGERS, includes a repeater aswell as a revolver
// DONUT STEAL!!1!

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater
	name = "repeatershotte"
	desc = "A gun designed to be fired rapidly in quick succession using a clicker design to spin a cylinder, automatically cycling a new bullet into the barrel."
	icon = 'icons/roguetown/weapons/64.dmi'
	icon_state = "repeatergun"
	possible_item_intents = list(INTENT_GENERIC)
	gripped_intents = list(/datum/intent/shoot/musket/peter, /datum/intent/shoot/musket/arc)
	wieldsound = 'sound/combat/musket_wield.ogg'
	dry_fire_sound = 'sound/foley/muskclick.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	bolt_type = BOLT_TYPE_STANDARD
	semi_auto = FALSE
	casing_ejector = FALSE
	internal_magazine = TRUE
	tac_reloads = FALSE
	experimental_onback = TRUE
	max_integrity = 600
	randomspread = 1
	spread = 0
	bigboy = TRUE
	can_parry = TRUE
	pin = /obj/item/firing_pin
	force = 10
	cartridge_wording = "ball"
	droprot = TRUE
	recoil = 4
	load_sound = 'sound/foley/revolvaload.ogg'
	fire_sound = list('sound/combat/Ranged/muskshot1.ogg','sound/combat/Ranged/muskshot2.ogg','sound/combat/Ranged/muskshot3.ogg')
	fire_sound_volume = 500
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	dropshrink = 0.7
	associated_skill = /datum/skill/combat/flintlocks
	var/flunked = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.5,"sx" = -7,"sy" = 0,"nx" = 8,"ny" = 0,"wx" = -5,"wy" = 1,"ex" = 0,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -90,"sturn" = 90,"wturn" = 90,"eturn" = -90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.5,"sx" = 5,"sy" = -3,"nx" = -5,"ny" = 0,"wx" = -7,"wy" = -3,"ex" = 7,"ey" = -3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 3,"sturn" = -3,"wturn" = 3,"eturn" = -3,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -5,"sy" = 2,"nx" = 5,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = -3,"ey" = 3,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 90,"eturn" = -90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/empty
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter/startempty

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/examine(mob/user)
	. = ..()
	if(chambered)
		. += "<span class='info'>It is loaded.</span>"
	. += "<span class='tutorial'>Use rightclick to cycle the chamber.</span>"
	. += "<span class='tutorial'>It doesn't need barkenpowder.</span>"

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/chamber_round(spin_cylinder)
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/proc/reloadact(mob/user)
	if(chambered)
		return
	if(!move_after(user, 0.5 SECONDS, TRUE, src))
		return
	var/obj/item/ammo_casing/caseless/rogue/bullet/B = magazine.get_round(TRUE)
	if(B)
		chambered = B
		flunked = TRUE
		to_chat(user, "<span class='info'>I chamber \the [src].</span>")
		playsound(user, 'sound/foley/piscock.ogg', 100)
		flick("[initial(icon_state)]_cycle", src)
		update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/attack_right(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/rmb_self(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/dropped(mob/user)
	. = ..()
	if(wielded)
		ungrip(user)
	update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/update_icon()
	if(chambered)
		icon_state = "[initial(icon_state)]_lever"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/attack_self(mob/living/user)
	if(!wielded)
		wield(user)
		update_icon()
	else
		ungrip(user)
		update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	QDEL_NULL(chambered)
	var/angle = dir2angle(user.dir)
	angle += rand(-25, 25)

	var/px = round(128 * sin(angle))
	var/py = round(128 * cos(angle))

	var/obj/effect/temp_visual/small_smoke/gunsmoke/S = new(get_turf(user))
	var/matrix/ARE = matrix()
	ARE.Scale(2, 2)
	ARE.Turn(rand(-350,350))
	animate(S, time = 20, alpha = 0, pixel_x = px, pixel_y = py, transform = ARE, easing = SINE_EASING)
	QDEL_IN(S, 20)

	firearm_recoil_mob(user)

	SSticker.muskshots++

	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z,user.z))
			continue
		var/turf/M_turf = get_turf(M)
		var/far_smith_sound = sound(pick('sound/ambience/distantshot1.ogg','sound/ambience/distantshot2.ogg','sound/ambience/distantshot3.ogg'))
		if(M_turf)
			var/dist = get_dist(M_turf, loc)
			if(dist < 7)
				continue
			M.playsound_local(M_turf, null, 60, 1, get_rand_frequency(), falloff = 5, S = far_smith_sound)

/obj/item/gun/ballistic/revolver/grenadelauncher/repeater/sniper
	name = "longrepeater"
	desc = "A gun designed to be fired rapidly in quick succession using a clicker design to spin a cylinder, automatically cycling a new bullet into the barrel. This one has a longer barrel and a scope."
	icon = 'icons/roguetown/weapons/64.dmi'
	icon_state = "repeatersniper"

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction
	name = "boltenbark"
	desc = "A gun designed to be fired rapidly in quick succession using a bolt action design to cycle ammunition into the barrel."
	icon = 'icons/roguetown/weapons/64.dmi'
	icon_state = "leveraction"
	possible_item_intents = list(INTENT_GENERIC)
	gripped_intents = list(/datum/intent/shoot/musket/peter, /datum/intent/shoot/musket/arc)
	wieldsound = 'sound/combat/musket_wield.ogg'
	dry_fire_sound = 'sound/foley/muskclick.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	bolt_type = BOLT_TYPE_STANDARD
	semi_auto = FALSE
	casing_ejector = FALSE
	internal_magazine = TRUE
	tac_reloads = FALSE
	experimental_onback = TRUE
	max_integrity = 600
	randomspread = 1
	spread = 0
	bigboy = TRUE
	can_parry = TRUE
	pin = /obj/item/firing_pin
	force = 10
	cartridge_wording = "ball"
	droprot = TRUE
	recoil = 4
	load_sound = 'sound/foley/boltactionload.ogg'
	fire_sound = list('sound/combat/Ranged/muskshot1.ogg','sound/combat/Ranged/muskshot2.ogg','sound/combat/Ranged/muskshot3.ogg')
	fire_sound_volume = 500
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	dropshrink = 0.7
	associated_skill = /datum/skill/combat/flintlocks
	var/flunked = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.5,"sx" = -7,"sy" = 0,"nx" = 8,"ny" = 0,"wx" = -5,"wy" = 1,"ex" = 0,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -90,"sturn" = 90,"wturn" = 90,"eturn" = -90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.5,"sx" = 5,"sy" = -3,"nx" = -5,"ny" = 0,"wx" = -7,"wy" = -3,"ex" = 7,"ey" = -3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 3,"sturn" = -3,"wturn" = 3,"eturn" = -3,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -5,"sy" = 2,"nx" = 5,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = -3,"ey" = 3,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 90,"eturn" = -90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/empty
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter/startempty

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/examine(mob/user)
	. = ..()
	if(chambered)
		. += "<span class='info'>It is loaded.</span>"
	. += "<span class='tutorial'>Use rightclick rack the bolt.</span>"
	. += "<span class='tutorial'>It doesn't need barkenpowder.</span>"

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/chamber_round(spin_cylinder)
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/proc/reloadact(mob/user)
	if(chambered)
		return
	if(!move_after(user, 0.5 SECONDS, TRUE, src))
		return
	var/obj/item/ammo_casing/caseless/rogue/bullet/B = magazine.get_round(TRUE)
	if(B)
		chambered = B
		flunked = TRUE
		to_chat(user, "<span class='info'>I rack \the [src].</span>")
		playsound(user, 'sound/foley/boltaction.ogg', 100)
		flick("[initial(icon_state)]_cycle", src)
		update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/attack_right(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/rmb_self(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/dropped(mob/user)
	. = ..()
	if(wielded)
		ungrip(user)
	update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/update_icon()
	if(chambered)
		icon_state = "[initial(icon_state)]_lever"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/attack_self(mob/living/user)
	if(!wielded)
		wield(user)
		update_icon()
	else
		ungrip(user)
		update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	QDEL_NULL(chambered)
	var/angle = dir2angle(user.dir)
	angle += rand(-25, 25)

	var/px = round(128 * sin(angle))
	var/py = round(128 * cos(angle))

	var/obj/effect/temp_visual/small_smoke/gunsmoke/S = new(get_turf(user))
	var/matrix/ARE = matrix()
	ARE.Scale(2, 2)
	ARE.Turn(rand(-350,350))
	animate(S, time = 20, alpha = 0, pixel_x = px, pixel_y = py, transform = ARE, easing = SINE_EASING)
	QDEL_IN(S, 20)

	firearm_recoil_mob(user)

	SSticker.muskshots++

	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z,user.z))
			continue
		var/turf/M_turf = get_turf(M)
		var/far_smith_sound = sound(pick('sound/ambience/distantshot1.ogg','sound/ambience/distantshot2.ogg','sound/ambience/distantshot3.ogg'))
		if(M_turf)
			var/dist = get_dist(M_turf, loc)
			if(dist < 7)
				continue
			M.playsound_local(M_turf, null, 60, 1, get_rand_frequency(), falloff = 5, S = far_smith_sound)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/sniper
	name = "longboltenbarker"
	desc = "A gun designed to be fired rapidly in quick succession using a bolt action design to cycle ammunition into the barrel. This one has a longer barrel and a fork sight."
	icon = 'icons/roguetown/weapons/64.dmi'
	load_sound = 'sound/foley/boltactionload.ogg'
	icon_state = "leveractionsniper"

/obj/item/ammo_box/magazine/internal/shot/peter // petah.. the saiga is here.
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bullet
	caliber = "musketball"
	max_ammo = 6
	start_empty = FALSE

/obj/item/ammo_box/magazine/internal/shot/peter/startempty
	start_empty = TRUE

// revolver

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot
	name = "revolleyer"
	desc = "Similar to a barkpistol, in both size and overall design. This barker uses a revolving cylinder to ensure the rapid firing of shots one after the other."
	icon = 'icons/roguetown/weapons/32.dmi'
	icon_state = "shitvolver"
	possible_item_intents = list(/datum/intent/shoot/musket/peter, /datum/intent/shoot/musket/arc, INTENT_GENERIC)
	wieldsound = 'sound/combat/musket_wield.ogg'
	dry_fire_sound = 'sound/foley/drypis.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	bolt_type = BOLT_TYPE_STANDARD
	semi_auto = FALSE
	casing_ejector = FALSE
	internal_magazine = TRUE
	tac_reloads = FALSE
	experimental_onback = TRUE
	max_integrity = 600
	randomspread = 1
	spread = 0
	bigboy = FALSE
	can_parry = TRUE
	pin = /obj/item/firing_pin
	force = 10
	droprot = TRUE
	cartridge_wording = "ball"
	recoil = 4
	load_sound = 'sound/foley/revolvaload.ogg'
	fire_sound = list('sound/combat/Ranged/muskshot1.ogg','sound/combat/Ranged/muskshot2.ogg','sound/combat/Ranged/muskshot3.ogg')
	fire_sound_volume = 500
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	associated_skill = /datum/skill/combat/flintlocks

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/empty
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter/startempty

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/examine(mob/user)
	. = ..()
	if(chambered)
		. += "<span class='info'>It is loaded.</span>"
	. += "<span class='tutorial'>Use rightclick to pull the clicker down.</span>"
	. += "<span class='tutorial'>It doesn't need barkenpowder.</span>"

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/attack_self(mob/living/user)
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/chamber_round(spin_cylinder)
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/proc/reloadact(mob/user)
	if(chambered)
		return
	if(!move_after(user, 1.5 SECONDS, TRUE, src))
		return
	var/obj/item/ammo_casing/caseless/rogue/bullet/B = magazine.get_round(TRUE)
	if(B)
		chambered = B
		to_chat(user, "<span class='info'>I pull the clicker down, chambering \the [src].</span>")
		playsound(user, 'sound/foley/piscock.ogg', 100)
		flick("shitvolver_anim", src)
		update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/attack_right(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/rmb_self(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/update_icon()
	if(chambered)
		icon_state = "[initial(icon_state)]_cock"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	QDEL_NULL(chambered)
	var/angle = dir2angle(user.dir)
	angle += rand(-25, 25)

	var/px = round(64 * sin(angle))
	var/py = round(64 * cos(angle))

	var/obj/effect/temp_visual/small_smoke/gunsmoke/S = new(get_turf(user))
	var/matrix/ARE = matrix()
	ARE.Turn(rand(-350,350))
	animate(S, time = 10, alpha = 0, pixel_x = px, pixel_y = py, transform = ARE, easing = SINE_EASING)
	QDEL_IN(S, 10)

	//new /obj/effect/particle_effect/smoke(get_turf(user))
	SSticker.muskshots++
	update_icon()

	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z,user.z))
			continue
		var/turf/M_turf = get_turf(M)
		var/far_smith_sound = sound(pick('sound/ambience/distantshot1.ogg','sound/ambience/distantshot2.ogg','sound/ambience/distantshot3.ogg'))
		if(M_turf)
			var/dist = get_dist(M_turf, loc)
			if(dist < 7)
				continue
			M.playsound_local(M_turf, null, 60, 1, get_rand_frequency(), falloff = 5, S = far_smith_sound)

/obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.3,"sx" = -7,"sy" = -6,"nx" = 7,"ny" = -6,"wx" = -3,"wy" = -6,"ex" = 3,"ey" = -6,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 90,"sturn" = -90,"wturn" = -90,"eturn" = 90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot
	name = "boltenpistol"
	desc = "Similar to a barkpistol, in both size and overall design. This barker uses a bolt action design to cycle ammunition for rapid firing."
	icon = 'icons/roguetown/weapons/32.dmi'
	icon_state = "shitvolver1"
	possible_item_intents = list(/datum/intent/shoot/musket/peter, /datum/intent/shoot/musket/arc, INTENT_GENERIC)
	wieldsound = 'sound/combat/musket_wield.ogg'
	dry_fire_sound = 'sound/foley/drypis.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	bolt_type = BOLT_TYPE_STANDARD
	semi_auto = FALSE
	casing_ejector = FALSE
	internal_magazine = TRUE
	tac_reloads = FALSE
	experimental_onback = TRUE
	max_integrity = 600
	randomspread = 1
	spread = 0
	bigboy = FALSE
	can_parry = TRUE
	pin = /obj/item/firing_pin
	force = 10
	droprot = TRUE
	cartridge_wording = "ball"
	recoil = 4
	load_sound = 'sound/foley/boltactionload.ogg'
	fire_sound = list('sound/combat/Ranged/muskshot1.ogg','sound/combat/Ranged/muskshot2.ogg','sound/combat/Ranged/muskshot3.ogg')
	fire_sound_volume = 500
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	associated_skill = /datum/skill/combat/flintlocks

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/empty
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter/startempty

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/examine(mob/user)
	. = ..()
	if(chambered)
		. += "<span class='info'>It is loaded.</span>"
	. += "<span class='tutorial'>Use rightclick to rack the bolt.</span>"
	. += "<span class='tutorial'>It doesn't need barkenpowder.</span>"

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/attack_self(mob/living/user)
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/chamber_round(spin_cylinder)
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/proc/reloadact(mob/user)
	if(chambered)
		return
	if(!move_after(user, 1.5 SECONDS, TRUE, src))
		return
	var/obj/item/ammo_casing/caseless/rogue/bullet/B = magazine.get_round(TRUE)
	if(B)
		chambered = B
		to_chat(user, "<span class='info'>I pull the bolt back, chambering \the [src].</span>")
		playsound(user, 'sound/foley/cock.ogg', 100)
		flick("shitvolver1_anim", src)
		update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/attack_right(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/rmb_self(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/update_icon()
	if(chambered)
		icon_state = "[initial(icon_state)]_cock"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	QDEL_NULL(chambered)
	var/angle = dir2angle(user.dir)
	angle += rand(-25, 25)

	var/px = round(64 * sin(angle))
	var/py = round(64 * cos(angle))

	var/obj/effect/temp_visual/small_smoke/gunsmoke/S = new(get_turf(user))
	var/matrix/ARE = matrix()
	ARE.Turn(rand(-350,350))
	animate(S, time = 10, alpha = 0, pixel_x = px, pixel_y = py, transform = ARE, easing = SINE_EASING)
	QDEL_IN(S, 10)

	//new /obj/effect/particle_effect/smoke(get_turf(user))
	SSticker.muskshots++
	update_icon()

	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z,user.z))
			continue
		var/turf/M_turf = get_turf(M)
		var/far_smith_sound = sound(pick('sound/ambience/distantshot1.ogg','sound/ambience/distantshot2.ogg','sound/ambience/distantshot3.ogg'))
		if(M_turf)
			var/dist = get_dist(M_turf, loc)
			if(dist < 7)
				continue
			M.playsound_local(M_turf, null, 60, 1, get_rand_frequency(), falloff = 5, S = far_smith_sound)

/obj/item/gun/ballistic/revolver/grenadelauncher/boltashot/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.3,"sx" = -7,"sy" = -6,"nx" = 7,"ny" = -6,"wx" = -3,"wy" = -6,"ex" = 3,"ey" = -6,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 90,"sturn" = -90,"wturn" = -90,"eturn" = 90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine // fucking unbalanced bullshit that shouldnt exist.
	name = "SUPERMACHINE"
	desc = "UNHOLY"
	icon = 'icons/roguetown/weapons/64.dmi'
	icon_state = "machine"
	possible_item_intents = list(INTENT_GENERIC)
	gripped_intents = list(/datum/intent/shoot/musket/peter, /datum/intent/shoot/musket/arc)
	wieldsound = 'sound/combat/musket_wield.ogg'
	dry_fire_sound = 'sound/foley/muskclick.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/peter
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	bolt_type = BOLT_TYPE_STANDARD
	semi_auto = TRUE
	experimental_onback = TRUE
	casing_ejector = FALSE
	burst_size = 2
	fire_delay = 2
	internal_magazine = TRUE
	tac_reloads = FALSE
	max_integrity = 600
	randomspread = 1
	spread = 0
	bigboy = TRUE
	can_parry = TRUE
	pin = /obj/item/firing_pin
	force = 10
	cartridge_wording = "ball"
	recoil = 4
	load_sound = 'sound/foley/nockarrow.ogg'
	fire_sound = list('sound/combat/Ranged/muskshot1.ogg','sound/combat/Ranged/muskshot2.ogg','sound/combat/Ranged/muskshot3.ogg')
	fire_sound_volume = 500
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	dropshrink = 0.7
	associated_skill = /datum/skill/combat/flintlocks

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine/proc/reloadact(mob/user)
	if(chambered)
		return
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return
	to_chat(user, "<span class='info'>IT IS FILLED</span>")
	magazine.complete_refill()

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine/attack_right(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine/rmb_self(mob/user)
	. = ..()
	reloadact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachiner/dropped(mob/user)
	. = ..()
	if(wielded)
		ungrip(user)
	update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine/update_icon()
	//icon_state = "[initial(icon_state)][wielded]"
	item_state = "[initial(item_state)][wielded]"

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine/attack_self(mob/living/user)
	if(!wielded)
		wield(user)
		update_icon()
	else
		ungrip(user)
		update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/supermachine/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	QDEL_NULL(chambered)
	//new /obj/effect/particle_effect/smoke(get_turf(user))
	SSticker.muskshots++

	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z,user.z))
			continue
		var/turf/M_turf = get_turf(M)
		var/far_smith_sound = sound(pick('sound/ambience/distantshot1.ogg','sound/ambience/distantshot2.ogg','sound/ambience/distantshot3.ogg'))
		if(M_turf)
			var/dist = get_dist(M_turf, loc)
			if(dist < 7)
				continue
			M.playsound_local(M_turf, null, 60, 1, get_rand_frequency(), falloff = 5, S = far_smith_sound)

/obj/item/gun/grenadelauncher/granata
	name = "granatalauncher"
	desc = "To Hell and Back. Load with grenades."
	icon = 'icons/roguetown/weapons/64.dmi'
	icon_state = "granata"
	bigboy = TRUE
	experimental_onback = TRUE
	can_parry = TRUE
	possible_item_intents = list(INTENT_GENERIC)
	gripped_intents = list(/datum/intent/shoot/musket/rifle, /datum/intent/shoot/musket/arc, /datum/intent/mace/smash/wood)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK
	droprot = TRUE
	max_grenades = 3

/obj/item/gun/grenadelauncher/granata/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 0,"nx" = 8,"ny" = 0,"wx" = -5,"wy" = 1,"ex" = 0,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -90,"sturn" = 90,"wturn" = 90,"eturn" = -90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -3,"nx" = -5,"ny" = 0,"wx" = -7,"wy" = -3,"ex" = 7,"ey" = -3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 3,"sturn" = -3,"wturn" = 3,"eturn" = -3,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -5,"sy" = 2,"nx" = 5,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = -3,"ey" = 3,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 90,"eturn" = -90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/obj/item/gun/grenadelauncher/granata/examine(mob/user)
	. = ..()
	. += "<span class='tutorial'>It doesn't need barkenpowder.</span>"
	if(grenades.len)
		. = "It is loaded."
	. += "<span class='tutorial'>It can hold three grenades, note the indicators on the weapon to see how many grenades are left.</span>"

/obj/item/gun/grenadelauncher/granata/update_icon()
	if(grenades.len)
		icon_state = "granata_[grenades.len]"
	else
		icon_state = "granata"

/obj/item/gun/grenadelauncher/granata/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/rogue/bomb)))
		if(grenades.len < max_grenades)
			if(!user.transferItemToLoc(I, src))
				return
			grenades += I
			to_chat(user, "<span class='info'>I load \the [I] into \the [src].</info>")
			playsound(user.loc, 'sound/foley/load_granata.ogg', 75, TRUE, -3)
			update_icon()

/obj/item/gun/grenadelauncher/granata/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	user.visible_message("<span class='danger'>[user] launches a grenade!</span>", \
						"<span class='danger'>I launch a grenade!</span>")
	var/obj/item/rogue/bomb/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.forceMove(user.loc)
	F.throw_at(target, 30, 4, user, spin = TRUE)
	F.lit = TRUE
	playsound(user.loc, 'sound/foley/shoot_granata.ogg', 75, TRUE, -3)
	firearm_recoil_camera(user, 1, 3, get_dir(get_turf(user),get_turf(target)))
	update_icon()

	var/turf/turfa = get_ranged_target_turf(user, turn(user.dir, 180), 1)
	user.throw_at(turfa, 1, 1, null, FALSE)
	
	new /obj/effect/particle_effect/smoke(get_turf(user))