/obj/item/clothing/accessory //Ties moved to neck slot items, but as there are still things like medals and armbands, this accessory system is being kept as-is
	name = "Accessory"
	desc = ""
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "plasma"
	item_state = ""	//no inhands
	slot_flags = 0
	w_class = WEIGHT_CLASS_SMALL
	var/above_suit = FALSE
	var/minimize_when_attached = TRUE // TRUE if shown as a small icon in corner, FALSE if overlayed
	var/datum/component/storage/detached_pockets
	var/attachment_slot = CHEST

/obj/item/clothing/accessory/proc/can_attach_accessory(obj/item/clothing/suit/U, mob/user)
	if(!attachment_slot || (U && U.body_parts_covered & attachment_slot))
		return TRUE
	if(user)
		to_chat(user, "<span class='warning'>There doesn't seem to be anywhere to put [src]...</span>")

/obj/item/clothing/accessory/proc/attach(obj/item/clothing/suit/U, user)
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(storage)
		if(SEND_SIGNAL(U, COMSIG_CONTAINS_STORAGE))
			return FALSE
		U.TakeComponent(storage)
		detached_pockets = storage
	U.attached_accessory = src
	forceMove(U)
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	if(minimize_when_attached)
		transform *= 0.5	//halve the size so it doesn't overpower the under
		pixel_x += 8
		pixel_y -= 8
	U.add_overlay(src)

	if (islist(U.armor) || isnull(U.armor)) 										// This proc can run before /obj/Initialize has run for U and src,
		U.armor = getArmor(arglist(U.armor))	// we have to check that the armor list has been transformed into a datum before we try to call a proc on it
																					// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if (islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))

	U.armor = U.armor.attachArmor(armor)

	if(isliving(user))
		on_uniform_equip(U, user)

	return TRUE

/obj/item/clothing/accessory/proc/detach(obj/item/clothing/suit/U, user)
	if(detached_pockets && detached_pockets.parent == U)
		TakeComponent(detached_pockets)

	U.armor = U.armor.detachArmor(armor)

	if(isliving(user))
		on_uniform_dropped(U, user)

	if(minimize_when_attached)
		transform *= 2
		pixel_x -= 8
		pixel_y += 8
	layer = initial(layer)
	plane = initial(plane)
	U.cut_overlays()
	U.attached_accessory = null
	U.accessory_overlay = null

/obj/item/clothing/accessory/proc/on_uniform_equip(obj/item/clothing/suit/U, user)
	return

/obj/item/clothing/accessory/proc/on_uniform_dropped(obj/item/clothing/suit/U, user)
	return

/obj/item/clothing/accessory/MiddleClick(mob/user, params)
	if(istype(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		if(initial(above_suit))
			above_suit = !above_suit
			to_chat(user, "[src] will be worn [above_suit ? "above" : "below"] my suit.")

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += "<span class='info'>\The [src] can be attached to a shirt. Middle-click to remove it once attached.</span>"

/obj/item/clothing/accessory/waistcoat
	name = "waistcoat"
	desc = ""
	icon_state = "waistcoat"
	item_state = "waistcoat"
	minimize_when_attached = FALSE
	attachment_slot = null

/obj/item/clothing/accessory/maidapron
	name = "maid apron"
	desc = ""
	icon_state = "maidapron"
	item_state = "maidapron"
	minimize_when_attached = FALSE
	attachment_slot = null

//////////
//Medals//
//////////

/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = ""
	icon_state = "bronze"
	custom_materials = list(/datum/material/iron=1000)
	resistance_flags = FIRE_PROOF
	var/medaltype = "medal" //Sprite used for medalbox
	var/commended = FALSE

//Pinning medals on people
/obj/item/clothing/accessory/medal/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M))

		if(M.wear_armor)
			if((M.wear_armor.flags_inv & HIDEJUMPSUIT)) //Check if the jumpsuit is covered
				to_chat(user, "<span class='warning'>It's all covered up.</span>")
				return

		if(M.wear_shirt)
			var/obj/item/clothing/suit/U = M.wear_shirt
			var/delay = 20
			if(user == M)
				delay = 0
			else
				user.visible_message("<span class='notice'>[user] is trying to pin [src] on [M]'s chest.</span>", \
									 "<span class='notice'>I try to pin [src] on [M]'s chest.</span>")
			var/input
			if(!commended && user != M)
				input = stripped_input(user,"Please input a reason for this award.", ,"", 140)
			if(do_after(user, delay, target = M))
				if(U.attach_accessory(src, user, 0)) //Attach it, do not notify the user of the attachment
					if(user == M)
						to_chat(user, "<span class='notice'>I attach [src] to [U].</span>")
					else
						user.visible_message("<span class='notice'>[user] pins \the [src] on [M]'s chest.</span>", \
											 "<span class='notice'>I pin \the [src] on [M]'s chest.</span>")
						if(input)
							SSblackbox.record_feedback("associative", "commendation", 1, list("commender" = "[user.real_name]", "commendee" = "[M.real_name]", "medal" = "[src]", "reason" = input))
							GLOB.commendations += "[user.real_name] awarded <b>[M.real_name]</b> the <span class='medaltext'>[name]</span>! \n- [input]"
							commended = TRUE
							desc += "<br>The inscription reads: [input] - [user.real_name]"
							log_game("<b>[key_name(M)]</b> was given the following commendation by <b>[key_name(user)]</b>: [input]")
							message_admins("<b>[key_name_admin(M)]</b> was given the following commendation by <b>[key_name_admin(user)]</b>: [input]")

		else
			to_chat(user, "<span class='warning'>Medals can only be pinned on shirts!</span>")
	else
		..()

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = ""

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = ""
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/ribbon
	name = "ribbon"
	desc = ""
	icon_state = "cargo"

/obj/item/clothing/accessory/medal/badmin
	name = "bad conduct medal"

/obj/item/clothing/accessory/medal/ribbon/cargo
	name = "\"cargo tech of the shift\" award"
	desc = ""

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = ""
	icon_state = "silver"
	medaltype = "medal-silver"
	custom_materials = list(/datum/material/silver=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = ""

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = ""

/obj/item/clothing/accessory/medal/silver/veteran
	name = "Sky Veteran medal"
	desc = "A medal for veterans of whom is said they could even beat the Sky in a battle."

/obj/item/clothing/accessory/medal/silver/excellence
	name = "award for outstanding achievement in the field of excellence"
	desc = ""

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = ""
	icon_state = "gold"
	medaltype = "medal-gold"
	custom_materials = list(/datum/material/gold=1000)

/obj/item/clothing/accessory/medal/gold/admin
	name = "humenitarian service medal"

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = ""
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = ""

/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = ""
	icon_state = "plasma"
	medaltype = "medal-plasma"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = -10, "acid" = 0) //It's made of plasma. Of course it's flammable.
	custom_materials = list(/datum/material/plasma=1000)

/obj/item/clothing/accessory/medal/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		atmos_spawn_air("plasma=20;TEMP=[exposed_temperature]")
		visible_message("<span class='danger'>\The [src] bursts into flame!</span>", "<span class='danger'>My [src] bursts into flame!</span>")
		qdel(src)

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nobel sciences award"
	desc = ""



////////////
//Armbands//
////////////

/obj/item/clothing/accessory/armband
	name = "red armband"
	desc = ""
	icon_state = "redband"
	attachment_slot = null

/obj/item/clothing/accessory/armband/deputy
	name = "security deputy armband"
	desc = ""

/obj/item/clothing/accessory/armband/cargo
	name = "cargo bay guard armband"
	desc = ""
	icon_state = "cargoband"

/obj/item/clothing/accessory/armband/engine
	name = "engineering guard armband"
	desc = ""
	icon_state = "engieband"

/obj/item/clothing/accessory/armband/science
	name = "science guard armband"
	desc = ""
	icon_state = "rndband"

/obj/item/clothing/accessory/armband/hydro
	name = "hydroponics guard armband"
	desc = ""
	icon_state = "hydroband"

/obj/item/clothing/accessory/armband/med
	name = "medical guard armband"
	desc = ""
	icon_state = "medband"

/obj/item/clothing/accessory/armband/medblue
	name = "medical guard armband"
	desc = ""
	icon_state = "medblueband"

//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = ""
	icon_state = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/attack_self(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!", forced = "attorney's badge")
	user.visible_message("<span class='notice'>[user] shows [user.p_their()] attorney's badge.</span>", "<span class='notice'>I show my attorney's badge.</span>")

/obj/item/clothing/accessory/lawyers_badge/on_uniform_equip(obj/item/clothing/suit/U, user)
	var/mob/living/L = user
	if(L)
		L.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/on_uniform_dropped(obj/item/clothing/suit/U, user)
	var/mob/living/L = user
	if(L)
		L.bubble_icon = initial(L.bubble_icon)

////////////////
//HA HA! NERD!//
////////////////
/obj/item/clothing/accessory/pocketprotector
	name = "pocket protector"
	desc = ""
	icon_state = "pocketprotector"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/pocketprotector

/obj/item/clothing/accessory/pocketprotector/full/Initialize()
	. = ..()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize()
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

////////////////
//REAL BIG FAN//
////////////////

/obj/item/clothing/accessory/fan_clown_pin
	name = "Clown Pin"
	desc = ""
	icon_state = "fan_clown_pin"
	above_suit = TRUE
	minimize_when_attached = TRUE
	attachment_slot = CHEST

/obj/item/clothing/accessory/fan_clown_pin/on_uniform_equip(obj/item/clothing/suit/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_FAN_CLOWN))
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "fan_clown_pin", /datum/mood_event/fan_clown_pin)

/obj/item/clothing/accessory/fan_clown_pin/on_uniform_dropped(obj/item/clothing/suit/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_FAN_CLOWN))
		SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "fan_clown_pin")

/obj/item/clothing/accessory/fan_mime_pin
	name = "Mime Pin"
	desc = ""
	icon_state = "fan_mime_pin"
	above_suit = TRUE
	minimize_when_attached = TRUE
	attachment_slot = CHEST

/obj/item/clothing/accessory/fan_clown_pin/on_uniform_equip(obj/item/clothing/suit/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_FAN_MIME))
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "fan_mime_pin", /datum/mood_event/fan_mime_pin)

/obj/item/clothing/accessory/fan_clown_pin/on_uniform_dropped(obj/item/clothing/suit/U, user)
	var/mob/living/L = user
	if(HAS_TRAIT(L, TRAIT_FAN_MIME))
		SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "fan_clown_pin")

////////////////
//OONGA BOONGA//
////////////////

/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = ""
	icon_state = "talisman"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25)
	attachment_slot = null

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = ""
	icon_state = "skull"
	above_suit = TRUE
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25)
	attachment_slot = GROIN
