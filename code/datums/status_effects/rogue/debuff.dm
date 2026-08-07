/datum/status_effect/debuff
	status_type = STATUS_EFFECT_REFRESH

///////////////////////////

/datum/status_effect/debuff/hungryt1
	id = "hungryt1"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/hungryt1
	affected_stats = list("speed" = -1,"strength" = -1, "constitution" = -1, "endurance" = -1)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/hungryt1
	name = "Peckish, stomach growling"
	desc = "<span class='warning'>I am getting hungry.</span>\n"
	icon_state = "hunger1"

/datum/status_effect/debuff/hungryt1/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/peckish)

/datum/status_effect/debuff/hungryt1/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/peckish)

/datum/status_effect/debuff/hungryt2
	id = "hungryt2"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/hungryt2
	affected_stats = list("speed" = -4,"strength" = -2, "constitution" = -2, "endurance" = -1)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/hungryt2
	name = "Hungry, need food"
	desc = "<span class='warning'>My stomach hurts, I need food.</span>\n"
	icon_state = "hunger2"

/datum/status_effect/debuff/hungryt2/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/hungry)

/datum/status_effect/debuff/hungryt2/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/hungry)

/datum/status_effect/debuff/hungryt3
	id = "hungryt3"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/hungryt3
	affected_stats = list("speed" = -6,"strength" = -6, "constitution" = -6, "endurance" = -6)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/hungryt3
	name = "STARVING"
	desc = "<span class='boldwarning'>I AM STARVING!</span>\n"
	icon_state = "hunger3"

/datum/status_effect/debuff/hungryt3/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/starving)

/datum/status_effect/debuff/hungryt3/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/starving)

//SILVER DAGGER EFFECT

/datum/status_effect/debuff/silver_curse
	id = "silver_curse"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/silver_curse
	duration = 5 SECONDS

/atom/movable/screen/alert/status_effect/debuff/silver_curse
	name = "Silver Curse"
	desc = "My BANE!"
	icon_state = "hunger3"


//BROKEN CELIBACY

/datum/status_effect/debuff/chastity
	id = "chastity"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/chastity
	affected_stats = list("fortune" = -6)
	duration = 999 MINUTES

/atom/movable/screen/alert/status_effect/debuff/chastity
	name = "Pantheons Curse"
	desc = "I have broken my oath of celibacy... what have I done"
	icon_state = "hunger3"

/datum/status_effect/debuff/wiz
	id = "wiz"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/wiz
	affected_stats = list("intelligence" = -5)
	duration = 999 MINUTES

/atom/movable/screen/alert/status_effect/debuff/wiz
	name = "Fading Power"
	desc = "My magical power wanes as I defile my body"
	icon_state = "hunger3"
////////////////////


/datum/status_effect/debuff/thirstyt1
	id = "thirsty1"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/thirstyt1
	affected_stats = list("endurance" = -1, "speed" = -1)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/thirstyt1
	name = "Getting thirsty"
	desc = "<span class='warning'>I could use a drink.</span>\n"
	icon_state = "thirst1"


/datum/status_effect/debuff/thirstyt1/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/drym)

/datum/status_effect/debuff/thirstyt1/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/drym)

/datum/status_effect/debuff/thirstyt2
	id = "thirsty2"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/thirstyt2
	affected_stats = list("speed" = -4, "endurance" = -4)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/thirstyt2
	name = "Extremly thirsty"
	desc = "<span class='warning'>If I don't drink something soon, my mouth will be sand.</span>\n"
	icon_state = "thirst2"

/datum/status_effect/debuff/thirstyt2/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/thirst)

/datum/status_effect/debuff/thirstyt2/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/thirst)

/datum/status_effect/debuff/thirstyt3
	id = "thirsty3"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/thirstyt3
	affected_stats = list("strength" = -6, "speed" = -6, "endurance" = -6)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/thirstyt3
	name = "Extreme Dehydration"
	desc = "<span class='boldwarning'>I AM DYING OF THIRST!</span>\n"
	icon_state = "thirst3"

/datum/status_effect/debuff/thirstyt3/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/parched)

/datum/status_effect/debuff/thirstyt3/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/parched)

/////////

/datum/status_effect/debuff/uncookedfood
	id = "uncookedfood"
	affected_stats = null
	duration = 10 MINUTES
	alert_type = /atom/movable/alert/status_effect/debuff/uncookedfood

/atom/movable/alert/status_effect/debuff/uncookedfood
	name = "Raw Food!"
	desc = "<span class='warning'>Augh! Why didn't I bring that food to fire!?"
	icon_state = "uncookedfood"

/datum/status_effect/debuff/uncookedfood/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_nausea(100)
		C.add_stress(/datum/stressevent/uncookedfood)

/datum/status_effect/debuff/badmeal
	alert_type = /atom/movable/alert/status_effect/debuff/badmeal
	id = "badmeal"
	affected_stats = null
	duration = 10 MINUTES

/atom/movable/alert/status_effect/debuff/badmeal
	name = "Foul Food!"
	desc = "<span class='warning'>That tasted like zcum!"
	icon_state = "badmeal"

/datum/status_effect/debuff/badmeal/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/badmeal)

/datum/status_effect/debuff/burnedfood
	alert_type = /atom/movable/alert/status_effect/debuff/burntmeal
	id = "burnedfood"
	affected_stats = null
	duration = 10 MINUTES

/datum/status_effect/debuff/burnedfood/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/burntmeal)
		C.add_nausea(100)

/atom/movable/alert/status_effect/debuff/burntmeal
	name = "Burnt Food!"
	desc = "<span class='warning'>That tasted like charcoal and cinder!"
	icon_state = "burntmeal"

/datum/status_effect/debuff/rotfood
	alert_type = /atom/movable/alert/status_effect/debuff/rotfood
	id = "rotfood"
	affected_stats = null
	duration = 10 MINUTES

/atom/movable/alert/status_effect/debuff/rotfood
	name = "Rotten Food!"
	desc = "<span class='warning'>MAGGOT-INFESTED BILE RISES TO MY THROAT!"
	icon_state = "burntmeal"

/datum/status_effect/debuff/rotfood/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_nausea(200)
		C.add_stress(/datum/stressevent/rotfood)

/datum/status_effect/debuff/bleeding
	id = "bleedingt1"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/bleedingt1
	affected_stats = list("speed" = -2)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/bleedingt1
	name = "Dizzy"
	desc = "<span class='warning'>Gah! I am bleeding!</span>\n"
	icon_state = "bleed1"

/datum/status_effect/debuff/bleedingworse
	id = "bleedingt2"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/bleedingt2
	affected_stats = list("strength" = -1, "speed" = -4)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/bleedingt2
	name = "Faint"
	desc = "<span class='warning'>I am bleeding heavily! Help!</span>\n"
	icon_state = "bleed2"

/datum/status_effect/debuff/bleedingworst
	id = "bleedingt3"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/bleedingt3
	affected_stats = list("strength" = -3, "speed" = -6)
	duration = 100

/atom/movable/screen/alert/status_effect/debuff/bleedingt3
	name = "Drained"
	desc = "<span class='boldwarning'>I feel like I am dying.. so.. weak..</span>\n"
	icon_state = "bleed3"

/datum/status_effect/debuff/sleepytime
	id = "sleepytime"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/sleepytime
	affected_stats = list("speed" = -2, "endurance" = -2)

/atom/movable/screen/alert/status_effect/debuff/sleepytime
	name = "Tired"
	desc = "<span class='warning'>I am feeling tired.</span>\n"
	icon_state = "sleepy"

/datum/status_effect/debuff/trainsleep
	id = "trainsleep"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/trainsleep
	affected_stats = list("strength" = -3, "speed" = -3,"endurance" = -3)

/atom/movable/screen/alert/status_effect/debuff/trainsleep
	name = "Muscle Soreness"
	desc = "<span class='warning'>Gaaaah, So sooooooore.</span>\n"
	icon_state = "muscles"

/datum/status_effect/debuff/gas
	id = "gas"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/gas
	affected_stats = list("strength" = -3, "speed" = -3,"endurance" = -3)
	duration = 600

/atom/movable/screen/alert/status_effect/debuff/gas
	name = "Gas Exposure"
	desc = "<span class='boldwarning'>THEY'RE GASSING US! NO! MY SKIN IS FALLING OFF! FUCK!!!</span>\n"
	icon_state = "gas"

/atom/movable/screen/alert/status_effect/debuff/embed
	name = "Embedded Objects"
	desc = "<span class='boldwarning'>There is something inside me that shouldn't.</span>\n"
	icon_state = "embed"

/datum/status_effect/debuff/embed
	id = "embed"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/embed

/// CLIMBING STUFF, PORTED FROM AZURE KEEP PULL REQUEST 808///

/// OPEN SPACE TURF BASED CLIMBING, MOB DRAG-DROP TILE
/datum/status_effect/debuff/climbing
	id = "climbing"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/climbing
	tick_interval = 10

/datum/status_effect/debuff/climbing/on_apply()
	. = ..()
	var/mob/living/climber = owner
	climber.climbing = TRUE
	climber.put_in_hands(new /obj/item/clothing/wall_grab, TRUE, FALSE, TRUE) // gotta have new before /obj/... , otherwise its gonna die

/datum/status_effect/debuff/climbing/tick() // do we wanna do this shit every single second? I guess we do boss
	. = ..()
	var/mob/living/carbon/human/climber = owner
	var/baseline_stamina_cost = 35 // have to disable stamina regen while on wall bruh in energystamina.dm
	var/climb_gear_bonus = 1
	if((istype(climber.backr, /obj/item/clothing/climbing_gear)) || (istype(climber.backl, /obj/item/clothing/climbing_gear)))
		climb_gear_bonus = 2
	var/climbing_skill = max(climber.mind.get_skill_level(/datum/skill/misc/climbing), SKILL_LEVEL_NOVICE) // freestyla hugboxed my shitcode FVCK
	var/stamina_cost_final = round(((baseline_stamina_cost / climbing_skill) / climb_gear_bonus), 1) // each END is 10 stam, each athletics is 5 stam
//	to_chat(climber, span_warningbig("[stamina_cost_final] REMOVED!")) // debug msg
	climber.rogstam_add(stamina_cost_final)
	var/turf/tile_under_climber = climber.loc
	var/list/branch_under_climber = list()
	for(var/obj/structure/flora/newbranch/branch in climber.loc)
		branch_under_climber += branch
	if(!istype(tile_under_climber, /turf/open/transparent/openspace))// if we aren't on open space turf, remove debuff (aka our feet are on solid shi or water)
		climber.remove_status_effect(/datum/status_effect/debuff/climbing)
	if(branch_under_climber.len)
		climber.remove_status_effect(/datum/status_effect/debuff/climbing)
	if(climber.rogfat >= (climber.maxrogfat / 2))
		to_chat(climber, "<span class='info'>I can't... hold on... much longer!</span>")
	else if(climber.rogfat >= climber.maxrogfat)
		to_chat(climber, "<span class='dead'>I can't hold onto the ledge for any longer!</span>")
		climber.remove_status_effect(/datum/status_effect/debuff/climbing)
		tile_under_climber.zFall(climber)

/datum/status_effect/debuff/climbing/on_remove()
	. = ..()
	var/mob/living/climber = owner
	climber.climbing = FALSE
	if(climber.is_holding_item_of_type(/obj/item/clothing/wall_grab)) // the slop slops itself holy shit
		for(var/obj/item/clothing/wall_grab/I in climber.held_items)
			if(istype(I, /obj/item/clothing/wall_grab))
				qdel(I)
				return

/atom/movable/screen/alert/status_effect/debuff/climbing
	name = "Climbing..."
	desc = ""
	icon_state = "muscles"