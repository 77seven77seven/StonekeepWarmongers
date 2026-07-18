/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock
	name = "longbark"
	desc = "A heavy barker with a magnifying lens, designed to kill at great distances."
	icon='icons/roguetown/weapons/64.dmi'
	icon_state = "musketsniper"
	item_state = "musketsniper"

	possible_item_intents = list(INTENT_GENERIC)
	gripped_intents = list(
		/datum/intent/shoot/musket/rifle,
		/datum/intent/shoot/musket/arc,
		/datum/intent/mace/smash/wood
	)

	wieldsound='sound/combat/musket_wield.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musk
	slot_flags = ITEM_SLOT_BACK

	experimental_onback = TRUE
	w_class = WEIGHT_CLASS_BULKY
	spread = 5
	max_integrity = 600   // Having your gun broken while parrying sucks.
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	walking_stick = TRUE

	var/cocked = FALSE
	var/rammed = FALSE
	var/bayonetable = FALSE
	var/has_bayonet = FALSE
	var/has_barkenpowder = FALSE
	var/click_delay = 2
	var/obj/item/rogue/ramrod/rod
	var/ramtime = 5.5

	bigboy = TRUE
	can_parry = TRUE
	droprot = TRUE
	pin = /obj/item/firing_pin
	force = 10
	recoil = 3

	cartridge_wording = "ball"
	load_sound='sound/foley/musket_load.ogg'
	fire_sound = list(
		'sound/combat/Ranged/muskshot1.ogg',
		'sound/combat/Ranged/muskshot2.ogg',
		'sound/combat/Ranged/muskshot3.ogg',
		'sound/combat/Ranged/muskshot4.ogg',
		'sound/combat/Ranged/muskshot5.ogg',
		'sound/combat/Ranged/muskshot6.ogg'
	)
	fire_sound_volume = 500
	vary_fire_sound = TRUE
	drop_sound='sound/foley/gun_drop.ogg'
	dropshrink = 0.7
	associated_skill = /datum/skill/combat/flintlocks

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list(
					"shrink" = 0.5,
					"sx" = -7, "sy" = 0,
					"nx" = 8,  "ny" = 0,
					"wx" = -5, "wy" = 1,
					"ex" = 0,  "ey" = 1,
					"northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0,
					"nturn" = -90, "sturn" = 90, "wturn" = 90, "eturn" = -90,
					"nflip" = 0,   "sflip" = 8,  "wflip" = 8,  "eflip" = 0
				)
			if("wielded")
				return list(
					"shrink" = 0.5,
					"sx" = 5,  "sy" = -3,
					"nx" = -5, "ny" = 0,
					"wx" = -7, "wy" = -3,
					"ex" = 7,  "ey" = -3,
					"northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0,
					"nturn" = 3,  "sturn" = -3, "wturn" = 3,  "eturn" = -3,
					"nflip" = 8,  "sflip" = 0,  "wflip" = 8,  "eflip" = 0
				)
			if("onback")
				return list(
					"shrink" = 0.5,
					"sx" = -5, "sy" = 2,
					"nx" = 5,  "ny" = 2,
					"wx" = 3,  "wy" = 3,
					"ex" = -3, "ey" = 3,
					"northabove" = 1, "southabove" = 0, "eastabove" = 0, "westabove" = 0,
					"nturn" = -38, "sturn" = 37, "wturn" = 90,  "eturn" = -90,
					"nflip" = 0,   "sflip" = 8,  "wflip" = 8,  "eflip" = 0
				)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/examine(mob/user)
	. = ..()
	. += "<span class='tutorial'>Use shift+middleclick to cock the weapon.</span>"
	. += "<span class='tutorial'>Use middleclick to remove or put back the ramrod.</span>"
	if(has_bayonet)
		. += "<span class='tutorial'>Use rightclick to remove the bayonet.</span>"

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/Initialize()
	. = ..()
	rod = new /obj/item/rogue/ramrod(src)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/equipped(mob/living/user, slot)
	. = ..()
	playsound(loc, 'sound/foley/gun_equip.ogg', 100, TRUE)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/dropped(mob/user)
	. = ..()
	if(wielded)
		ungrip(user)
	update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/update_icon()
	item_state = "[initial(item_state)][wielded]"

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/attack_self(mob/living/user)
	if(!wielded)
		wield(user)
	else
		ungrip(user)
	update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/MiddleClick(mob/user, params)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(rod)
		H.put_in_hands(rod)
		rod = null
		to_chat(H, "<span class='info'>I remove the ramrod from \the [src].</span>")
		playsound(src.loc, 'sound/foley/ramrodremoval.ogg', 100, FALSE, -1)
	else if(istype(H.get_active_held_item(), /obj/item/rogue/ramrod))
		var/obj/item/rogue/ramrod/rrod = H.get_active_held_item()
		rrod.forceMove(src)
		rod = rrod
		H.update_a_intents()
		to_chat(H, "<span class='info'>I put \the [rrod] into \the [src].</span>")
		playsound(src.loc, 'sound/foley/ramrodentry.ogg', 100, FALSE, -1)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/ShiftMiddleClick(mob/user)
	if(!cocked)
		playsound(src.loc, 'sound/foley/muskclick.ogg', 100, FALSE)
		to_chat(user, "<span class='info'>I cock \the [src].</span>")
		cocked = TRUE

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/attack_right(mob/user)
	if(!user.is_holding(src))
		to_chat(user, "<span class='warning'>I need to hold \the [src] to do that!</span>")
		return
	if(!has_bayonet)
		return
	if(!do_after(user, 3 SECONDS, TRUE, src))
		return
	has_bayonet = FALSE
	gripped_intents -= /datum/intent/dagger/thrust
	icon_state = initial(icon_state)
	update_icon()
	var/obj/item/rogueweapon/huntingknife/bayonet/B = new()
	if(user.put_in_hands(B))
		to_chat(user, "<span class='info'>I detach the bayonet from \the [src] and hold it in my hand.</span>")
	else
		B.forceMove(get_turf(user))
		to_chat(user, "<span class='info'>I detach the bayonet from \the [src] but have no free hand, so it drops to the ground.</span>")
	playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/attackby(obj/item/A, mob/user, params)
	var/tt = ramtime - (user.mind.get_skill_level(/datum/skill/combat/flintlocks) / 2.5)

	if(aspect_chosen(/datum/round_aspect/linefocus))
		tt += 3

	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.formation_check())
			tt -= 0.6

	if(tt < 0.1)
		tt = 0.1

	if(aspect_chosen(/datum/round_aspect/noreloading))
		tt = 0.1

	// --- Ramrod ---
	if(istype(A, /obj/item/rogue/ramrod))
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>I need to hold \the [src] to ram it!</span>")
			return
		if(chambered && !rammed)
			playsound(src.loc, 'sound/combat/ramrod_working.ogg', 100, FALSE, -3)
			if(move_after(user, tt SECONDS, TRUE, src))
				to_chat(user, "<span class='info'>I ram \the [src].</span>")
				rammed = TRUE
		return

	// --- Powder flask ---
	else if(istype(A, /obj/item/rogue/barkenpowderflask))
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>I need to hold \the [src] to add barkenpowder!</span>")
			return
		if(!has_barkenpowder)
			playsound(src.loc, 'sound/foley/powder.ogg', 100, FALSE, -3)
			if(move_after(user, tt SECONDS, TRUE, src))
				to_chat(user, "<span class='info'>I add barkenpowder to \the [src].</span>")
				has_barkenpowder = TRUE
		return

	// --- Bayonet ---
	else if(istype(A, /obj/item/rogueweapon/huntingknife/bayonet))
		if(!bayonetable)
			to_chat(user, "<span class='warning'>I can't attach a bayonet to this weapon!</span>")
			return
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>I need to hold \the [src] to attach a bayonet!</span>")
			return
		if(has_bayonet)
			to_chat(user, "<span class='warning'>A bayonet is already attached!</span>")
			return
		if(!do_after(user, 3 SECONDS, TRUE, src))
			return
		has_bayonet = TRUE
		gripped_intents += list(/datum/intent/dagger/thrust)
		icon_state = "[initial(icon_state)]_b"
		update_icon()
		qdel(A)
		to_chat(user, "<span class='info'>I attach a bayonet to \the [src].</span>")
		playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)
		return
	else
		return ..()

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/shoot_with_empty_chamber(mob/living/user)
	if(!cocked)
		return
	playsound(src.loc, 'sound/combat/Ranged/muskfire.ogg', 100, FALSE)
	cocked = FALSE
	rammed = FALSE
	has_barkenpowder = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!cocked)
		return
	if(!rammed)
		return

	if(user.client)
		if(!has_barkenpowder)
			playsound(src.loc, 'sound/items/match_fail.ogg', 100, FALSE)
			to_chat(user, "<span class='info'>I dry fire \the [src]!</span>")
			cocked = FALSE
			return
		if(HAS_TRAIT(user, TRAIT_UNTRAINED))
			to_chat(user, "<span class='info'>I don't know how this works.</span>")
			playsound(src.loc, 'sound/items/match_fail.ogg', 100, FALSE)
			cocked = FALSE
			return

	// Spread calculation.
	if(user.client)
		if(user.client.chargedprog >= 80)
			spread = 0
		else
			spread = 125 - (125 * (user.client.chargedprog / 100))
	else
		spread = 0

	// Accuracy bonuses.
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/BB = CB.BB
		if(user.client)
			if(user.client.chargedprog >= 50)
				BB.accuracy       += 20   // Better accuracy when fully aimed.
				BB.bonus_accuracy += 2
			if(user.client.chargedprog >= 95)
				BB.accuracy       += 50   // Fully accurate.
				BB.bonus_accuracy += 50
			if(user.STAPER > 8)
				// Each point of Perception above 8 improves accuracy.
				BB.accuracy       += (user.STAPER - 8) * 4
				BB.bonus_accuracy += (user.STAPER - 8)
			if(user.lying)
				BB.accuracy       += 30
				BB.bonus_accuracy += 50
			if(user.m_intent == MOVE_INTENT_SNEAK)
				BB.bonus_accuracy += 2
			if(has_bayonet)
				BB.bonus_accuracy -= 1   // Bayonet slightly hampers aim.
		BB.bonus_accuracy += (user.mind.get_skill_level(/datum/skill/combat/flintlocks) * 2)

	// Fire!
	playsound(src.loc, 'sound/combat/Ranged/muskfire.ogg', 100, FALSE)
	cocked = FALSE
	rammed = FALSE
	has_barkenpowder = FALSE
	sleep(click_delay)
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	spawn()
		for(var/i=1,i<=4,i++)
			sleep(rand(0.1,0.4))
			var/angle = dir2angle(user.dir)
			angle += rand(-25, 25)

			var/px = round(128 * sin(angle))
			var/py = round(128 * cos(angle))

			var/obj/effect/temp_visual/small_smoke/gunsmoke/S = new(get_step(user.loc, user.dir))
			var/matrix/ARE = matrix()
			ARE.Scale(5, 5)
			ARE.Turn(rand(-350, 350))

			var/randtime = rand(30,50)
			animate(S, time = randtime, alpha = 0, pixel_x = px, pixel_y = py, transform = ARE, easing = SINE_EASING)
			QDEL_IN(S, randtime)

	firearm_recoil_mob(user)

	SSticker.muskshots++

	var/far_shot
	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z, user.z))
			continue
		var/turf/M_turf = get_turf(M)
		if(!M_turf)
			continue
		if(get_dist(M_turf, loc) < 7)
			continue
		far_shot = pick('sound/ambience/distantshot1.ogg','sound/ambience/distantshot2.ogg','sound/ambience/distantshot3.ogg')
		M.playsound_local(M_turf, far_shot, 60, 1, get_rand_frequency(), falloff = 5)

// = ===========================================================
//  SUBTYPES — Sniper variants
// = ===========================================================

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/sniper
	desc = "A heavy barker with a magnifying lens, designed to kill at great distances."
	icon_state = "musketsniper"
	gripped_intents = list(
		/datum/intent/shoot/musket,
		/datum/intent/shoot/musket/arc,
		/datum/intent/mace/heavy/strike
	)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/sniper/alternate
	icon_state = "musketsniper1"

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/sniper/scythed
	desc = "A heavy barker with a magnifying lens, designed to kill at great distances. This one haphazardly has a scythehead attached to the end of the barrel."
	icon_state = "musketsniperscythe"
	gripped_intents = list(
		/datum/intent/shoot/musket,
		/datum/intent/shoot/musket/arc,
		/datum/intent/mace/heavy/strike,
		/datum/intent/spear/halberd/chop
	)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/bayo
	name = "barkmusket"
	desc = "A barker used to kill at distance, and can be fitted with a bayonet for close encounters."
	icon_state = "musket"
	bayonetable = TRUE
	spread = 0.5
	gripped_intents = list(
		/datum/intent/shoot/musket,
		/datum/intent/shoot/musket/arc,
		/datum/intent/mace/smash/wood
	)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/bayo/carbine
	icon='icons/roguetown/weapons/64.dmi'
	icon_state = "musket1"
	item_state = "musket1"


// = ===========================================================
//  SUBTYPES — Pistol
// = ===========================================================

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol
	name = "barkpistol"
	desc = "A lightweight barker small enough to be held in just one hand, favored by officers."
	icon='icons/roguetown/weapons/32.dmi'
	lefthand_file='icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file='icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "pistol"
	item_state = "pistol"

	bigboy = FALSE
	walking_stick = FALSE
	recoil = 2
	spread = 3
	click_delay = 2.4
	experimental_onback = TRUE
	gripsprite = FALSE
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	ramtime = 3.4

	possible_item_intents = list(
		/datum/intent/shoot/musket/pistol,
		/datum/intent/shoot/musket/arc,
		/datum/intent/mace/strike/wood
	)
	gripped_intents = null

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list(
					"shrink" = 0.3,
					"sx" = -7, "sy" = -6,
					"nx" = 7,  "ny" = -6,
					"wx" = -3, "wy" = -6,
					"ex" = 3,  "ey" = -6,
					"northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0,
					"nturn" = 90,  "sturn" = -90, "wturn" = -90, "eturn" = 90,
					"nflip" = 0,   "sflip" = 8,   "wflip" = 8,   "eflip" = 0
				)
			if("onbelt")
				return list(
					"shrink" = 0.3,
					"sx" = -2, "sy" = -5,
					"nx" = 4,  "ny" = -5,
					"wx" = 0,  "wy" = -5,
					"ex" = 2,  "ey" = -5,
					"nturn" = 0, "sturn" = 0, "wturn" = 0, "eturn" = 0,
					"nflip" = 0, "sflip" = 0, "wflip" = 0, "eflip" = 0,
					"northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0
				)

// Pistols don't use the wield-toggling self-attack or icon update from the base type.
/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/attack_self(mob/living/user)
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/update_icon()
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/alternate
	icon_state = "pistol1"
	item_state = "pistol1"


// = ===========================================================
//  SUBTYPES — Pistol combo weapons
// = ===========================================================

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/axed  // i axed you a question
	name = "barkaxe"
	desc = "A hefty barkpistol equipped with an axe for close combat."
	icon='icons/roguetown/weapons/32.dmi'
	lefthand_file='icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file='icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "pistolaxe"
	item_state = "pistolaxe"
	slot_flags = ITEM_SLOT_HIP
	walking_stick = FALSE
	possible_item_intents = list(
		/datum/intent/shoot/musket/pistol,
		/datum/intent/shoot/musket/arc,
		/datum/intent/axe/chop,
		/datum/intent/axe/cut
	)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/axed/alternate
	icon_state = "pistolaxe1"
	item_state = "pistolaxe1"


/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded  // i sword what you did there
	name = "barksword"
	desc = "A sleek sabre with a miniaturized barkpistol attached, an especially complex and valuable weapon."
	icon='icons/roguetown/weapons/32.dmi'
	lefthand_file='icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file='icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "sabergunp"
	item_state = "sabergunp"
	slot_flags = ITEM_SLOT_HIP
	walking_stick = FALSE
	associated_skill = /datum/skill/combat/swords
	possible_item_intents = list(
		/datum/intent/shoot/musket,
		/datum/intent/shoot/musket/arc,
		/datum/intent/sword/cut/sabre,
		/datum/intent/sword/chop
	)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list(
					"shrink" = 0.5,
					"sx" = -10, "sy" = -8,
					"nx" = 13,  "ny" = -8,
					"wx" = -8,  "wy" = -7,
					"ex" = 7,   "ey" = -8,
					"northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0,
					"nturn" = 90,  "sturn" = -90, "wturn" = -80, "eturn" = 81,
					"nflip" = 0,   "sflip" = 8,   "wflip" = 8,   "eflip" = 0
				)
			if("wielded")
				return list(
					"shrink" = 0.6,
					"sx" = 3,  "sy" = 4,
					"nx" = -1, "ny" = 4,
					"wx" = -8, "wy" = 3,
					"ex" = 7,  "ey" = 0,
					"northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0,
					"nturn" = 0,  "sturn" = 0,  "wturn" = 0,  "eturn" = 15,
					"nflip" = 8,  "sflip" = 0,  "wflip" = 8,  "eflip" = 0
				)
			if("onbelt")
				return list(
					"shrink" = 0.5,
					"sx" = -4, "sy" = -6,
					"nx" = 5,  "ny" = -6,
					"wx" = 0,  "wy" = -6,
					"ex" = -1, "ey" = -6,
					"nturn" = 100, "sturn" = 156, "wturn" = 90, "eturn" = 180,
					"nflip" = 0,   "sflip" = 0,   "wflip" = 0,  "eflip" = 0,
					"northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0
				)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/alternate
	icon_state = "sabergunr"
	item_state = "sabergunr"


// = ===========================================================
//  SUBTYPES — Shotgun (blunderbark / nockbark)
// = ===========================================================

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/shotgun
	name = "blunderbark"
	desc = "Named for its ability to cause quite the blunder."
	icon_state = "blunder"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/gun
	bayonetable = FALSE
	force = 20
	force_wielded = 35
	gripped_intents = list(
		/datum/intent/shoot/musket/shotgun,
		/datum/intent/mace/heavy/smash
	)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/shotgun/examine(mob/user)
	. = ..()
	. += "<span class='tutorial'>SNEAK while using this weapon to make sure you don't get blown (to hell and) back.</span>"

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/shotgun/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	. = ..()
	if(user.m_intent == MOVE_INTENT_SNEAK)
		return
	// Massive recoil hurls the shooter backwards.
	var/turf/turfa = get_ranged_target_turf(user, turn(user.dir, 180), 40)
	user.throw_at(turfa, 40, 1, null, TRUE)
	user.take_overall_damage(65)
	user.unlock_achievement(new /datum/achievement/backblast())
	user.visible_message("<span class='danger'>\The [user] is thrown back from \the [src]'s recoil!</span>")

// Shotgun alt

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/shotgun/alternate
	name = "nockbark"
	desc = "Named for its ability to cause quite the nock... bark.  This joke really doesn't fucking work, does it?"
	icon_state = "nockgun"

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/shotgun/alternate/Initialize()
	. = ..()
	if(prob(50))
		name = "plunderbark"
		desc = "Named for its ability to cause quite the plunder."


// = ===========================================================
//  AMMO MAGAZINES
// = ===========================================================

/obj/item/ammo_box/magazine/internal/shot/musk
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bullet
	caliber = "musketball"
	max_ammo = 1
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/shot/gun  // get it? shotgun?
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bullet/shotgun
	caliber = "bagball"
	max_ammo = 1
	start_empty = TRUE


// = ===========================================================
//  SUPPORTING ITEMS
// = ===========================================================

/obj/item/rogue/ramrod
	name = "rod of ramming"
	desc = "Used to force ammunition down a barrel."
	drop_sound='sound/combat/ramrod_pickup.ogg'
	icon='icons/roguetown/items/misc.dmi'
	icon_state = "ramrod"
	force = 15
	possible_item_intents = list(
		/datum/intent/use,
		/datum/intent/mace/strike,
		/datum/intent/mace/smash
	)

/obj/item/rogue/barkenpowderflask
	name = "powderflask"
	desc = "A leather pouch containing barkenpowder."
	icon='icons/roguetown/items/misc.dmi'
	icon_state = "powderflask"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_NECK