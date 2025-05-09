/obj/effect/spawner/roguemap/Initialize(mapload)
	START_PROCESSING(SSmapgen, src)

/obj/effect/spawner/roguemap
	icon = 'icons/obj/structures_spawners.dmi'
	var/probby = 100
	var/list/spawned

/obj/effect/spawner/roguemap/process()
	if(prob(probby))
		var/obj/new_type = pick(spawned)
		new new_type(get_turf(src))

	STOP_PROCESSING(SSmapgen, src)
	qdel(src)

/obj/effect/spawner/roguemap/pit
	icon_state = "pit"

/obj/effect/spawner/roguemap/pit/process()
	var/turf/T = get_turf(src)
	var/turf/below = get_step_multiz(src, DOWN)
	if(below)
		T.ChangeTurf(/turf/open/transparent/openspace)
		below.ChangeTurf(/turf/open/floor/rogue/dirt/road)

	STOP_PROCESSING(SSmapgen, src)
	qdel(src)


/obj/effect/spawner/roguemap/tree
	icon_state = "tree"
	name = "Tree spawner"
	probby = 80
	spawned = list(/obj/structure/flora/roguetree)

/obj/effect/spawner/roguemap/treeorbush
	icon_state = "Treeorbush"
	name = "Tree or bush spawner"
	probby = 50
	spawned = list(/obj/structure/flora/roguetree, /obj/structure/flora/roguegrass/bush)

/obj/effect/spawner/roguemap/treeorstump
	icon_state = "treeorstump"
	name = "Tree or stump spawner"
	probby = 50
	spawned = list(/obj/structure/flora/roguetree, /obj/structure/table/wood/treestump)

/obj/effect/spawner/roguemap/stump
	icon_state = "stump"
	name = "stump spawner"
	probby = 75
	spawned = list(/obj/structure/table/wood/treestump)

/obj/effect/spawner/roguemap/shroud
	icon_state = "shroud"
	name = "shroud sp"
	probby = 30
	spawned = list(/turf/closed/wall/shroud)

/obj/effect/spawner/roguemap/hauntpile
	icon_state = "hauntpile"
	name = "hauntpile"
	probby = 23
	spawned = list(/obj/structure/bonepile)

/obj/effect/spawner/roguemap/beartrap
	icon_state = "beartrap"
	name = "beartrap"
	probby = 50
	spawned = list(/obj/item/restraints/legcuffs/beartrap/armed/camouflage)

/obj/effect/spawner/roguemap/tallgrass
	icon_state = "grass"
	name = "grass tile loot spawner"
	probby = 75
	spawned = list(/obj/structure/flora/roguegrass/bush = 10, /obj/structure/flora/roguegrass = 60, /obj/item/natural/stone = 8, /obj/item/natural/rock = 7, /obj/item/grown/log/tree/stick = 3, /obj/structure/closet/dirthole/closed/loot=0.1)

/obj/effect/spawner/roguemap/grass_low
	icon_state = "grass"
	name = "grass tile low loot spawner"
	probby = 50
	spawned = list(/obj/structure/flora/roguegrass/bush = 5, /obj/structure/flora/roguegrass = 60, /obj/item/natural/stone = 8, /obj/item/natural/rock = 4, /obj/item/grown/log/tree/stick = 2)

