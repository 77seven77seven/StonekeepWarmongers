/obj/item/rogue/bomb
	name = "bomb"
	desc = "Dangerous explosion."
	icon_state = "grenade"
	icon = 'icons/roguetown/items/misc.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	//dropshrink = 0
	throwforce = 0
	slot_flags = ITEM_SLOT_HIP
	throw_speed = 0.95

	var/impact = FALSE // is impact bomb, explodes on impact
	var/use_arm = FALSE // use in hand to arm

	var/light_impact = 4
	var/flame_impact = 0
	var/heavy_impact = 2
	var/fuze = 40 // deciseconds, not seconds. 40 deciseconds is 4 seconds.
	var/lit = FALSE
	var/prob2fail = 0

/obj/item/rogue/bomb/examine(mob/user)
	. = ..()
	if(fuze && !lit)
		. += "<span class='tutorial'>The fuze is set for [fuze/10] seconds.</span>"
	if(impact)
		. += "<span class='tutorial'>It is an impact bomb. It will explode when it hits something.</span>"
	if(use_arm)
		. += "<span class='tutorial'>You can click this one to arm it without a fire source.</span>"
	
/obj/item/rogue/bomb/attack_self(mob/user)
	. = ..()
	if(use_arm)
		light()
		to_chat(user, "<span class='notice'>You arm \the [src]!</span>")
	else
		to_chat(user, "<span class='danger'>This bomb needs to be lit by a fire source!</span>")

/obj/item/rogue/bomb/Crossed(atom/movable/AM, oldloc)
	if(ishuman(AM))
		if(lit)
			explode()
	return ..()

/obj/item/rogue/bomb/spark_act()
	light()

/obj/item/rogue/bomb/fire_act()
	light()

/obj/item/rogue/bomb/ex_act()
	if(!QDELETED(src))
		lit = TRUE
		explode(TRUE)

/obj/item/rogue/bomb/proc/light()
	if(!lit)
		START_PROCESSING(SSfastprocess, src)
		icon_state = "[initial(icon_state)]-lit"
		lit = TRUE
		playsound(src.loc, 'sound/items/firelight.ogg', 100)
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_hands()

/obj/item/rogue/bomb/extinguish()
	snuff()

/obj/item/rogue/bomb/proc/snuff()
	if(lit)
		lit = FALSE
		STOP_PROCESSING(SSfastprocess, src)
		playsound(src.loc, 'sound/items/firesnuff.ogg', 100)
		icon_state = initial(icon_state)
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_hands()

/obj/item/rogue/bomb/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(istype(hit_atom, /turf/open/transparent/openspace))
		forceMove(get_step_multiz(get_turf(src),DOWN))
	if(impact)
		explode()

/obj/item/rogue/bomb/process()
	fuze--
	if(fuze <= 0)
		explode(TRUE)

/obj/item/rogue/bomb/proc/explode(skipprob)
	STOP_PROCESSING(SSfastprocess, src)
	var/turf/T = get_turf(src)
	if(T)
		if(lit)
			if(!skipprob && prob(prob2fail))
				snuff()
			else
				explosion(T, heavy_impact_range = heavy_impact, light_impact_range = light_impact, flame_range = flame_impact, smoke = TRUE, soundin = pick('sound/misc/explode/bottlebomb (1).ogg','sound/misc/explode/bottlebomb (2).ogg','sound/misc/explode/bottlebomb (3).ogg'))
				new /obj/item/shard (T)
				new /obj/effect/decal/cleanable/glass(T)
		else
			if(prob(prob2fail))
				snuff()
			else
				playsound(T, 'sound/items/firesnuff.ogg', 100)
				new /obj/item/shard (T)
				new /obj/effect/decal/cleanable/glass(T)
	qdel(src)

// SMOKE BOMB, SMOKES

/obj/item/rogue/bomb/smoke
	name = "smoke bomb"
	desc = "Popping a smoke! A very experimental grenade. I'm sure you can find uses for it though."
	icon_state = "smoke_bomb"
	impact = TRUE
	use_arm = TRUE

	fuze = 25
	light_impact = 0
	flame_impact = 0

/obj/item/rogue/bomb/smoke/process()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	return

/obj/item/rogue/bomb/smoke/explode(skipprob)
	STOP_PROCESSING(SSfastprocess, src)
	var/turf/T = get_turf(src)
	if(T)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(4, src)
		smoke.start()
		playsound(src.loc, 'sound/combat/smoke.ogg', 100, FALSE, 5, 5)
		qdel(smoke)
		new /obj/item/shard (T)
		new /obj/effect/decal/cleanable/glass(T)
	qdel(src)

// GAS BOMBS, POISON BOMBS

/obj/item/rogue/bomb/poison
	name = "poison bomb"
	desc = "Vile brimstone powder mixed with barkenpowder inside a ceramic coating, heat over fire to begin an exothermic reaction gradually increasing pressure until releasing poisonous smoke."
	icon_state = "poison_bomb"
	impact = FALSE
	use_arm = TRUE

	fuze = 30

/obj/item/rogue/bomb/poison/explode(skipprob)
	STOP_PROCESSING(SSfastprocess, src)
	var/turf/T = get_turf(src)
	if(T)
		var/datum/effect_system/smoke_spread/bad/smoke = new
		smoke.set_up(3, src)
		smoke.start()
		playsound(src.loc, 'sound/combat/smoke.ogg', 100, FALSE, 5, 5)
		qdel(smoke)
		new /obj/item/shard (T)
		new /obj/effect/decal/cleanable/glass(T)
	qdel(src)

// FIRE BOMBS

/obj/item/rogue/bomb/fire
	name = "fire bomb"
	desc = "Dangerous fire in a coating of sorts. Dangerous!"
	icon_state = "firebomb"

	impact = FALSE
	use_arm = TRUE

	fuze = 25
	light_impact = 2
	heavy_impact = 0
	flame_impact = 5

/obj/item/rogue/bomb/fire/explode(skipprob)
	STOP_PROCESSING(SSfastprocess, src)
	var/turf/T = get_turf(src)
	if(T)
		if(lit)
			if(!skipprob && prob(prob2fail))
				snuff()
			else
				explosion(T, light_impact_range = light_impact, flame_range = flame_impact, smoke = TRUE, soundin = pick('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg'))
				new /obj/item/shard (T)
				new /obj/effect/decal/cleanable/glass(T)
		else
			if(prob(prob2fail))
				snuff()
			else
				playsound(T, 'sound/items/firesnuff.ogg', 100)
				new /obj/item/shard (T)
				new /obj/effect/decal/cleanable/glass(T)
	qdel(src)

// MOLOTOVS, MOLLIES, FIREWATER, COCKTAIL

/obj/item/rogue/bomb/mollie
	name = "firewater cocktail"
	desc = "Tar-black sludge made to spread fire, bottled up and stuffed with a rag."
	icon = 'icons/roguetown/items/cooking.dmi'
	icon_state = "clearbomb"

	impact = TRUE
	use_arm = FALSE

	fuze = 30

	light_impact = 1
	heavy_impact = 0
	flame_impact = 3

/obj/item/rogue/bomb/mollie/explode(skipprob)
	STOP_PROCESSING(SSfastprocess, src)
	var/turf/T = get_turf(src)
	if(T)
		if(lit)
			if(!skipprob && prob(prob2fail))
				snuff()
			else
				explosion(T, light_impact_range = light_impact, flame_range = flame_impact, soundin = pick('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg'))
				new /obj/item/shard (T)
				new /obj/effect/decal/cleanable/glass(T)
		else
			if(prob(prob2fail))
				snuff()
			else
				playsound(T, 'sound/items/firesnuff.ogg', 100)
				new /obj/item/shard (T)
				new /obj/effect/decal/cleanable/glass(T)
	qdel(src)