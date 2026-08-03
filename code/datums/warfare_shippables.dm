/datum/warshippable
	var/name = "shippable"
	var/list/items = list()
	var/reinforcement = 1 // on what wave this becomes available on
	var/faction

/datum/warshippable/smokebombs
	name = "FIVE SMOKE BOMBS"
	items = list(/obj/item/rogue/bomb/smoke,
			/obj/item/rogue/bomb/smoke,
			/obj/item/rogue/bomb/smoke,
			/obj/item/rogue/bomb/smoke,
			/obj/item/rogue/bomb/smoke
			)

/datum/warshippable/gasbombs
	name = "FOUR GAS BOMBS"
	items = list(/obj/item/rogue/bomb/poison,
			/obj/item/rogue/bomb/poison,
			/obj/item/rogue/bomb/poison,
			/obj/item/rogue/bomb/poison
			)

/datum/warshippable/bombs
	name = "FIVE BOMBS"
	items = list(/obj/item/rogue/bomb,
			/obj/item/rogue/bomb,
			/obj/item/rogue/bomb,
			/obj/item/rogue/bomb,
			/obj/item/rogue/bomb
			)

/*
/datum/warshippable/crownpointer
	name = "CROWN POINTER"
	items = list(/obj/item/pinpointer/crown)
*/

/datum/warshippable/firebombs
	name = "THREE FIRE BOMBS"
	items = list(/obj/item/rogue/bomb/fire,
			/obj/item/rogue/bomb/fire,
			/obj/item/rogue/bomb/fire
			)

/datum/warshippable/granatalauncher
	name = "GRANATALAUNCHER"
	items = list(/obj/item/gun/grenadelauncher/granata)

/datum/warshippable/normalammo
	name = "LEAD BALL POUCHES"
	items = list(/obj/item/quiver/bullets,
			/obj/item/quiver/bullets
			)

/datum/warshippable/shotgun_ammo
	name = "HEAVY AMMUNITION POUCHES"
	items = list(/obj/item/quiver/shitgunner,
			/obj/item/quiver/shitgunner
			)

/datum/warshippable/cannonballs
	name = "LARGE LEAD BALLS"
	items = list(/obj/item/ammo_casing/caseless/rogue/cball,
			/obj/item/ammo_casing/caseless/rogue/cball,
			/obj/item/ammo_casing/caseless/rogue/cball,
			/obj/item/ammo_casing/caseless/rogue/cball
			)

/datum/warshippable/healther
	name = "HEALTHER"
	items = list(/obj/structure/healther)

/datum/warshippable/bombard
	name = "BOMBTARD"
	items = list(/obj/structure/bombard)
	faction = RED_WARTEAM

/datum/warshippable/bombard/alt
	name = "MORTARD"
	items = list(/obj/structure/bombard/alt)
	faction = BLUE_WARTEAM

/datum/warshippable/cannon
	name = "BARKSTONE"
	items = list(/obj/structure/cannon)

/datum/warshippable/maxim
	name = "GATLYN'S CRANKBOX"
	items = list(/obj/structure/maxim)
	faction = RED_WARTEAM

/datum/warshippable/maxim/alt
	name = "KAITZAR'S ORGAN"
	items = list(/obj/structure/maxim/alt)
	faction = BLUE_WARTEAM

/datum/warshippable/maxim_ammo
	name = "THREE MACHINE AMMO"
	items = list(/obj/item/rogue/maxim_ammo,
				/obj/item/rogue/maxim_ammo,
				/obj/item/rogue/maxim_ammo)

/datum/warshippable/caltrops
	name = "CALTROPS"
	items = list(/obj/item/rogue/caltrop,
			/obj/item/rogue/caltrop,
			/obj/item/rogue/caltrop
			)

/datum/warshippable/sandbags
	name = "TEN SAND BAGS"
	items = list(/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit,
			/obj/item/rogue/sandbagkit
			)

/datum/warshippable/pistolsword
	name = "FIVE BARKSWORDS"
	items = list(/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded
			)
	faction = RED_WARTEAM

/datum/warshippable/pistolsword/alt
	name = "FIVE BARKSWORDS"
	items = list(/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/alternate,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/alternate,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/alternate,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/alternate,
			/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/alternate
			)
	faction = BLUE_WARTEAM

/datum/warshippable/wood
	name = "WOOD SUPPLIES"
	items = list(/obj/structure/closet/crate/chest/woodsupps)

/obj/structure/closet/crate/chest/woodsupps/PopulateContents()
	for(var/i = 0 to 10)
		new /obj/item/grown/log/tree(src)

/datum/warshippable/stone
	name = "STONE SUPPLIES"
	items = list(/obj/structure/closet/crate/chest/stonesupps)

/obj/structure/closet/crate/chest/stonesupps/PopulateContents()
	for(var/i = 0 to 10)
		new /obj/item/natural/stone(src)

/datum/warshippable/metals
	name = "METALS SUPPLIES"
	items = list(/obj/structure/closet/crate/chest/metalsupps)

/obj/structure/closet/crate/chest/metalsupps/PopulateContents()
	for(var/i = 0 to 6)
		new /obj/item/ingot/steel(src)
		new /obj/item/ingot/iron(src)

/datum/warshippable/explodabarrel
	name = "EXPLODABARRELS"
	items = list(/obj/structure/fluff/explodabarrel,
			/obj/structure/fluff/explodabarrel,
			/obj/structure/fluff/explodabarrel,
			/obj/structure/fluff/explodabarrel,
			/obj/structure/fluff/explodabarrel
			)

/datum/warshippable/surger
	name = "SURGERS BAGS TWO"
	items = list(/obj/item/storage/backpack/rogue/satchel/surgbag,
				/obj/item/storage/backpack/rogue/satchel/surgbag)

/datum/warshippable/bottles
	name = "FIVE BOOTLES"
	items = list(/obj/item/reagent_containers/glass/bottle/rogue,
				/obj/item/reagent_containers/glass/bottle/rogue,
				/obj/item/reagent_containers/glass/bottle/rogue,
				/obj/item/reagent_containers/glass/bottle/rogue,
				/obj/item/reagent_containers/glass/bottle/rogue)

/datum/warshippable/bandages
	name = "FIVE BANDANAGES"
	items = list(/obj/item/natural/cloth,
				/obj/item/natural/cloth,
				/obj/item/natural/cloth,
				/obj/item/natural/cloth,
				/obj/item/natural/cloth)