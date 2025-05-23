/*
	Items, Structures, Machines
*/


//
// Items
//

/obj/item/holo
	damtype = STAMINA

/obj/item/holo/esword
	name = "holographic energy sword"
	desc = ""
	icon = 'icons/obj/transforming_energy.dmi'
	icon_state = "sword0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 3.0
	throw_speed = 2
	throw_range = 5
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	hitsound = "swing_hit"
	armor_penetration = 50
	var/active = 0
	var/saber_color

/obj/item/holo/esword/green/Initialize()
	. = ..()
	saber_color = "green"

/obj/item/holo/esword/red/Initialize()
	. = ..()
	saber_color = "red"

/obj/item/holo/esword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/holo/esword/attack(target as mob, mob/user as mob)
	..()

/obj/item/holo/esword/Initialize()
	. = ..()
	saber_color = pick("red","blue","green","purple")

/obj/item/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if (active)
		force = 30
		icon_state = "sword[saber_color]"
		w_class = WEIGHT_CLASS_BULKY
		hitsound = 'sound/blank.ogg'
		playsound(user, 'sound/blank.ogg', 20, TRUE)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL
		hitsound = "swing_hit"
		playsound(user, 'sound/blank.ogg', 20, TRUE)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	return

//BASKETBALL OBJECTS

/obj/item/toy/beach_ball/holoball
	name = "basketball"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "basketball"
	item_state = "basketball"
	desc = ""
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/toy/beach_ball/holoball/dodgeball
	name = "dodgeball"
	icon_state = "dodgeball"
	item_state = "dodgeball"
	desc = ""

/obj/item/toy/beach_ball/holoball/dodgeball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/M = hit_atom
		playsound(src, 'sound/blank.ogg', 50, TRUE)
		M.apply_damage(10, STAMINA)
		if(prob(5))
			M.Paralyze(60)
			visible_message("<span class='danger'>[M] is knocked right off [M.p_their()] feet!</span>")

//
// Structures
//

/obj/structure/holohoop
	name = "basketball hoop"
	desc = ""
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE

/obj/structure/holohoop/attackby(obj/item/W as obj, mob/user as mob, params)
	if(get_dist(src,user)<2)
		if(user.transferItemToLoc(W, drop_location()))
			visible_message("<span class='warning'>[user] dunks [W] into \the [src]!</span>")

/obj/structure/holohoop/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(user.pulling && user.used_intent.type == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>I need a better grip to do that!</span>")
			return
		L.forceMove(loc)
		L.Paralyze(100)
		visible_message("<span class='danger'>[user] dunks [L] into \the [src]!</span>")
		user.stop_pulling()
	else
		..()

/obj/structure/holohoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if (isitem(AM) && !istype(AM,/obj/projectile))
		if(prob(50))
			AM.forceMove(get_turf(src))
			visible_message("<span class='warning'>Swish! [AM] lands in [src].</span>")
			return
		else
			visible_message("<span class='danger'>[AM] bounces off of [src]'s rim!</span>")
			return ..()
	else
		return ..()



//
// Machines
//

/obj/machinery/readybutton
	name = "ready declaration device"
	desc = ""
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = FALSE

	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	to_chat(user, "<span class='warning'>The station AI is not to interact with these devices!</span>")
	return

/obj/machinery/readybutton/attack_paw(mob/user as mob)
	to_chat(user, "<span class='warning'>I am too primitive to use this device!</span>")
	return

/obj/machinery/readybutton/attackby(obj/item/W as obj, mob/user as mob, params)
	to_chat(user, "<span class='warning'>The device is a solid button, there's nothing you can do with it!</span>")

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(user.stat || stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>This device is not powered!</span>")
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, "<span class='warning'>The event has already begun!</span>")
		return

	ready = !ready

	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if (button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()

	eventstarted = TRUE

	for(var/obj/structure/window/W in currentarea)
		if(W.flags_1&NODECONSTRUCT_1) // Just in case: only holo-windows
			qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "<span class='danger'>FIGHT!</span>")

/obj/machinery/conveyor/holodeck

/obj/machinery/conveyor/holodeck/attackby(obj/item/I, mob/user, params)
	if(!user.transferItemToLoc(I, drop_location()))
		return ..()

/obj/item/paper/fluff/holodeck/trek_diploma
	name = "paper - Starfleet Academy Diploma"
	info = {"<h2>Starfleet Academy</h2></br><p>Official Diploma</p></br>"}

/obj/item/paper/fluff/holodeck/disclaimer
	name = "Holodeck Disclaimer"
	info = "Bruises sustained in the holodeck can be healed simply by sleeping."
