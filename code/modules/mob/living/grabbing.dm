///////////OFFHAND///////////////
/obj/item/grabbing
	name = "pulling"
	icon_state = "pulling"
	icon = 'icons/mob/roguehudgrabs.dmi'
	w_class = WEIGHT_CLASS_HUGE
	possible_item_intents = list(/datum/intent/grab/upgrade)
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	grab_state = 0 //this is an atom/movable var i guess
	no_effect = TRUE
	force = 0
	experimental_inhand = FALSE
	var/grabbed				//ref to what atom we are grabbing
	var/obj/item/bodypart/limb_grabbed		//ref to actual bodypart being grabbed if we're grabbing a carbo
	var/sublimb_grabbed		//ref to what precise (sublimb) we are grabbing (if any) (text)
	var/mob/living/carbon/grabbee
	var/list/dependents = list()
	var/handaction
	var/bleed_suppressing = 0.5 //multiplier for how much we suppress bleeding, can accumulate so two grabs means 25% bleeding

/atom/movable //reference to all obj/item/grabbing
	var/list/grabbedby = list()

/turf
	var/list/grabbedby = list()

/obj/item/grabbing/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C != grabbee)
			qdel(src)
			return 1
		if(modifiers["right"])
			qdel(src)
			return 1
	return ..()

/obj/item/grabbing/proc/update_hands(mob/user)
	if(!user)
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	for(var/i in 1 to C.held_items.len)
		var/obj/item/I = C.get_item_for_held_index(i)
		if(I == src)
			if(i == 1)
				C.r_grab = src
			else
				C.l_grab = src

/datum/proc/grabdropped(obj/item/grabbing/G)
	if(G)
		for(var/datum/D in G.dependents)
			if(D == src)
				G.dependents -= D

/obj/item/grabbing/proc/relay_cancel_action()
	if(handaction)
		for(var/datum/D in dependents) //stop fapping
			if(handaction == D)
				D.grabdropped(src)
		handaction = null

/obj/item/grabbing/Destroy()
	if(isobj(grabbed))
		var/obj/I = grabbed
		I.grabbedby -= src
	if(ismob(grabbed))
		var/mob/M = grabbed
		M.grabbedby -= src
	if(isturf(grabbed))
		var/turf/T = grabbed
		T.grabbedby -= src
	if(grabbee)
		if(grabbee.r_grab == src)
			grabbee.r_grab = null
		if(grabbee.l_grab == src)
			grabbee.l_grab = null
		if(grabbee.mouth == src)
			grabbee.mouth = null
	for(var/datum/D in dependents)
		D.grabdropped(src)
	return ..()

/obj/item/grabbing/dropped(mob/living/user, show_message = TRUE)
	SHOULD_CALL_PARENT(FALSE)
	if(grabbed == user.pulling)
		user.stop_pulling(FALSE)
	if(!user.pulling)
		user.stop_pulling(FALSE)
	for(var/mob/M in user.buckled_mobs)
		if(M == grabbed)
			user.unbuckle_mob(M, force = TRUE)
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/grabbing/attack(mob/living/M, mob/living/user)
	if(M != grabbed)
		return FALSE
	user.changeNext_move(CLICK_CD_MELEE)
	switch(user.used_intent.type)
		if(/datum/intent/grab/upgrade)
			if(!(M.status_flags & CANPUSH) || HAS_TRAIT(M, TRAIT_PUSHIMMUNE))
				to_chat(user, "<span class='warning'>Can't get a grip!</span>")
				return FALSE
			M.grippedby(user)
		if(/datum/intent/grab/choke)
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(M) && M != user)
					var/mob/living/carbon/C = M
					if(get_location_accessible(C, BODY_ZONE_PRECISE_NECK))
						if(prob(23))
							C.emote("choke")
						C.adjustOxyLoss(user.STASTR)
					C.visible_message("<span class='danger'>[user] [pick("chokes", "strangles")] [C]!</span>", \
									"<span class='userdanger'>[user] [pick("chokes", "strangles")] me!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE, user)
					to_chat(user, "<span class='danger'>I [pick("choke", "strangle")] [C]!</span>")
		if(/datum/intent/grab/twist)
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(M))
					twistlimb(user)
		if(/datum/intent/grab/twistitem)
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(ismob(M))
					twistitemlimb(user)
		if(/datum/intent/grab/remove)
			if(isitem(sublimb_grabbed))
				removeembeddeditem(user)
			else
				user.stop_pulling()
		if(/datum/intent/grab/shove)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, "<span class='warning'>I must stand..</span>")
				return
			if(!(M.mobility_flags & MOBILITY_STAND))
				if(user.loc != M.loc)
					to_chat(user, "<span class='warning'>I must be above them.</span>")
					return
				if(src == user.r_grab)
					if(!user.l_grab || user.l_grab.grabbed != M)
						to_chat(user, "<span class='warning'>I must grab them with both hands.</span>")
						return
				if(src == user.l_grab)
					if(!user.r_grab || user.r_grab.grabbed != M)
						to_chat(user, "<span class='warning'>I must grab them with both hands.</span>")
						return
				if(user.STASTR > M.STASTR)
					M.visible_message("<span class='danger'>[user] pins [M] to the ground!</span>", \
									"<span class='userdanger'>[user] pins me to the ground!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE)
					M.Knockdown(300)
					M.Immobilize(300)
					user.Immobilize(30)
				else
					if(prob(23))
						M.visible_message("<span class='danger'>[user] pins [M] to the ground briefly!</span>", \
										"<span class='userdanger'>[user] pins me to the ground briefly!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE)
						M.Knockdown(100)
						M.Immobilize(100)
						user.Immobilize(50)
					else
						M.visible_message("<span class='warning'>[user] tries to pin [M]!</span>", \
										"<span class='danger'>[user] tries to pin me down!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE)
			else
				if(user.STASTR > M.STASTR)
					M.visible_message("<span class='danger'>[user] shoves [M] to the ground!</span>", \
									"<span class='userdanger'>[user] shoves me to the ground!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE)
					M.Knockdown(10)
				else
					if(prob(23))
						M.visible_message("<span class='danger'>[user] shoves [M] to the ground!</span>", \
										"<span class='userdanger'>[user] shoves me to the ground!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE)
						M.Knockdown(1)
					else
						M.visible_message("<span class='warning'>[user] tries to shove [M]!</span>", \
										"<span class='danger'>[user] tries to shove me!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE)

/obj/item/grabbing/proc/twistlimb(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(limb_grabbed, "melee")
	var/damage = user.get_punch_dmg()
	C.next_attack_msg.Cut()
	if(damage >= 25 || prob(3))
		if(limb_grabbed.drop_limb())
			C.visible_message("<span class='danger'>[user] rips off [C]'s [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", \
				"<span class='userdanger'>[user] rips off my [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE, user)
			user.stop_pulling(TRUE)
			user.put_in_active_hand(limb_grabbed, TRUE, TRUE)

			var/obj/item/bodypart/affecting = C.get_bodypart(BODY_ZONE_CHEST)
			if(affecting && limb_grabbed.dismember_wound)
				affecting.add_wound(limb_grabbed.dismember_wound)

			C.emote("painscream")
			limb_grabbed.add_mob_blood(C)
			SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "dismembered", /datum/mood_event/dismembered)
			C.add_stress(/datum/stressevent/dismembered)
			to_chat(user, "<span class='warning'>I rip off [C]'s [parse_zone(sublimb_grabbed)].[C.next_attack_msg.Join()]</span>")
			playsound(C.loc, "headcrush", 100, FALSE, -1)
	else
		playsound(C.loc, "genblunt", 100, FALSE, -1)
		C.apply_damage(damage, BRUTE, limb_grabbed, armor_block)
		limb_grabbed.bodypart_attacked_by(BCLASS_TWIST, damage, user, sublimb_grabbed, crit_message = TRUE)
		C.visible_message("<span class='danger'>[user] twists [C]'s [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", \
						"<span class='userdanger'>[user] twists my [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE, user)
		to_chat(user, "<span class='warning'>I twist [C]'s [parse_zone(sublimb_grabbed)].[C.next_attack_msg.Join()]</span>")
		for(var/obj/item/I in limb_grabbed.embedded_objects)
			limb_grabbed.remove_embedded_object(I)
	C.next_attack_msg.Cut()
	log_combat(user, C, "limbtwisted [sublimb_grabbed] ")

/obj/item/grabbing/proc/twistitemlimb(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/M = grabbed
	var/damage = rand(5,10)
	var/obj/item/I = sublimb_grabbed
	playsound(M.loc, "genblunt", 100, FALSE, -1)
	M.apply_damage(damage, BRUTE, limb_grabbed)
	M.visible_message("<span class='danger'>[user] twists [I] in [M]'s wound!</span>", \
					"<span class='userdanger'>[user] twists [I] in my wound!</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE)
	log_combat(user, M, "itemtwisted [sublimb_grabbed] ")

/obj/item/grabbing/proc/removeembeddeditem(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/M = grabbed
	var/obj/item/bodypart/L = limb_grabbed
	playsound(M.loc, "genblunt", 100, FALSE, -1)
	log_combat(user, M, "itemremovedgrab [sublimb_grabbed] ")
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/obj/item/I = locate(sublimb_grabbed) in L.embedded_objects
		if(QDELETED(I) || QDELETED(L) || !L.remove_embedded_object(I))
			return FALSE
		L.receive_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class) //It hurts to rip it out, get surgery you dingus.
		user.dropItemToGround(src)
		user.put_in_hands(I)
		C.emote("paincrit", TRUE)
		playsound(C, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
		if(usr == src)
			user.visible_message("<span class='notice'>[user] rips [I] out of [user.p_their()] [L.name]!</span>", "<span class='notice'>I rip [I] from my [L.name].</span>")
		else
			user.visible_message("<span class='notice'>[user] rips [I] out of [C]'s [L.name]!</span>", "<span class='notice'>I rip [I] from [C]'s [L.name].</span>")
		sublimb_grabbed = limb_grabbed.body_zone
	else if(HAS_TRAIT(M, TRAIT_SIMPLE_WOUNDS))
		var/obj/item/I = locate(sublimb_grabbed) in M.simple_embedded_objects
		if(QDELETED(I) || !M.simple_remove_embedded_object(I))
			return FALSE
		M.apply_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class, BRUTE) //It hurts to rip it out, get surgery you dingus.
		user.dropItemToGround(src)
		user.put_in_hands(I)
		M.emote("paincrit", TRUE)
		playsound(M, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
		if(user == M)
			user.visible_message("<span class='notice'>[user] rips [I] out of [user.p_them()]self!</span>", "<span class='notice'>I remove [I] from myself.</span>")
		else
			user.visible_message("<span class='notice'>[user] rips [I] out of [M]!</span>", "<span class='notice'>I rip [I] from [src].</span>")
		sublimb_grabbed = M.simple_limb_hit(user.zone_selected)
	user.update_grab_intents(grabbed)
	return TRUE

/obj/item/grabbing/attack_turf(turf/T, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	switch(user.used_intent.type)
		if(/datum/intent/grab/move)
			if(isturf(T))
				user.Move_Pulled(T)
		if(/datum/intent/grab/smash)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, "<span class='warning'>I must stand..</span>")
				return
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(isopenturf(T))
					if(iscarbon(grabbed))
						var/mob/living/carbon/C = grabbed
						if(!C.Adjacent(T))
							return FALSE
						if(C.mobility_flags & MOBILITY_STAND)
							return
						playsound(C.loc, T.attacked_sound, 100, FALSE, -1)
						smashlimb(T, user)
				else if(isclosedturf(T))
					if(iscarbon(grabbed))
						var/mob/living/carbon/C = grabbed
						if(!C.Adjacent(T))
							return FALSE
						if(!(C.mobility_flags & MOBILITY_STAND))
							return
						playsound(C.loc, T.attacked_sound, 100, FALSE, -1)
						smashlimb(T, user)

/obj/item/grabbing/attack_obj(obj/O, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.used_intent.type == /datum/intent/grab/smash)
		if(isstructure(O) && O.blade_dulling != DULLING_CUT)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, "<span class='warning'>I must stand..</span>")
				return
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(grabbed))
					var/mob/living/carbon/C = grabbed
					if(!C.Adjacent(O))
						return FALSE
					playsound(C.loc, O.attacked_sound, 100, FALSE, -1)
					smashlimb(O, user)


/obj/item/grabbing/proc/smashlimb(atom/A, mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(limb_grabbed, "melee")
	var/damage = user.get_punch_dmg()
	C.next_attack_msg.Cut()
	if(C.apply_damage(damage, BRUTE, limb_grabbed, armor_block))
		limb_grabbed.bodypart_attacked_by(BCLASS_BLUNT, damage, user, sublimb_grabbed, crit_message = TRUE)
		playsound(C.loc, "smashlimb", 100, FALSE, -1)
	else
		C.next_attack_msg += " <span class='warning'>⛊ARMOR⛊</span>"
	C.visible_message("<span class='danger'>[user] smashes [C]'s [limb_grabbed] into [A]![C.next_attack_msg.Join()]</span>", \
					"<span class='userdanger'>[user] smashes my [limb_grabbed] into [A]![C.next_attack_msg.Join()]</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE, user)
	to_chat(user, "<span class='warning'>I smash [C]'s [limb_grabbed] against [A].[C.next_attack_msg.Join()]</span>")
	C.next_attack_msg.Cut()
	log_combat(user, C, "limbsmashed [limb_grabbed] ")

/datum/intent/grab
	unarmed = TRUE
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	canparry = FALSE
	no_attack = TRUE

/datum/intent/grab/move
	name = "grab move"
	desc = ""
	icon_state = "inmove"

/datum/intent/grab/upgrade
	name = "upgrade grab"
	desc = ""
	icon_state = "ingrab"

/datum/intent/grab/smash
	name = "smash"
	desc = ""
	icon_state = "insmash"

/datum/intent/grab/twist
	name = "twist"
	desc = ""
	icon_state = "intwist"

/datum/intent/grab/choke
	name = "choke"
	desc = ""
	icon_state = "inchoke"

/datum/intent/grab/shove
	name = "shove"
	desc = ""
	icon_state = "intackle"

/datum/intent/grab/twistitem
	name = "twist in wound"
	desc = ""
	icon_state = "intwist"

/datum/intent/grab/remove
	name = "remove"
	desc = ""
	icon_state = "intake"


/obj/item/grabbing/bite
	name = "bite"
	icon_state = "bite"
	slot_flags = ITEM_SLOT_MOUTH
	bleed_suppressing = 1
	var/last_drink

/obj/item/grabbing/bite/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C != grabbee)
			qdel(src)
			return 1
		if(modifiers["right"])
			qdel(src)
			return 1
		var/_y = text2num(params2list(params)["icon-y"])
		if(_y>=17)
			bitelimb(C)
		else
			drinklimb(C)
	return 1

/obj/item/grabbing/bite/process()
	..()
	if(!grabbee.Adjacent(grabbed))
		qdel(src)
		return

/obj/item/grabbing/bite/proc/bitelimb(mob/living/user) //implies limb_grabbed and sublimb are things
	if(!user.Adjacent(grabbed))
		qdel(src)
		return
	if(world.time <= user.next_move)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(sublimb_grabbed, "melee")
	var/damage = user.get_punch_dmg()
	if(HAS_TRAIT(user, TRAIT_STRONGBITE))
		damage = damage*2
	C.next_attack_msg.Cut()
	if(C.apply_damage(damage, BRUTE, limb_grabbed, armor_block))
		playsound(C.loc, "smallslash", 100, FALSE, -1)
		limb_grabbed.bodypart_attacked_by(BCLASS_BITE, damage, user, sublimb_grabbed, crit_message = TRUE)
		if(user.mind)
			if(user.mind.has_antag_datum(/datum/antagonist/werewolf))
				var/mob/living/carbon/human/H = C
				if(prob(25) && H)
					spawn(3 MINUTES)
						H.werewolf_infect()
					//addtimer(CALLBACK(C, TYPE_PROC_REF(/mob/living/carbon/human, werewolf_infect)), 3 MINUTES)
			if(user.mind.has_antag_datum(/datum/antagonist/zombie))
				var/mob/living/carbon/human/H = C
				INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon/human, zombie_infect_attempt))
				if(C.stat)
					if(istype(limb_grabbed, /obj/item/bodypart/head))
						var/obj/item/bodypart/head/HE = limb_grabbed
						if(HE.brain)
							QDEL_NULL(HE.brain)
							C.visible_message("<span class='danger'>[user] consumes [C]'s brain!</span>", \
								"<span class='userdanger'>[user] consumes my brain!</span>", "<span class='hear'>I hear a sickening sound of chewing!</span>", COMBAT_MESSAGE_RANGE, user)
							to_chat(user, "<span class='boldnotice'>Braaaaaains!</span>")
							if(!user.mob_timers["zombie_tri"])
								user.adjust_triumphs(1)
								user.mob_timers["zombie_tri"] = world.time
							playsound(C.loc, 'sound/combat/fracture/headcrush (2).ogg', 100, FALSE, -1)
							return
	else
		C.next_attack_msg += " <span class='warning'>⛊ARMOR⛊</span>"
	C.visible_message("<span class='danger'>[user] bites [C]'s [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", \
					"<span class='userdanger'>[user] bites my [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", "<span class='hear'>I hear a sickening sound of chewing!</span>", COMBAT_MESSAGE_RANGE, user)
	to_chat(user, "<span class='danger'>I bite [C]'s [parse_zone(sublimb_grabbed)].[C.next_attack_msg.Join()]</span>")
	C.next_attack_msg.Cut()
	log_combat(user, C, "limb chewed [sublimb_grabbed] ")

//this is for carbon mobs being drink only
/obj/item/grabbing/bite/proc/drinklimb(mob/living/user) //implies limb_grabbed and sublimb are things
	if(!user.Adjacent(grabbed))
		qdel(src)
		return
	if(world.time <= user.next_move)
		return
	if(world.time < last_drink + 2 SECONDS)
		return
	if(!limb_grabbed.get_bleed_rate())
		to_chat(user, "<span class='warning'>Sigh. It's not bleeding.</span>")
		return
	var/mob/living/carbon/C = grabbed
	if(C.dna?.species && (NOBLOOD in C.dna.species.species_traits))
		to_chat(user, "<span class='warning'>Sigh. No blood.</span>")
		return
	if(C.blood_volume <= 0)
		to_chat(user, "<span class='warning'>Sigh. No blood.</span>")
		return
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.wear_neck, /obj/item/clothing/neck/roguetown/psicross/silver))
			to_chat(user, "<span class='userdanger'>SILVER! HISSS!!!</span>")
			return
	last_drink = world.time
	user.changeNext_move(CLICK_CD_MELEE)

	if(user.mind && C.mind)
		var/datum/antagonist/vampirelord/VDrinker = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
		var/datum/antagonist/vampirelord/VVictim = C.mind.has_antag_datum(/datum/antagonist/vampirelord)
		var/zomwerewolf = C.mind.has_antag_datum(/datum/antagonist/werewolf)
		if(!zomwerewolf)
			if(C.stat != DEAD)
				zomwerewolf = C.mind.has_antag_datum(/datum/antagonist/zombie)
		if(VDrinker)
			if(zomwerewolf)
				to_chat(user, "<span class='danger'>I'm going to puke...</span>")
				addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon, vomit), 0, TRUE), rand(8 SECONDS, 15 SECONDS))
			else
				if(VVictim)
					to_chat(user, "<span class='warning'>It's vitae, just like mine.</span>")
				else
					C.blood_volume = max(C.blood_volume-45, 0)
					if(ishuman(C))
						var/mob/living/carbon/human/H = C
						if(H.virginity)
							to_chat(user, "<span class='love'>Virgin blood, delicious!</span>")
							var/mob/living/carbon/V = user
							V.add_stress(/datum/stressevent/vblood)
							if(VDrinker.isspawn)
								VDrinker.handle_vitae(750, 750)
							else
								VDrinker.handle_vitae(1000)
					if(VDrinker.isspawn)
						VDrinker.handle_vitae(500, 500)
					else
						VDrinker.handle_vitae(500)
		else
/*			if(VVictim)
				to_chat(user, "<span class='notice'>A strange, sweet taste tickles my throat.</span>")
				addtimer(CALLBACK(user, .mob/living/carbon/human/proc/vampire_infect), 1 MINUTES) // I'll use this for succession later.
			else */
			to_chat(user, "<span class='warning'>I'm going to puke...</span>")
			addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon, vomit), 0, TRUE), rand(8 SECONDS, 15 SECONDS))
	else
		if(user.mind)
			if(user.mind.has_antag_datum(/datum/antagonist/vampirelord))
				var/datum/antagonist/vampirelord/VDrinker = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
				C.blood_volume = max(C.blood_volume-45, 0)
				if(VDrinker.isspawn)
					VDrinker.handle_vitae(300, 300)
				else
					VDrinker.handle_vitae(300)

	C.blood_volume = max(C.blood_volume-5, 0)
	C.handle_blood()

	playsound(user.loc, 'sound/misc/drink_blood.ogg', 100, FALSE, -4)

	C.visible_message("<span class='danger'>[user] drinks from [C]'s [parse_zone(sublimb_grabbed)]!</span>", \
					"<span class='userdanger'>[user] drinks from my [parse_zone(sublimb_grabbed)]!</span>", "<span class='hear'>...</span>", COMBAT_MESSAGE_RANGE, user)
	to_chat(user, "<span class='warning'>I drink from [C]'s [parse_zone(sublimb_grabbed)].</span>")
	log_combat(user, C, "drank blood from ")

	if(ishuman(C) && C.mind)
		var/datum/antagonist/vampirelord/VDrinker = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
		if(C.blood_volume <= BLOOD_VOLUME_SURVIVE)
			if(!VDrinker.isspawn)
				switch(alert("Would you like to sire a new spawn?",,"Yes","No"))
					if("Yes")
						user.visible_message("[user] begins to infuse dark magic into [C]")
						if(do_after(user, 30))
							C.visible_message("[C] rises as a new spawn!")
							var/datum/antagonist/vampirelord/lesser/new_antag = new /datum/antagonist/vampirelord/lesser()
							new_antag.sired = TRUE
							C.mind.add_antag_datum(new_antag)
							sleep(20)
							C.fully_heal()
					if("No")
						to_chat(user, "<span class='warning'>I decide [C] is unworthy.</span>")
