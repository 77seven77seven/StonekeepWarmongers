/datum/status_effect/buff
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/buff/drunk
	id = "drunk"
	alert_type = /atom/movable/screen/alert/status_effect/buff/drunk
	effectedstats = list("intelligence" = -1, "speed" = -1, "endurance" = 1)
	duration = 12 MINUTES

/atom/movable/screen/alert/status_effect/buff/drunk
	name = "Drunk"
	desc = "<span class='nicegreen'>I feel very drunk.</span>\n"
	icon_state = "drunk"

/datum/status_effect/buff/drunk/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/drunk)
/datum/status_effect/buff/drunk/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/drunk)

/datum/status_effect/buff/foodbuff
	id = "foodbuff"
	alert_type = /atom/movable/screen/alert/status_effect/buff/foodbuff
	effectedstats = list("constitution" = 1,"endurance" = 1)
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/buff/foodbuff
	name = "Great Meal"
	desc = "<span class='nicegreen'>That was a good meal!</span>\n"
	icon_state = "foodbuff"

/datum/status_effect/buff/foodbuff/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/goodfood)

/datum/status_effect/buff/druqks
	id = "druqks"
	alert_type = /atom/movable/screen/alert/status_effect/buff/druqks
	effectedstats = list("endurance" = 4,"speed" = 1)
	duration = 2 MINUTES

/datum/status_effect/buff/druqks/on_apply()
	. = ..()
	if(owner?.client)
		if(owner.client.screen && owner.client.screen.len)
			var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_above) in owner.client.screen
			PM.backdrop(owner)
			var/mob/living/carbon/C = owner
			C.add_stress(/datum/stressevent/high)


/datum/status_effect/buff/druqks/on_remove()
	. = ..()
	if(owner?.client)
		if(owner.client.screen && owner.client.screen.len)
			var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_above) in owner.client.screen
			PM.backdrop(owner)
			var/mob/living/carbon/C = owner
			C.remove_stress(/datum/stressevent/high)

/atom/movable/screen/alert/status_effect/buff/druqks
	name = "High"
	desc = "<span class='nicegreen'>I am tripping balls.</span>\n"
	icon_state = "acid"

/datum/status_effect/buff/ozium
	id = "ozium"
	alert_type = /atom/movable/screen/alert/status_effect/buff/druqks
	effectedstats = list("speed" = -3, "strength" = 3)
	duration = 2 MINUTES

/datum/status_effect/buff/ozium/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/ozium)
	ADD_TRAIT(owner, TRAIT_NOPAIN, TRAIT_GENERIC)

/datum/status_effect/buff/ozium/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOPAIN, TRAIT_GENERIC)
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/ozium)

/datum/status_effect/buff/smonkium
	id = "smonkium"
	alert_type = /atom/movable/screen/alert/status_effect/buff/druqks
	effectedstats = list("perception" = 3, "speed" = -1)
	duration = 2 MINUTES

/datum/status_effect/buff/moondust
	id = "moondust"
	alert_type = /atom/movable/screen/alert/status_effect/buff/druqks
	effectedstats = list("speed" = 4, "constitution" = 1)
	duration = 2 MINUTES

/datum/status_effect/buff/moondust/nextmove_modifier()
	return 0.5

/datum/status_effect/buff/moondust/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/moondust)

/datum/status_effect/buff/moondust/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/moondust)

/datum/status_effect/buff/moondust_purest
	id = "purest moondust"
	alert_type = /atom/movable/screen/alert/status_effect/buff/druqks
	effectedstats = list("speed" = 6, "endurance" = 6)
	duration = 3 MINUTES

/datum/status_effect/buff/moondust_purest/nextmove_modifier()
	return 0.5

/datum/status_effect/buff/moondust_purest/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/moondust_purest)

/datum/status_effect/buff/moondust_purest/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/moondust_purest)


/datum/status_effect/buff/weed
	id = "weed"
	alert_type = /atom/movable/screen/alert/status_effect/buff/weed
	effectedstats = list("intelligence" = 2,"speed" = -2,"fortune" = 2)
	duration = 5 MINUTES

/datum/status_effect/buff/weed/on_apply()
	. = ..()
	if(owner?.client)
		if(owner.client.screen && owner.client.screen.len)
			var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_above) in owner.client.screen
			PM.backdrop(owner)
			var/mob/living/carbon/C = owner
			C.add_stress(/datum/stressevent/weed)

/datum/status_effect/buff/weed/on_remove()
	. = ..()
	if(owner?.client)
		if(owner.client.screen && owner.client.screen.len)
			var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in owner.client.screen
			PM.backdrop(owner)
			PM = locate(/atom/movable/screen/plane_master/game_world_above) in owner.client.screen
			PM.backdrop(owner)
			var/mob/living/carbon/C = owner
			C.remove_stress(/datum/stressevent/weed)

/atom/movable/screen/alert/status_effect/buff/weed
	name = "Dazed"
	desc = "<span class='nicegreen'>I am so high maaaaaaaaan</span>\n"
	icon_state = "weed"

/datum/status_effect/buff/ravox
	id = "ravoxbuff"
	alert_type = /atom/movable/screen/alert/status_effect/buff/ravoxbuff
	effectedstats = list("constitution" = 1,"endurance" = 1,"strength" = 1)
	duration = 240 MINUTES

/atom/movable/screen/alert/status_effect/buff/ravoxbuff
	name = "Divine Power"
	desc = "<span class='nicegreen'>Divine power flows through me.</span>\n"
	icon_state = "ravox"

/datum/status_effect/buff/calm
	id = "calm"
	alert_type = /atom/movable/screen/alert/status_effect/buff/calm
	effectedstats = list("fortune" = 1)
	duration = 240 MINUTES

/atom/movable/screen/alert/status_effect/buff/calm
	name = "Calmness"
	desc = "<span class='nicegreen'>I feel a supernatural calm coming over me.</span>\n"
	icon_state = "stressg"

/datum/status_effect/buff/calm/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/calm)

/datum/status_effect/buff/calm/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/calm)

/datum/status_effect/buff/noc
	id = "nocbuff"
	alert_type = /atom/movable/screen/alert/status_effect/buff/nocbuff
	effectedstats = list("intelligence" = 3)
	duration = 240 MINUTES

/atom/movable/screen/alert/status_effect/buff/nocbuff
	name = "Divine Knowledge"
	desc = "<span class='nicegreen'>Divine knowledge flows through me.</span>\n"
	icon_state = "intelligence"

/datum/status_effect/buff/inspired
	id = "inspired"
	alert_type = /atom/movable/screen/alert/status_effect/buff/inspired
	effectedstats = list("speed" = 5,"constitution" = 3,"endurance" = 3,"strength" = 2)
	duration = 2 MINUTES

/atom/movable/screen/alert/status_effect/buff/inspired
	name = "Charge"
	desc = "<span class='nicegreen'>CHARGE!</span>\n"
	icon_state = "ravox"

/datum/status_effect/buff/inspired/great
	id = "inspired_great"
	alert_type = /atom/movable/screen/alert/status_effect/buff/inspired/great
	effectedstats = list("speed" = 7,"constitution" = 6,"endurance" = 6,"strength" = 5)
	duration = 3 MINUTES

/atom/movable/screen/alert/status_effect/buff/inspired/great
	name = "Ready to Die"
	desc = "<span class='nicegreen'>I'M READY TO DIE NOW!</span>\n"
	icon_state = "intelligence"

/atom/movable/screen/alert/status_effect/buff/charge
	name = "Charge"
	desc = "<span class='nicegreen'>CHARGE!</span>\n"
	icon_state = "ravox"

/datum/status_effect/buff/charge
	id = "charge"
	alert_type = /atom/movable/screen/alert/status_effect/buff/charge
	effectedstats = list("speed" = 7)
	duration = 1 MINUTES

/datum/status_effect/buff/saint
	id = "saint"
	alert_type = /atom/movable/screen/alert/status_effect/buff/saint
	effectedstats = list("speed" = 2,"constitution" = 2,"endurance" = 2,"strength" = 2)
	duration = 1 MINUTES

/atom/movable/screen/alert/status_effect/buff/saint
	name = "Death of a Saint"
	desc = "<span class='nicegreen'>They were a saint! A SAINT!</span>\n"
	icon_state = "intelligence"

/datum/status_effect/buff/adrenaline
	id = "adrenaline"
	alert_type = null
	duration = 35 SECONDS

/datum/status_effect/buff/adrenaline/on_apply()
	if(!ishuman(owner))
		return ..()
	var/mob/living/carbon/human/human_owner = owner

	human_owner.update_disabled_bodyparts()
	human_owner.emote("laugh")
	human_owner.set_resting(FALSE, FALSE)
	to_chat(owner, "<span class='userdanger'>NO! I AM NOT DYING LIKE THIS! THE LAST WILLS OF MY LIFE BEGIN TO BEAT HARDER THAN EVER BEFORE!</span>")
	if(aspect_chosen(/datum/round_aspect/halo))
		human_owner.playsound_local(src, 'sound/vo/halo/invincible.mp3', 75)
	return ..()

/datum/status_effect/buff/adrenaline/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.update_disabled_bodyparts()
	to_chat(owner, "<span class='danger'>[pick("The adrenaline drains, and the pain begins coming back!","AGH!!! MY ADRENALINEN!","MY LIFE!","MŮJ ŽIVOT UŽ UTÍKÁ! ADRENALINE, KDE JSI?!","FUCK! It is beginning to fade!","HELP! HELP! I CAN FEEL MY LEGS!")]</span>")

/datum/status_effect/buff/spawn_protection
	id = "spawnprotect"
	alert_type = null
	duration = 45 SECONDS

/datum/status_effect/buff/spawn_protection/on_apply()
	owner.status_flags |= GODMODE
	to_chat(owner, "<span class='info'>Spawn protection now active.</span>")
	if(aspect_chosen(/datum/round_aspect/halo))
		owner.playsound_local(src, 'sound/vo/halo/invincible.mp3', 100)
	return ..()

/datum/status_effect/buff/spawn_protection/on_remove()
	owner.status_flags &= ~GODMODE
	to_chat(owner, "<span class='info'>Your moment of spawn protection invulnerability has ended.</span>")

/atom/movable/screen/alert/status_effect/buff/formation
	name = "In Formation"
	desc = "<span class='nicegreen'>I'm in formation. So synchronized! I'm in awe, I can reload barkshottes faster.</span>"
	icon_state = "formation"

/datum/status_effect/buff/formation
	id = "formation"
	alert_type = /atom/movable/screen/alert/status_effect/buff/formation

/datum/status_effect/buff/formation/on_apply()
	if(prob(1))
		to_chat(owner, "<span class='info'>ok ladies now lets get in formation!</span>")
		owner.playsound_local(src, 'sound/misc/formation.ogg', 100)
	return ..()

//--------- Start of Warmongers Ring Buffs

/datum/status_effect/buff/warmongers
	var/stats2text = "None."

// Default #1
/datum/status_effect/buff/warmongers/ring
	id = "warmonger"
	stats2text = "a Warmonger's fervor"
	alert_type = /atom/movable/screen/alert/status_effect/buff/warmonger
	duration = 666 MINUTES

/atom/movable/screen/alert/status_effect/buff/warmonger
	name = "I AM A TRUE WARMONGER!!"
	desc = "<span class='nicegreen'>KILL THEM ALL!! CHAAARRRGE!!</span>\n"
	icon_state = "buff_war"

// Default #2
/datum/status_effect/buff/warmongers/shiny
	id = "shiny"
	stats2text = "a beautiful shine"
	alert_type = /atom/movable/screen/alert/status_effect/buff/shiny
	duration = 666 MINUTES

/atom/movable/screen/alert/status_effect/buff/shiny
	name = "OOOUH!! IT'S SO SHINY!!"
	desc = "<span class='nicegreen'>YESSSSSSS, MY PRECIOUSSS!!</span>\n"
	icon_state = "stressvg"

// Standard Magical Ring Buffs
// Bonus Stat I, II, III, etc.

// Strength
/datum/status_effect/buff/warmongers/ring/strength1
	id = "strength1"
	stats2text = "Strength I"
	alert_type = /atom/movable/screen/alert/status_effect/buff/strength1
	duration = 666 MINUTES
	effectedstats = list("strength" = 1)

/atom/movable/screen/alert/status_effect/buff/strength1
	name = "Strength I"
	desc = "<span class='nicegreen'>I feel stronger.</span>\n"
	icon_state = "buff_str"

/datum/status_effect/buff/warmongers/ring/strength2
	id = "strength2"
	stats2text = "Strength II"
	alert_type = /atom/movable/screen/alert/status_effect/buff/strength2
	duration = 666 MINUTES
	effectedstats = list("strength" = 2)

/atom/movable/screen/alert/status_effect/buff/strength2
	name = "Strength II"
	desc = "<span class='nicegreen'>I feel stronger.</span>\n"
	icon_state = "buff_str"

/datum/status_effect/buff/warmongers/ring/strength3
	id = "strength3"
	stats2text = "Strength III"
	alert_type = /atom/movable/screen/alert/status_effect/buff/strength3
	duration = 666 MINUTES
	effectedstats = list("strength" = 3)

/atom/movable/screen/alert/status_effect/buff/strength3
	name = "Strength III"
	desc = "<span class='nicegreen'>I feel stronger.</span>\n"
	icon_state = "buff_str"

// Perception
/datum/status_effect/buff/warmongers/ring/perception1
	id = "perception1"
	stats2text = "Perception I"
	alert_type = /atom/movable/screen/alert/status_effect/buff/perception1
	duration = 666 MINUTES
	effectedstats = list("perception" = 1)

/atom/movable/screen/alert/status_effect/buff/perception1
	name = "Perception I"
	desc = "<span class='nicegreen'>I see clearer.</span>\n"
	icon_state = "buff_per"

/datum/status_effect/buff/warmongers/ring/perception2
	id = "perception2"
	stats2text = "Perception II"
	alert_type = /atom/movable/screen/alert/status_effect/buff/perception2
	duration = 666 MINUTES
	effectedstats = list("perception" = 2)

/atom/movable/screen/alert/status_effect/buff/perception2
	name = "Perception II"
	desc = "<span class='nicegreen'>I see clearer.</span>\n"
	icon_state = "buff_per"

/datum/status_effect/buff/warmongers/ring/perception3
	id = "perception3"
	stats2text = "Perception III"
	alert_type = /atom/movable/screen/alert/status_effect/buff/perception3
	duration = 666 MINUTES
	effectedstats = list("perception" = 3)

/atom/movable/screen/alert/status_effect/buff/perception3
	name = "Perception III"
	desc = "<span class='nicegreen'>I see clearer.</span>\n"
	icon_state = "buff_per"

// Intelligence
/datum/status_effect/buff/warmongers/ring/intelligence1
	id = "intelligence1"
	stats2text = "Intelligence I"
	alert_type = /atom/movable/screen/alert/status_effect/buff/intelligence1
	duration = 666 MINUTES
	effectedstats = list("intelligence" = 1)

/atom/movable/screen/alert/status_effect/buff/intelligence1
	name = "Intelligence I"
	desc = "<span class='nicegreen'>I feel smarter.</span>\n"
	icon_state = "buff_int"

/datum/status_effect/buff/warmongers/ring/intelligence2
	id = "intelligence2"
	stats2text = "Intelligence II"
	alert_type = /atom/movable/screen/alert/status_effect/buff/intelligence2
	duration = 666 MINUTES
	effectedstats = list("intelligence" = 2)

/atom/movable/screen/alert/status_effect/buff/intelligence2
	name = "Intelligence II"
	desc = "<span class='nicegreen'>I feel smarter.</span>\n"
	icon_state = "buff_int"

/datum/status_effect/buff/warmongers/ring/intelligence3
	id = "intelligence3"
	stats2text = "Intelligence III"
	alert_type = /atom/movable/screen/alert/status_effect/buff/intelligence3
	duration = 666 MINUTES
	effectedstats = list("intelligence" = 3)

/atom/movable/screen/alert/status_effect/buff/intelligence3
	name = "Intelligence III"
	desc = "<span class='nicegreen'>I feel smarter.</span>\n"
	icon_state = "buff_int"

// Constitution
/datum/status_effect/buff/warmongers/ring/constitution1
	id = "constitution1"
	stats2text = "Constitution I"
	alert_type = /atom/movable/screen/alert/status_effect/buff/constitution1
	duration = 666 MINUTES
	effectedstats = list("constitution" = 1)

/atom/movable/screen/alert/status_effect/buff/constitution1
	name = "Constitution I"
	desc = "<span class='nicegreen'>I feel heartier.</span>\n"
	icon_state = "buff_con"

/datum/status_effect/buff/warmongers/ring/constitution2
	id = "constitution2"
	stats2text = "Constitution II"
	alert_type = /atom/movable/screen/alert/status_effect/buff/constitution2
	duration = 666 MINUTES
	effectedstats = list("constitution" = 2)

/atom/movable/screen/alert/status_effect/buff/constitution2
	name = "Constitution II"
	desc = "<span class='nicegreen'>I feel heartier.</span>\n"
	icon_state = "buff_con"

/datum/status_effect/buff/warmongers/ring/constitution3
	id = "constitution3"
	stats2text = "Constitution III"
	alert_type = /atom/movable/screen/alert/status_effect/buff/constitution3
	duration = 666 MINUTES
	effectedstats = list("constitution" = 3)

/atom/movable/screen/alert/status_effect/buff/constitution3
	name = "Constitution III"
	desc = "<span class='nicegreen'>I feel heartier.</span>\n"
	icon_state = "buff_con"

// Endurance
/datum/status_effect/buff/warmongers/ring/endurance1
	id = "endurance1"
	stats2text = "Endurance I"
	alert_type = /atom/movable/screen/alert/status_effect/buff/endurance1
	duration = 666 MINUTES
	effectedstats = list("endurance" = 1)

/atom/movable/screen/alert/status_effect/buff/endurance1
	name = "Endurance I"
	desc = "<span class='nicegreen'>I feel sturdier.</span>\n"
	icon_state = "buff_end"

/datum/status_effect/buff/warmongers/ring/endurance2
	id = "endurance2"
	stats2text = "Endurance II"
	alert_type = /atom/movable/screen/alert/status_effect/buff/endurance2
	duration = 666 MINUTES
	effectedstats = list("endurance" = 2)

/atom/movable/screen/alert/status_effect/buff/endurance2
	name = "Endurance II"
	desc = "<span class='nicegreen'>I feel sturdier.</span>\n"
	icon_state = "buff_end"

/datum/status_effect/buff/warmongers/ring/endurance3
	id = "endurance3"
	stats2text = "Endurance III"
	alert_type = /atom/movable/screen/alert/status_effect/buff/endurance3
	duration = 666 MINUTES
	effectedstats = list("endurance" = 3)

/atom/movable/screen/alert/status_effect/buff/endurance3
	name = "Endurance III"
	desc = "<span class='nicegreen'>I feel sturdier.</span>\n"
	icon_state = "buff_end"

// Speed
/datum/status_effect/buff/warmongers/ring/speed1
	id = "speed1"
	stats2text = "Speed I"
	alert_type = /atom/movable/screen/alert/status_effect/buff/speed1
	duration = 666 MINUTES
	effectedstats = list("speed" = 1)

/atom/movable/screen/alert/status_effect/buff/speed1
	name = "Speed I"
	desc = "<span class='nicegreen'>I feel faster.</span>\n"
	icon_state = "buff_spd"

/datum/status_effect/buff/warmongers/ring/speed2
	id = "speed2"
	stats2text = "Speed II"
	alert_type = /atom/movable/screen/alert/status_effect/buff/speed2
	duration = 666 MINUTES
	effectedstats = list("speed" = 2)

/atom/movable/screen/alert/status_effect/buff/speed2
	name = "Speed II"
	desc = "<span class='nicegreen'>I feel faster.</span>\n"
	icon_state = "buff_spd"

/datum/status_effect/buff/warmongers/ring/speed3
	id = "speed3"
	stats2text = "Speed III"
	alert_type = /atom/movable/screen/alert/status_effect/buff/speed3
	duration = 666 MINUTES
	effectedstats = list("speed" = 3)

/atom/movable/screen/alert/status_effect/buff/speed3
	name = "Speed III"
	desc = "<span class='nicegreen'>I feel faster.</span>\n"
	icon_state = "buff_spd"

// Fortune
/datum/status_effect/buff/warmongers/ring/fortune1
	id = "fortune1"
	stats2text = "Fortune I"
	alert_type = /atom/movable/screen/alert/status_effect/buff/fortune1
	duration = 666 MINUTES
	effectedstats = list("fortune" = 1)

/atom/movable/screen/alert/status_effect/buff/fortune1
	name = "Fortune I"
	desc = "<span class='nicegreen'>I feel luckier.</span>\n"
	icon_state = "buff_luc"

/datum/status_effect/buff/warmongers/ring/fortune2
	id = "fortune2"
	stats2text = "Fortune II"
	alert_type = /atom/movable/screen/alert/status_effect/buff/fortune2
	duration = 666 MINUTES
	effectedstats = list("fortune" = 2)

/atom/movable/screen/alert/status_effect/buff/fortune2
	name = "Fortune II"
	desc = "<span class='nicegreen'>I feel luckier.</span>\n"
	icon_state = "buff_luc"

/datum/status_effect/buff/warmongers/ring/fortune3
	id = "fortune3"
	stats2text = "Fortune III"
	alert_type = /atom/movable/screen/alert/status_effect/buff/fortune3
	duration = 666 MINUTES
	effectedstats = list("fortune" = 3)

/atom/movable/screen/alert/status_effect/buff/fortune3
	name = "Fortune III"
	desc = "<span class='nicegreen'>I feel luckier.</span>\n"
	icon_state = "buff_luc"

//--------- Unique Magical Ring Buffs
//--------- Here be dragons

/datum/status_effect/buff/warmongers/ring/unique

/datum/status_effect/buff/warmongers/ring/unique/truemonger
	id = "truemonger"
	stats2text = "All Stats Up VI"
	alert_type = /atom/movable/screen/alert/status_effect/buff/truemonger
	duration = 666 MINUTES
	effectedstats = list("strength" = 6, "perception" = 6, "intelligence" = 6, "constitution" = 6, "endurance" = 6, "speed" = 6, "fortune" = 6)

/atom/movable/screen/alert/status_effect/buff/truemonger
	name = "THERE CAN BE ONLY ONE!!"
	desc = "<span class='nicegreen'>I FEEL LIKE I COULD SLAY GODS!!</span>\n"
	icon_state = "buff_war"

//--------- End of Warmongers Ring Buffs
