#define round_duration_in_ticks (SSticker.round_start_time ? world.time - SSticker.round_start_time : 0)

SUBSYSTEM_DEF(warmongers)
	name = "Warmongers"

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME

	var/warfare_ready_to_die = FALSE		// If the barriers for fair play have been removed yet.
	var/warfare_techlevel = WARMONGERS_TECHLEVEL_FLINTLOCKS
	var/obj/structure/warobjective/fuckthisshit
	var/list/warfare_barriers = list()

	var/area/red_airship
	var/area/blue_airship

	var/list/red_airship_landmarks = list()
	var/list/blue_airship_landmarks = list()

	var/respawn_cycle = 0
	var/next_respawn
	var/last_respawn = 0
	var/time_between_respawns = 1 MINUTES // in seconds

	var/respawning = FALSE

	var/oneteammode = FALSE // players only allowed to choose the regime

	var/landmark_respawn_id_attacker // used for big capture point maps
	var/landmark_respawn_id_defender

	var/red_warteam_cmode_music = 'sound/music/drunkandlovingit.ogg'
	var/blu_warteam_cmode_music = 'sound/music/prayformoreammo.ogg'
	// generic footsoldier anthems

/datum/controller/subsystem/warmongers/Initialize(start_timeofday)
	red_airship = locate(/area/rogue/indoors/airship/red)
	blue_airship = locate(/area/rogue/indoors/airship/blue)

	if(splittext(SSmapping.config.map_name, "-")[1] == "TDM" || aspect_chosen(/datum/round_aspect/squishyhumans))
		time_between_respawns = 30 SECONDS

/datum/controller/subsystem/warmongers/proc/get_respawn_point(var/mob/living/carbon/human/HU)
	var/turf/starto
	for(var/obj/effect/landmark/start/sloc in GLOB.start_landmarks_list)
		if(sloc.name != HU.mind.assigned_role)
			continue
		starto = get_turf(sloc)
	if(HU.warfare_faction == BLUE_WARTEAM && landmark_respawn_id_attacker)
		for(var/obj/effect/landmark/assaultrespawn/ASSR in GLOB.landmarks_list)
			if(ASSR.respawn_id != landmark_respawn_id_attacker)
				continue
			starto = get_turf(ASSR)
	if(HU.warfare_faction == RED_WARTEAM && landmark_respawn_id_defender)
		for(var/obj/effect/landmark/assaultrespawn/defender/ASSR in GLOB.landmarks_list)
			if(ASSR.respawn_id != landmark_respawn_id_defender)
				continue
			starto = get_turf(ASSR)
	return starto

/datum/controller/subsystem/warmongers/proc/respawn(var/area/airship)
	for(var/mob/living/carbon/human/H in airship)
		window_flash(H.client)

		sleep(rand(1,3))
		H.blind_eyes(1)
		H.emote("scream")
		H.apply_status_effect(/datum/status_effect/buff/spawn_protection)

		if(H.warfare_faction)
			var/turf/starto = get_respawn_point(H)

			H.forceMove(starto)
			if(H.buckled)
				H.buckled.forceMove(starto)
			//H.lay_down()

			H.pixel_y = 200
			H.alpha = 0
			animate(H, 1 SECONDS, easing = BOUNCE_EASING, pixel_y = 0)
			animate(H, 1 SECONDS, alpha = 255)

			if(H.buckled)
				H.buckled.pixel_y = 200
				H.buckled.alpha = 0
				animate(H.buckled, 1 SECONDS, easing = BOUNCE_EASING, pixel_y = 0)
				animate(H.buckled, 1 SECONDS, alpha = 255)

			spawn(0.35 SECONDS)
				playsound(H.loc, 'sound/misc/fall.ogg', 100, FALSE, -1)

/datum/controller/subsystem/warmongers/fire(resumed)
	if(!warfare_ready_to_die)
		return

	var/obj/effect/landmark/blureinforcement/blu = locate(/obj/effect/landmark/blureinforcement) in GLOB.landmarks_list
	var/obj/effect/landmark/redreinforcement/red = locate(/obj/effect/landmark/redreinforcement) in GLOB.landmarks_list

	if(round_duration_in_ticks >= next_respawn || !next_respawn)
		if(!respawn_cycle)
			message_admins("respawn cycle activated")
			respawn_cycle++
		respawning = TRUE

		playsound(blu.loc, 'sound/misc/airship_horn.ogg', 100, FALSE, 8)
		playsound(red.loc, 'sound/misc/airship_horn.ogg', 100, FALSE, 8)

		playsound_area(red_airship, 'sound/misc/airship_horn_inside.ogg')
		playsound_area(blue_airship, 'sound/misc/airship_horn_inside.ogg')

		sleep(7 SECONDS)
		respawn(red_airship)
		respawn(blue_airship)

		respawn_cycle++
		next_respawn = round_duration_in_ticks + time_between_respawns
		last_respawn = round_duration_in_ticks
		respawning = FALSE

		message_admins("respawn cycle: [respawn_cycle]")

/datum/controller/subsystem/warmongers/proc/ReadyToDie()
	var/datum/game_mode/warmongers/W = SSticker.mode
	if(!warfare_ready_to_die)
		to_chat(world, "<span class='userdanger'>[pick("FOR THE CROWN! FOR THE EMPIRE!","CHILDREN OF THE NATION, TO YOUR STATIONS!","I'M NOT AFRAID TO DIE!")]</span>")
		if(!(oneteammode))
			W.supplies()
		warfare_ready_to_die = TRUE

		// https://imgur.com/a/mzWBurl

		for(var/mob/M in GLOB.player_list)
			SEND_SOUND(M, sound(null))
			M.overlay_fullscreen("kill", /atom/movable/screen/fullscreen/kill)
			M.clear_fullscreen("kill", 5 SECONDS)
			//M.client.verbs -= /client/proc/forcestartvote
			SSdroning.area_entered(get_area(M), M.client)

		for(var/obj/O in warfare_barriers)
			qdel(O)
		
		W.HandleNoLords()
		W.warmode.beginround()

/datum/controller/subsystem/warmongers/proc/SendSupplies() // supply drops
	var/datum/game_mode/warmongers/W = SSticker.mode

	var/obj/effect/landmark/blureinforcement/blu = locate(/obj/effect/landmark/blureinforcement) in GLOB.landmarks_list
	var/obj/effect/landmark/redreinforcement/red = locate(/obj/effect/landmark/redreinforcement) in GLOB.landmarks_list

	var/list/reinforcementinas = list()
	switch(W.reinforcementwave)
		if(1)
			reinforcementinas += "/obj/item/rogue/bomb"
			reinforcementinas += "/obj/item/rogue/bomb/fire/mollie"
		if(2)
			reinforcementinas += "/obj/item/rogue/bomb"
			reinforcementinas += "/obj/item/rogue/bomb"
			reinforcementinas += "/obj/item/rogue/bomb/fire"
			reinforcementinas += "/obj/item/rogue/bomb/smoke"
			reinforcementinas += "/obj/item/flint"
			SSwarmongers.warfare_techlevel = WARMONGERS_TECHLEVEL_FLINTLOCKS
			to_chat(world, "<span class='notice'>This battle will soon get too heated for these shopkeepers!</span>")
		if(3)
			reinforcementinas += "/obj/item/rogue/bomb/smoke"
			reinforcementinas += "/obj/item/rogue/bomb/fire"
			reinforcementinas += "/obj/item/rogue/bomb/poison"
			reinforcementinas += "/obj/item/rogue/bomb"
			reinforcementinas += "/obj/item/rogue/bomb"
			to_chat(world, "<span class='notice'>This battle is getting too heated for these shopkeepers! They're leaving!</span>")
			for(var/obj/structure/shopkeep/SHP in world)
				SHP.leave()
		if(4)
			reinforcementinas += "/obj/item/rogue/bomb/fire"
			reinforcementinas += "/obj/item/rogue/bomb/fire"
			reinforcementinas += "/obj/item/rogue/bomb/poison"
			reinforcementinas += "/obj/item/rogue/bomb/poison"
			SSwarmongers.warfare_techlevel = WARMONGERS_TECHLEVEL_COWBOY
			to_chat(world, "<span class='notice'>OUR NATION'S ARMORY IS EVOLVING! PROTOTYPE WEAPONRY AUTHORIZED!</span>")
		if(5)
			reinforcementinas += "/obj/item/rogue/bomb"
			reinforcementinas += "/obj/item/rogue/bomb"
			reinforcementinas += "/obj/item/rogue/bomb/fire"
			reinforcementinas += "/obj/item/rogue/bomb/smoke"
			reinforcementinas += "/obj/item/rogue/bomb/poison"
			reinforcementinas += "/obj/item/rogue/bomb/poison"
	W.reinforcementwave++
	to_chat(world, "<span class='info'><span class='typewrite'>Supplies have arrived.</span></span>")
	for(var/mob/M in GLOB.player_list)
		if(aspect_chosen(/datum/round_aspect/halo))
			SEND_SOUND(M, 'sound/vo/halo/reinforcements.mp3')
		else
			SEND_SOUND(M, 'sound/misc/reinforcement.ogg')
	new /obj/effect/telefog(red.loc)
	new /obj/effect/telefog(blu.loc)
	for(var/i in reinforcementinas)
		var/typepath = text2path(i)
		new typepath(red.loc)
		new typepath(blu.loc)

/proc/GetMainGunForWarfarePPU()
	switch(SSwarmongers.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/bayo
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/repeater
		if(WARMONGERS_TECHLEVEL_AUTO)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/supermachine
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/proc/GetMainGunForWarfareRegime()
	switch(SSwarmongers.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/bayo/carbine
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/boltaction
		if(WARMONGERS_TECHLEVEL_AUTO)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/supermachine
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/proc/GetSniperForWarfarePPU()
	switch(SSwarmongers.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/sniper
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/repeater/sniper
		if(WARMONGERS_TECHLEVEL_AUTO)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/supermachine
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/proc/GetSniperForWarfareRegime()
	switch(SSwarmongers.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/sniper/alternate
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/boltaction/sniper
		if(WARMONGERS_TECHLEVEL_AUTO)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/supermachine
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/proc/GetSidearmForWarfarePPU(var/isofficer = FALSE)
	var/datum/game_mode/warmongers/W = SSticker.mode
	if(isofficer && W.reinforcementwave == 4)
		if(prob(50))
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/axed
		else
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded

	switch(SSwarmongers.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/storage/backpack/rogue/holster/lockpistppr
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/storage/backpack/rogue/holster/volvappr
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/proc/GetSidearmForWarfareRegime(var/isofficer = FALSE)
	var/datum/game_mode/warmongers/W = SSticker.mode
	if(isofficer && W.reinforcementwave == 4)
		if(prob(50))
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/axed/alternate
		else
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol/sworded/alternate

	switch(SSwarmongers.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/storage/backpack/rogue/holster/regime/lockpistregi
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/storage/backpack/rogue/holster/regime/volvaregi
		if(WARMONGERS_TECHLEVEL_NONE)
			return null