/obj/item/ammo_casing/caseless/rogue/bolt
	name = "bolt"
	desc = "A small and sturdy bolt, with simple plume and metal tip, alongside a groove to load onto a crossbow."
	projectile_type = /obj/projectile/bullet/reusable/bolt
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/thrust)
	caliber = "regbolt"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt"
	dropshrink = 0.8
	max_integrity = 10
	force = 10

/obj/projectile/bullet/reusable/bolt
	name = "bolt"
	desc = "A small and sturdy bolt, with simple plume and metal tip, alongside a groove to load onto a crossbow."
	damage = 50
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bolt
	range = 30
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	embedchance = 100
	armor_penetration = 50
	woundclass = BCLASS_STAB
	flag = "bullet"
	speed = 0.3
	accuracy = 85 //Crossbows have higher accuracy

/obj/item/ammo_casing/caseless/rogue/bolt/poison
	name = "poison bolt"
	desc = "A bolt dipped with a potent poison."
	projectile_type = /obj/projectile/bullet/reusable/bolt/poison
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/thrust)
	caliber = "regbolt"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_poison"
	dropshrink = 0.8
	max_integrity = 10
	force = 10

/obj/projectile/bullet/reusable/bolt/poison
	name = "poison bolt"
	desc = "A bolt dipped with a potent poison."
	damage = 35
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "boltpoison_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bolt
	range = 15
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	embedchance = 100
	woundclass = BCLASS_STAB
	flag = "bullet"
	speed = 0.3
	var/piercing = FALSE

/obj/projectile/bullet/reusable/bolt/poison/Initialize()
	. = ..()
	create_reagents(50, NO_REACT)

/obj/projectile/bullet/reusable/bolt/poison/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(null, FALSE, def_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.reaction(M, INJECT)
				reagents.trans_to(M, reagents.total_volume)
				return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message("<span class='danger'>\The [src] was deflected!</span>", \
									   "<span class='danger'>My armor protected me against \the [src]!</span>")

	..(target, blocked)
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	return BULLET_ACT_HIT

/obj/projectile/bullet/reusable/bolt/poison/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/berrypoison, 3)

/obj/item/ammo_casing/caseless/rogue/bolt/pyro
	name = "pyroclastic bolt"
	desc = "A bolt smeared with a flammable tincture."
	projectile_type = /obj/projectile/bullet/bolt/pyro
	possible_item_intents = list(/datum/intent/mace/strike)
	caliber = "regbolt"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_pyroclastic"
	dropshrink = 0.8
	max_integrity = 10
	force = 10

/obj/projectile/bullet/bolt/pyro
	name = "pyroclastic bolt"
	desc = "A bolt smeared with a flammable tincture."
	damage = 20
	damage_type = BURN
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "boltpyro_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bolt
	range = 15
	hitsound = 'sound/blank.ogg'
	embedchance = 0
	woundclass = BCLASS_BLUNT
	flag = "bullet"
	speed = 0.3

	var/explode_sound = list('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg')

    //explosion values
	var/exp_heavy = 0
	var/exp_light = 0
	var/exp_flash = 0
	var/exp_fire = 1

/obj/projectile/bullet/bolt/pyro/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(3)
//		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, my at about 65 damage if you stop drop and roll immediately

/obj/item/ammo_casing/caseless/rogue/arrow
	name = "arrow"
	desc = "A fletched projectile, with simple plumes and metal tip."
	projectile_type = /obj/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow"
	force = 20
	dropshrink = 0.8
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/thrust)
	max_integrity = 20

/obj/projectile/bullet/reusable/arrow
	name = "arrow"
	desc = "A fletched projectile, with simple plumes and metal tip."
	damage = 40
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/arrow
	range = 30
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	embedchance = 100
	armor_penetration = 25
	woundclass = BCLASS_STAB
	flag = "bullet"
	speed = 0.4

// Weaker version of arrow projectile because handmade and brittle, but still decent to hunt with.
/obj/projectile/bullet/reusable/arrow/stone
	damage = 30
	ammo_type = /obj/item/ammo_casing/caseless/rogue/arrow/stone
	embedchance = 80
	armor_penetration = 40

/obj/projectile/bullet/reusable/arrow/poison
	name = "poison arrow"
	desc = "An arrow with it's tip drenched in a powerful poison."
	damage = 20
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrowpoison_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/arrow
	range = 15
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	embedchance = 100
	woundclass = BCLASS_STAB
	flag = "bullet"
	speed = 0.4
	var/piercing = FALSE

/obj/item/ammo_casing/caseless/rogue/arrow/poison
	name = "poison arrow"
	desc = "An arrow with it's tip drenched in a powerful poison."
	projectile_type = /obj/projectile/bullet/reusable/arrow/poison
	caliber = "arrow"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_poison"
	force = 20
	dropshrink = 0.8
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/thrust)
	max_integrity = 20

/obj/projectile/bullet/reusable/arrow/poison/Initialize()
	. = ..()
	create_reagents(50, NO_REACT)

/obj/projectile/bullet/reusable/arrow/poison/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(null, FALSE, def_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.reaction(M, INJECT)
				reagents.trans_to(M, reagents.total_volume)
				return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message("<span class='danger'>\The [src] was deflected!</span>", \
									   "<span class='danger'>My armor protected me against \the [src]!</span>")

	..(target, blocked)
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	return BULLET_ACT_HIT

/obj/projectile/bullet/reusable/arrow/poison/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/berrypoison, 3)

/obj/item/ammo_casing/caseless/rogue/arrow/pyro
	name = "pyroclastic arrow"
	desc = "An arrow with it's tip drenched in a flammable tincture."
	projectile_type = /obj/projectile/bullet/arrow/pyro
	possible_item_intents = list(/datum/intent/mace/strike)
	caliber = "arrow"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_pyroclastic"
	dropshrink = 0.8
	max_integrity = 10
	force = 10

/obj/projectile/bullet/arrow/pyro
	name = "pyroclatic arrow"
	desc = "An arrow with it's tip drenched in a flammable tincture."
	damage = 15
	damage_type = BURN
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrowpyro_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/arrow
	range = 15
	hitsound = 'sound/blank.ogg'
	embedchance = 0
	woundclass = BCLASS_BLUNT
	flag = "bullet"
	speed = 0.4

	var/explode_sound = list('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg')

    //explosion values
	var/exp_heavy = 0
	var/exp_light = 0
	var/exp_flash = 0
	var/exp_fire = 1

/obj/projectile/bullet/arrow/pyro/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(6)
//		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, my at about 65 damage if you stop drop and roll immediately
	var/turf/T
	if(isturf(target))
		T = target
	else
		T = get_turf(target)
	explosion(T, -1, exp_heavy, exp_light, exp_flash, 0, flame_range = exp_fire, soundin = explode_sound)

/obj/item/ammo_casing/caseless/rogue/arrow/stone
	name = "stone arrow"
	icon_state = "stonearrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/stone //weaker projectile
	max_integrity = 5

/obj/projectile/bullet/reusable/bullet
	name = "lead ball"
	desc = "A round lead shot, simple and spherical."
	damage = 140
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bullet
	range = 50
	jitter = 5
	eyeblur = 3
	immobilize = 1
	hitsound = 'sound/combat/hits/hi_bolt (2).ogg'
	embedchance = 100
	woundclass = BCLASS_STAB
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	flag = "bullet"
	armor_penetration = 75
	speed = 0.1
	accuracy = 75

/obj/projectile/bullet/reusable/bullet/wood
	damage = 35
	armor_penetration = 30

/obj/projectile/bullet/reusable/bullet/iron
	damage = 65
	armor_penetration = 90

/obj/projectile/bullet/fragment
	name = "fragment"
	desc = "Haha. You're not able to see this!"
	damage = 10
	damage_type = BRUTE
	woundclass = BCLASS_STAB
	range = 50
	jitter = 5
	eyeblur = 3
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "woodenball_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bullet/wood
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	flag = "bullet"
	armor_penetration = 40
	speed = 1.5

/obj/item/ammo_casing/caseless/rogue/bullet
	name = "lead ball"
	desc = "A round lead shot, simple and spherical."
	projectile_type = /obj/projectile/bullet/reusable/bullet
	caliber = "musketball"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball"
	dropshrink = 0.5
	possible_item_intents = list(/datum/intent/use)
	max_integrity = 0
	force = 20

/obj/item/ammo_casing/caseless/rogue/bullet/iron
	name = "iron ball"
	desc = "A round iron shot, simple and spherical. Not as malleable as lead though."
	projectile_type = /obj/projectile/bullet/reusable/bullet/iron

/obj/item/ammo_casing/caseless/rogue/bullet/wood
	name = "wooden ball"
	desc = "A small wooden ball. You're the biggest fucking idiot I have ever heard of. But it does shatter when it's fired, so that's something."
	icon_state = "woodenball"
	pellets = 7
	variance = 25
	projectile_type = /obj/projectile/bullet/fragment

/obj/projectile/sanctiflux
	name = "sanctiflux"
	desc = "Oh shit."
	damage = 300
	damage_type = BURN
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "gourd"
	range = 999
	hitsound = 'sound/combat/hits/hi_bolt (2).ogg'
	spread = 0
	woundclass = BCLASS_SMASH
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	flag = "bullet"
	hitscan = FALSE
	armor_penetration = 100
	speed = 0.8

/obj/projectile/sanctiflux/on_hit(atom/target,blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.fire_act(20, 40)
	explosion(target, light_impact_range = 5, flame_range = 7, smoke = TRUE, soundin = pick('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg'))
	..(target, blocked)

/obj/projectile/bullet/reusable/cannonball
	name = "large lead ball"
	desc = "A round lead ball. Complex and still spherical."
	damage = 300
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj" // No one sees it anyway. I think.
	ammo_type = /obj/item/ammo_casing/caseless/rogue/cball
	range = 999
	jitter = 5
	stun = 1
	hitsound = 'sound/combat/hits/hi_bolt (2).ogg'
	embedchance = 0
	dismemberment = 300
	spread = 0
	woundclass = BCLASS_SMASH
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	flag = "bullet"
	hitscan = FALSE
	armor_penetration = 100
	speed = 0.8

/obj/projectile/bullet/reusable/cannonball/on_hit(atom/target,blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message("<span class='danger'>[M] explodes into a shower of gibs!</span>")
		M.gib()
	explosion(get_turf(target), heavy_impact_range = 4, light_impact_range = 6, flame_range = 0, smoke = TRUE, soundin = pick('sound/misc/explode/bottlebomb (1).ogg','sound/misc/explode/bottlebomb (2).ogg'))
	..(target, blocked)

/obj/item/ammo_casing/caseless/rogue/cball
	name = "large lead ball"
	desc = "A round lead ball. Complex and still spherical."
	icon = 'icons/roguetown/weapons/ammo.dmi'
	projectile_type = /obj/projectile/bullet/reusable/cannonball
	icon_state = "cball"
	caliber = "cannoball"
	possible_item_intents = list(/datum/intent/use)
	max_integrity = 100
	randomspread = 0
	variance = 0
	force = 20