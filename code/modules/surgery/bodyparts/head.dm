/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = ""
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "default_human_head"
	max_damage = 200
	body_zone = BODY_ZONE_HEAD
	body_part = HEAD
	w_class = WEIGHT_CLASS_NORMAL //Quite a hefty load
	slowdown = 1 //Balancing measure
	throw_range = 2 //No head bowling
	px_x = 0
	px_y = -8
	stam_damage_coeff = 1
	max_stamina_damage = 100
	dismember_wound = /datum/wound/dismemberment/head

	var/mob/living/brain/brainmob = null //The current occupant.
	var/obj/item/organ/brain/brain = null //The brain organ
	var/obj/item/organ/eyes/eyes
	var/obj/item/organ/eyes/eyesl
	var/obj/item/organ/ears/ears
	var/obj/item/organ/tongue/tongue
	var/obj/item/stack/teeth/teeth

	//Limb appearance info:
	var/real_name = "" //Replacement name
	//Hair colour and style
	var/hair_color = "000"
	var/hairstyle = "Bald"
	var/hair_alpha = 255
	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hairstyle = "Shaved"
	//Eye Colouring

	var/lip_style = null
	var/lip_color = "white"

	offset = OFFSET_HEAD
	offset_f = OFFSET_HEAD_F
	//subtargets for crits
	subtargets = list(BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_NOSE, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_SKULL, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_NECK)
	//grabtargets for grabs
	grabtargets = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_NOSE, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_SKULL, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_NECK)
	resistance_flags = FLAMMABLE

	/// Brainkill means that this head is considered dead and revival is impossible
	var/brainkill = FALSE

/obj/item/bodypart/head/grabbedintents(mob/living/user, precise)
	var/used_limb = precise
	switch(used_limb)
		if(BODY_ZONE_HEAD)
			return list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash)
		if(BODY_ZONE_PRECISE_EARS)
			return list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash)
		if(BODY_ZONE_PRECISE_NOSE)
			return list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash)
		if(BODY_ZONE_PRECISE_SKULL)
			return list(/datum/intent/grab/move, /datum/intent/grab/smash)
		if(BODY_ZONE_PRECISE_L_EYE)
			return list(/datum/intent/grab/move, /datum/intent/grab/smash)
		if(BODY_ZONE_PRECISE_R_EYE)
			return list(/datum/intent/grab/move, /datum/intent/grab/smash)
		if(BODY_ZONE_PRECISE_MOUTH)
			return list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash)
		if(BODY_ZONE_PRECISE_NECK)
			return list(/datum/intent/grab/move, /datum/intent/grab/choke)

/obj/item/bodypart/head/Initialize() // stupid? probably.
	..()
	teeth = new /obj/item/stack/teeth/full(src)

/obj/item/bodypart/head/proc/knock_out_teeth(throw_dir, num=24)
	num = CLAMP(num, 1, 24)
	var/done = FALSE
	if(teeth && !teeth.zero_amount()) //We still have teeth
		for(var/d = 1 to num) //Random amount of teeth
			var/obj/item/stack/teeth/toth = teeth.change_stack(amount = 1)
			if(!toth)
				return done
			toth.forceMove(get_turf(owner))
			toth.add_mob_blood(owner)

			playsound(get_turf(owner), "wetbreak", 100, TRUE, -5)
			owner.flash_fullscreen("redflash3")
			owner.emote("painscream")

			var/turf/target = get_turf(owner.loc)
			var/range = rand(1, 3)
			for(var/i = 1; i < range; i++)
				var/turf/new_turf = get_step(target, throw_dir)
				target = new_turf
				if(new_turf.density)
					break
			toth.throw_at(get_edge_target_turf(toth,pick(GLOB.alldirs)),rand(1,3),30)
			toth.loc.add_mob_blood(owner)
			toth.do_knock_out_animation()
			toth.update_transform()

			toth.zero_amount() //Try to delete the teeth
			done = TRUE
	return done

/obj/item/bodypart/head/Destroy()
	QDEL_NULL(brainmob) //order is sensitive, see warning in handle_atom_del() below
	QDEL_NULL(brain)
	QDEL_NULL(eyes)
	QDEL_NULL(ears)
	QDEL_NULL(tongue)
	QDEL_NULL(teeth)
	return ..()

/obj/item/bodypart/head/handle_atom_del(atom/A)
	if(A == brain)
		brain = null
		update_icon_dropped()
		if(!QDELETED(brainmob)) //this shouldn't happen without badminnery.
			message_admins("Brainmob: ([ADMIN_LOOKUPFLW(brainmob)]) was left stranded in [src] at [ADMIN_VERBOSEJMP(src)] without a brain!")
			log_game("Brainmob: ([key_name(brainmob)]) was left stranded in [src] at [AREACOORD(src)] without a brain!")
	if(A == brainmob)
		brainmob = null
	if(A == eyes)
		eyes = null
		update_icon_dropped()
	if(A == ears)
		ears = null
	if(A == tongue)
		tongue = null
	return ..()

/obj/item/bodypart/head/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(T, 'sound/blank.ogg', 50, TRUE, -1)
	for(var/obj/item/I in src)
		if(I == brain)
			if(user)
				user.visible_message("<span class='warning'>[user] saws [src] open and pulls out a brain!</span>", "<span class='notice'>I saw [src] open and pull out a brain.</span>")
			if(brainmob)
				brainmob.container = null
				brainmob.forceMove(brain)
				brain.brainmob = brainmob
				brainmob = null
			if(violent_removal && prob(rand(80, 100))) //ghetto surgery can damage the brain.
				to_chat(user, "<span class='warning'>[brain] was damaged in the process!</span>")
				brain.setOrganDamage(brain.maxHealth)
			brain.forceMove(T)
			brain = null
			update_icon_dropped()
		else
			I.forceMove(T)
	eyes = null
	ears = null
	tongue = null

/obj/item/bodypart/head/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
	else
		C = owner

	real_name = C.real_name
	if(HAS_TRAIT(C, TRAIT_HUSK))
		real_name = "Unknown"
		hairstyle = "Bald"
		facial_hairstyle = "Shaved"
		lip_style = null

	else if(!animal_origin)
		var/mob/living/carbon/human/H = C
		if(!H.dna || !H.dna.species)
			return ..()
		var/datum/species/S = H.dna.species

		//Facial hair
		if(H.facial_hairstyle && (FACEHAIR in S.species_traits))
			facial_hairstyle = H.facial_hairstyle
			if(S.hair_color)
				if(S.hair_color == "mutcolor")
					facial_hair_color = H.dna.features["mcolor"]
				else
					facial_hair_color = S.hair_color
			else
				facial_hair_color = H.facial_hair_color
			hair_alpha = S.hair_alpha
		else
			facial_hairstyle = "Shaved"
			facial_hair_color = "000"
			hair_alpha = 255
		//Hair
		if(H.hairstyle && (HAIR in S.species_traits))
			hairstyle = H.hairstyle
			if(S.hair_color)
				if(S.hair_color == "mutcolor")
					hair_color = H.dna.features["mcolor"]
				else
					hair_color = S.hair_color
			else
				hair_color = H.hair_color
			hair_alpha = S.hair_alpha
		else
			hairstyle = "Bald"
			hair_color = "000"
			hair_alpha = initial(hair_alpha)
		// lipstick
		if(H.lip_style && (LIPS in S.species_traits))
			lip_style = H.lip_style
			lip_color = H.lip_color
		else
			lip_style = null
			lip_color = "white"
	..()

/obj/item/bodypart/head/update_icon_dropped()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)

/obj/item/bodypart/head/get_limb_icon(dropped)
	cut_overlays()
	. = ..()
	if(dropped) //certain overlays only appear when the limb is being detached from its owner.

		if(status != BODYPART_ROBOTIC) //having a robotic head hides certain features.
			//facial hair
			if(facial_hairstyle)
				var/datum/sprite_accessory/S = GLOB.facial_hairstyles_list[facial_hairstyle]
				if(S)
					var/image/facial_overlay = image(S.icon, "[S.icon_state]", -HAIR_LAYER, SOUTH)
					facial_overlay.color = "#" + facial_hair_color
					facial_overlay.alpha = hair_alpha
					. += facial_overlay

			//Applies the debrained overlay if there is no brain
			if(!brain)
				var/image/debrain_overlay = image(layer = -HAIR_LAYER, dir = SOUTH)
				if(animal_origin == ALIEN_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_alien"
				else if(animal_origin == LARVA_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_larva"
				else if(!(NOBLOOD in species_flags_list))
					debrain_overlay.icon = 'icons/mob/human_face.dmi'
					debrain_overlay.icon_state = "debrained"
				. += debrain_overlay
			else
				var/datum/sprite_accessory/S2 = GLOB.hairstyles_list[hairstyle]
				if(S2)
					var/image/hair_overlay = image(S2.icon, "[S2.icon_state]", -HAIR_LAYER, SOUTH)
					hair_overlay.color = "#" + hair_color
					hair_overlay.alpha = hair_alpha
					. += hair_overlay
			//ROGTODO add accessories (earrings, piercings) here

		// lipstick
		if(lip_style)
			var/image/lips_overlay = image('icons/mob/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, SOUTH)
			lips_overlay.color = lip_color
			. += lips_overlay

		// eyes
		var/image/eyes_overlay = image('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER, SOUTH)
		. += eyes_overlay
		if(eyes)
			eyes_overlay.icon_state = eyes.eye_icon_state

			if(eyes.eye_color)
				eyes_overlay.color = "#" + eyes.eye_color

/obj/item/bodypart/head/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_head"
	animal_origin = MONKEY_BODYPART

/obj/item/bodypart/head/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_head"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/head/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/head/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_head"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 50
	animal_origin = LARVA_BODYPART

// teeth

/obj/item/stack/teeth
	name = "teeth"
	singular_name = "tooth"
	desc = "Youchies."
	icon = 'icons/roguetown/items/surgery.dmi'
	icon_state = "tooth_4"
	dropshrink = 0.5
	var/base_icon_state = "tooth"
	max_amount = 24 // i know this isnt realistic but it would be dumb to have so much teeth objects being flung around
	throwforce = 4 // trol
	force = 0
	var/icon_state_variation = 4

/obj/item/stack/teeth/Initialize()
	. = ..()
	if(icon_state_variation >= 1)
		icon_state = "[base_icon_state]_[rand(1, icon_state_variation)]"

/obj/item/stack/teeth/proc/do_knock_out_animation(shrink_time = 5)
	shrink_time = rand(1, shrink_time)
	var/old_transform = matrix(transform)
	transform = transform.Scale(2, 2)
	transform = transform.Turn(rand(0, 360))
	animate(src, transform = old_transform, time = shrink_time)

//many teethe
/obj/item/stack/teeth/full
	amount = 24