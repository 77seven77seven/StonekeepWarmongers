#define CRANKER_CHEMS		list("HEALTH","DUST OF MOON","OZ","LOVE","SMONKAID","SYNADRENALINEN","COAGULATIONIUM")

/obj/item/rogue/cranker
	name = "SCHLaNKER"
	desc = "A strange skull-shaped medical device used to grind up bodyparts and teeth to make all sorts of things, including chemicals, medicine, and new glass bootles."
	icon = 'icons/roguetown/items/cooking.dmi'
	icon_state = "cranker"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP
	var/obj/item/bp // bodypart/teeth to grind
	var/datum/reagent/chosen_potion = /datum/reagent/medicine/healthpot
	var/obj/item/pot // where to put the health potion
	var/counter = 0 // make 3 potions for 1 triumph

/obj/item/rogue/cranker/New(loc, ...)
	. = ..()
	if(prob(30))
		name = "KRaTOM" // Don't eat mud.
	else if(prob(30))
		name = "CRaNKER"

/obj/item/rogue/cranker/examine(mob/user)
	. = ..()
	if(pot)
		. += "<span class='info'>It's loaded.</span>"
		. += "<span class='tutorial'>Use middleclick to unscrew the bottle.</span>"
	else
		. += "<span class='tutorial'>Use middleclick to fabricate a new glass bottle.</span>"
	if(bp)
		. += "<span class='tutorial'>Use it in-hand to begin grinding.</span>"
	. += "<span class='tutorial'>Use rightclick to change what you'll be cooking.</span>"

/obj/item/rogue/cranker/attack(mob/living/M, mob/living/user)
	. = ..()
	if(M.stat == DEAD)
		counter++
		if(counter >= 5)
			user.adjust_triumphs(1)
			counter = 0
		else
			to_chat(user, "<span class='tutorial'>TRI PROGRESS+</span>")
		M.dust(TRUE, FALSE)
		playsound(get_turf(M), 'sound/magic/heal.ogg', 75, TRUE)

/obj/item/rogue/cranker/MiddleClick(mob/user, params)
	if(user.mind.get_skill_level(/datum/skill/misc/medicine) <= 1)
		to_chat(user, "<span class='warning'>I don't know how to use this.</span>")
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(pot)
		to_chat(user, "<span class='info'>I unscrew \the [pot] from the [src].</span>")
		playsound(get_turf(user), 'sound/foley/grab.ogg', 100, FALSE, -2)
		H.put_in_hands(pot)
		pot = null
	else
		to_chat(user, "<span class='info'>I fabricate a new glass bottle into my [src].</span>")
		playsound(get_turf(user), 'sound/foley/winch.ogg', 100, FALSE, -2)
		pot = new /obj/item/reagent_containers/glass/bottle/rogue(src)
		return

/obj/item/rogue/cranker/proc/cook_select(mob/user)
	var/chosen = input(user, "What are we cooking today?", "WARMONGERS") as null|anything in CRANKER_CHEMS
	if(!chosen)
		return
	switch(chosen)
		if("HEALTH")
			chosen_potion = /datum/reagent/medicine/healthpot
			to_chat(user, "<span class='info'>People will love you, but they will all know you're just a little too boring. HEALING+</span>")
		if("DUST OF MOON")
			chosen_potion = /datum/reagent/moondust
			to_chat(user, "<span class='info'>After all, you didn't want those bullets piercing your lungs anyway. SPEED+</span>")
		if("OZ")
			chosen_potion = /datum/reagent/ozium
			to_chat(user, "<span class='info'>Everyone loves it, who doesn't? You'll be unbeatable. STRENGTH+, SPEED-</span>")
		if("LOVE")
			chosen_potion = /datum/reagent/druqks
			to_chat(user, "<span class='info'>Love defeats all hardship. ENDURANCE+</span>")
		if("SMONKAID")
			chosen_potion = /datum/reagent/smonkium
			to_chat(user, "<span class='info'>Favoured by marksman-merks. PERCEPTION+, SPEED-</span>")
		if("SYNADRENALINEN")
			chosen_potion = /datum/reagent/adrenalinen
			to_chat(user, "<span class='info'>Synthetic natural morphium. A must have for all soldiers! ADRENALINE+</span>")
		if("COAGULATIONIUM")
			chosen_potion = /datum/reagent/coagulationium
			to_chat(user, "<span class='info'>Natural coagulationium, made from boiled blood and tears. BLOOD-LOSS-IMMUNITY+</span>")

/obj/item/rogue/cranker/attack_right(mob/user)
	cook_select(user)

/obj/item/rogue/cranker/rmb_self(mob/user)
	cook_select(user)

/obj/item/rogue/cranker/attack_self(mob/living/carbon/human/user)
	. = ..()
	var/datum/game_mode/warmongers/C = SSticker.mode
	if(user.mind.get_skill_level(/datum/skill/misc/medicine) <= 1)
		to_chat(user, "<span class='warning'>I don't know how to use this.</span>")
		return
	if(!bp)
		to_chat(user, "<span class='warning'>You can't crank the [src] if there's nothing in it. You wouldn't want to damage the gears, would you?</span>")
		return
	if(!pot)
		to_chat(user, "<span class='warning'>You're gonna need to attach a bottle, otherwise our divine gift will just go to waste.</span>")
		return
	playsound(get_turf(user), 'sound/neu/peppermill.ogg', 100, TRUE, -5)
	flick("cranker-cranking", src)
	QDEL_NULL(bp)
	sleep(10)
	playsound(get_turf(user), "wetbreak", 100, TRUE, -5)
	pot.reagents.add_reagent(chosen_potion, 25)
	to_chat(user, "<span class='info'>The product is ready.</span>")
	counter++
	if(counter >= 3)
		user.adjust_triumphs(1)
		counter = 0
	else
		to_chat(user, "<span class='tutorial'>TRI PROGRESS+</span>")
	switch(user.warfare_faction)
		if(RED_WARTEAM)
			C.red_bonus++
			to_chat(user, "<span class='tutorial'>+1 SUPPLY POINT</span>")
		if(BLUE_WARTEAM)
			C.blu_bonus++
			to_chat(user, "<span class='tutorial'>+1 SUPPLY POINT</span>")
	
/obj/item/rogue/cranker/attackby(obj/item/I, mob/user, params)
	if(user.mind.get_skill_level(/datum/skill/misc/medicine) <= 1)
		to_chat(user, "<span class='warning'>I don't know how to use this.</span>")
		return ..()
	if(istype(I, /obj/item/bodypart) || istype(I, /obj/item/stack/teeth)) // I don't fucking care. You can waste an entire stack of teeth for all I care.
		var/obj/item/bodypart/BI = I
		to_chat(user, "<span class='info'>I put \the [BI] into the [src].</span>")
		playsound(get_turf(user), 'sound/foley/struggle.ogg', 100, FALSE, -2)
		BI.forceMove(src)
		bp = BI
		return
	if(istype(I, /obj/item/reagent_containers/glass/bottle/rogue))
		var/obj/item/reagent_containers/glass/bottle/rogue/bootle = I
		to_chat(user, "<span class='info'>I attach \the [bootle] into the [src].</span>")
		playsound(get_turf(user), 'sound/foley/torchfixtureput.ogg', 100, FALSE, -2)
		bootle.forceMove(src)
		pot = bootle
		return

// MEDICINE

// SMONKAID

/datum/reagent/smonkium
	name = "Smonkium"
	description = ""
	color = "#505050"
	overdose_threshold = 0
	metabolization_rate = 0.2
	taste_description = "...smoke?"

/datum/reagent/smonkium/on_mob_life(mob/living/carbon/M)
	if(prob(1))
		M.flash_fullscreen("whiteflash")
	M.apply_status_effect(/datum/status_effect/buff/smonkium)
	..()

// OZ

/datum/reagent/ozium
	name = "Ozium"
	description = ""
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 0
	metabolization_rate = 0.2
	taste_description = "beautiful things"

/datum/reagent/ozium/on_mob_metabolize(mob/living/L)
	. = ..()
	L.flash_fullscreen("can_you_see")

/datum/reagent/ozium/on_mob_life(mob/living/carbon/M)
	if(prob(20))
		M.flash_fullscreen("whiteflash")
	M.apply_status_effect(/datum/status_effect/buff/ozium)
	..()

// DUST OF MOON

/datum/reagent/moondust
	name = "Moondustis"
	description = ""
	color = "#ffffff"
	overdose_threshold = 0
	metabolization_rate = 0.2
	taste_description = "moondustits"

/datum/reagent/moondust/on_mob_metabolize(mob/living/M)
	M.flash_fullscreen("can_you_see")
	animate(M.client, pixel_y = 1, time = 1, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -1, time = 1, flags = ANIMATION_RELATIVE)

/datum/reagent/moondust/on_mob_end_metabolize(mob/living/M)
	animate(M.client)

/datum/reagent/moondust/on_mob_life(mob/living/carbon/M)
	if(M.reagents.has_reagent(/datum/reagent/moondust_purest))
		M.Sleeping(40, 0)
	if(M.has_flaw(/datum/charflaw/addiction/junkie))
		M.sate_addiction()
	M.apply_status_effect(/datum/status_effect/buff/moondust)
	if(prob(10))
		M.flash_fullscreen("whiteflash")
	..()

// LOVE

/datum/reagent/druqks
	name = "Drukqs"
	description = ""
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 0
	metabolization_rate = 0.2
	taste_description = "Love"

/datum/reagent/druqks/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(30)
	if(prob(5))
		if(M.gender == FEMALE)
			M.emote(pick("twitch_s","giggle"))
		else
			M.emote(pick("twitch_s","chuckle"))
	if(M.has_flaw(/datum/charflaw/addiction/junkie))
		M.sate_addiction()
	M.apply_status_effect(/datum/status_effect/buff/druqks)
	..()

/datum/reagent/druqks/on_mob_metabolize(mob/living/M)
	M.overlay_fullscreen("druqk", /atom/movable/screen/fullscreen/druqks)
	M.set_drugginess(30)
	M.update_body_parts_head_only()
	if(M.client)
		ADD_TRAIT(M, TRAIT_DRUQK, "based")
		SSdroning.area_entered(get_area(M), M.client)
//			if(M.client.screen && M.client.screen.len)
//				var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in M.client.screen
//				PM.backdrop(M.client.mob)

/datum/reagent/druqks/on_mob_end_metabolize(mob/living/M)
	M.clear_fullscreen("druqk")
	M.update_body_parts_head_only()
	if(M.client)
		REMOVE_TRAIT(M, TRAIT_DRUQK, "based")
		SSdroning.play_area_sound(get_area(M), M.client)
//		if(M.client.screen && M.client.screen.len)
///			var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in M.client.screen
//			PM.backdrop(M.client.mob)

// ADRENALINEN

/datum/reagent/adrenalinen
	name = "Adrenalinen"
	description = ""
	color = "#827979ff" // rgb: 96, 165, 132
	overdose_threshold = 0
	metabolization_rate = 1.5
	taste_description = "mushroomy goodness"

/datum/reagent/adrenalinen/on_mob_life(mob/living/carbon/M)
	M.apply_status_effect(/datum/status_effect/buff/adrenaline, -1)
	..()

/datum/reagent/adrenalinen/on_mob_end_metabolize(mob/living/M)
	M.remove_status_effect(/datum/status_effect/buff/adrenaline)
	..()

/datum/reagent/coagulationium
	name = "Coagulationium"
	description = ""
	color = "#949b5aff"
	overdose_threshold = 0
	metabolization_rate = 1.5
	taste_description = "weirdly enough, blood"

/datum/reagent/adrenalinen/on_mob_life(mob/living/carbon/M)
	ADD_TRAIT(M, TRAIT_BLOODLOSS_IMMUNE, type)
	..()

/datum/reagent/adrenalinen/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_BLOODLOSS_IMMUNE, type)
	..()