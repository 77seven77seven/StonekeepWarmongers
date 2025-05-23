#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

//Barricades/cover

/obj/structure/barricade
	name = "chest high wall"
	desc = ""
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	var/proj_pass_rate = 50 //How many projectiles will pass the cover. Lower means stronger cover
	var/bar_material = METAL

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		make_debris()
	qdel(src)

/obj/structure/barricade/proc/make_debris()
	return

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WELDER && user.used_intent.type != INTENT_HARM && bar_material == METAL)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>I begin repairing [src]...</span>")
			if(I.use_tool(src, user, 40, volume=40))
				obj_integrity = CLAMP(obj_integrity + 20, 0, max_integrity)
	else
		return ..()

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target)//So bullets will fly over and stuff.
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return 1
	else if(istype(mover, /obj/projectile))
		if(!anchored)
			return 1
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return 1
		if(prob(proj_pass_rate))
			return 1
		return 0
	else
		return !density

/////BARRICADE TYPES///////

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = ""
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	bar_material = WOOD
	var/drop_amount = 3

/obj/structure/barricade/wooden/rogue
	name = "wooden barricade"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "woodenbarricade_r"
	max_integrity = 60
	proj_pass_rate = 70
	bar_material = WOOD
	drop_amount = 0

/obj/item/rogue/sandbagkit
	name = "kit of sand bags"
	desc = "Bags of sand meant to be built to cover your sorry face."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "sandbag"
	dropshrink = 0.8
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/rogue/sandbagkit/attack_right(mob/user)
	. = ..()
	var/turf/T = get_turf(src)
	if(!isfloorturf(T))
		to_chat(user, "<span class='warning'>I need ground to plant this on!</span>")
		return
	for(var/obj/A in T)
		if(istype(A, /obj/structure))
			to_chat(user, "<span class='warning'>I need some free space to deploy a [src] here!</span>")
			return
		if(A.density && !(A.flags_1 & ON_BORDER_1))
			to_chat(user, "<span class='warning'>There is already something here!</span>")
			return
	to_chat(user, "<span class='notice'>I begin deploying \the [src].</span>")
	if(do_after(user, 5 SECONDS, TRUE, src))
		var/obj/structure/barricade/sandbags/rogue/sb = new(T)
		sb.dir = user.dir
		qdel(src)

/obj/structure/barricade/sandbags/rogue
	name = "sand bags"
	gender = PLURAL
	desc = "Bags of sand meant to cover your sorry face."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "sandbags"
	max_integrity = 50
	proj_pass_rate = 15
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	climbable = TRUE
	climb_time = 5 SECONDS
	climb_offset = -5
	smooth = SMOOTH_FALSE
	canSmoothWith = list()
	attacked_sound = 'sound/foley/cloth_rip.ogg'
	break_sound = 'sound/foley/cloth_rip.ogg'
	bar_material = SAND

/obj/structure/barricade/sandbags/rogue/CanPass(atom/movable/mover, turf/target)
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return 1
	if(istype(mover, /obj/projectile))
		if(!anchored)
			return 1
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return 1
		if(prob(proj_pass_rate))
			return 1
		return 0
	else
		if(get_dir(loc, target) == dir)
			return !density
	return 1

/obj/structure/barricade/sandbags/rogue/obj_break(damage_flag)
	new /obj/item/rogue/sandbagkit(get_turf(src))
	. = ..()

/obj/structure/barricade/wooden/rogue/crude
	name = "crude plank barricade"
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "woodenbarricade_r2"
	proj_pass_rate = 90
	max_integrity = 40

/obj/structure/barricade/wooden/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/W = I
		if(W.amount < 5)
			to_chat(user, "<span class='warning'>I need at least five wooden planks to make a wall!</span>")
			return
		else
			to_chat(user, "<span class='notice'>I start adding [I] to [src]...</span>")
			if(do_after(user, 50, target=src))
				W.use(5)
				var/turf/T = get_turf(src)
				T.PlaceOnTop(/turf/closed/wall/mineral/wood/nonmetal)
				qdel(src)
				return
	return ..()


/obj/structure/barricade/wooden/crude
	name = "crude plank barricade"
	desc = ""
	icon_state = "woodenbarricade-old"
	drop_amount = 1
	max_integrity = 50
	proj_pass_rate = 65

/obj/structure/barricade/wooden/crude/snow
	desc = ""
	icon_state = "woodenbarricade-snow-old"
	max_integrity = 75

/obj/structure/barricade/wooden/make_debris()
	new /obj/item/stack/sheet/mineral/wood(get_turf(src), drop_amount)


/obj/structure/barricade/sandbags
	name = "sandbags"
	desc = ""
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags = LETPASSTHROW
	bar_material = SAND
	climbable = TRUE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/barricade/sandbags, /turf/closed/wall, /turf/closed/wall/r_wall, /obj/structure/falsewall, /obj/structure/falsewall/reinforced, /turf/closed/wall/rust, /turf/closed/wall/r_wall/rust, /obj/structure/barricade/security)

/obj/structure/barricade/security
	name = "security barrier"
	desc = ""
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	density = FALSE
	anchored = FALSE
	max_integrity = 180
	proj_pass_rate = 20
	armor = list("melee" = 10, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 10, "acid" = 0)

	var/deploy_time = 40
	var/deploy_message = TRUE


/obj/structure/barricade/security/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(deploy)), deploy_time)

/obj/structure/barricade/security/proc/deploy()
	icon_state = "barrier1"
	density = TRUE
	anchored = TRUE
	if(deploy_message)
		visible_message("<span class='warning'>[src] deploys!</span>")


/obj/item/grenade/barrier
	name = "barrier grenade"
	desc = ""
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	item_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = SINGLE

/obj/item/grenade/barrier/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to toggle modes.</span>"

/obj/item/grenade/barrier/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	toggle_mode(user)

/obj/item/grenade/barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if(SINGLE)
			mode = VERTICAL
		if(VERTICAL)
			mode = HORIZONTAL
		if(HORIZONTAL)
			mode = SINGLE

	to_chat(user, "<span class='notice'>[src] is now in [mode] mode.</span>")

/obj/item/grenade/barrier/prime()
	new /obj/structure/barricade/security(get_turf(src.loc))
	switch(mode)
		if(VERTICAL)
			var/target_turf = get_step(src, NORTH)
			if(!(is_blocked_turf(target_turf)))
				new /obj/structure/barricade/security(target_turf)

			var/target_turf2 = get_step(src, SOUTH)
			if(!(is_blocked_turf(target_turf2)))
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/target_turf = get_step(src, EAST)
			if(!(is_blocked_turf(target_turf)))
				new /obj/structure/barricade/security(target_turf)

			var/target_turf2 = get_step(src, WEST)
			if(!(is_blocked_turf(target_turf2)))
				new /obj/structure/barricade/security(target_turf2)
	qdel(src)

/obj/item/grenade/barrier/ui_action_click(mob/user)
	toggle_mode(user)


#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND
