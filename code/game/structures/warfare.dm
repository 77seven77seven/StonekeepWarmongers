/obj/structure/warobjective
	name = "objective"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/gametype = /datum/warmode
	var/invis_on_init = FALSE // whether to set invisibility, density and opacity on init

/obj/structure/warobjective/Initialize()
	. = ..()
	SSwarmongers.fuckthisshit = src

/obj/structure/warobjective/proc/setup()
	var/datum/game_mode/warmongers/C = SSticker.mode
	var/datum/warmode/WM = new gametype
	
	C.warmode = WM
	WM.objective = src

	if(invis_on_init)
		invisibility = INVISIBILITY_ABSTRACT
		density = FALSE
		opacity = FALSE

// TDM

/obj/structure/warobjective/bloodstatue // new LAST STAND
	name = "Sanctified Statue"
	desc = "A derelict of a former age. It demands blood."
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "psy" //ironic...
	pixel_x = -32
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	gametype = /datum/warmode/tdm

// CTF

/obj/structure/warobjective/ponr
	name = "Regimer Flong"
	desc = "A very important flong."
	icon = 'icons/shamelessly_stolen.dmi'
	icon_state = "ponrblue"
	anchored = TRUE
	climbable = FALSE
	density = TRUE
	opacity = FALSE
	gametype = /datum/warmode/noreturn

/obj/structure/warobjective/ponr/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/warobjective/ponr/process()
	for(var/turf/closed/wall/W in RANGE_TURFS(2, src)) //no cheating by just boxing in the statue, that is super lame.
		W.dismantle_wall()

/obj/structure/warobjective/ponr/attack_hand(mob/user)
	var/mob/living/carbon/human/H
	var/datum/game_mode/warmongers/C = SSticker.mode
	var/datum/warmode/noreturn/NR = C.warmode
	if(ishuman(user))
		H = user

	if(NR.red_flag == H)
		NR.red_flag = null
		H.filters = list()

		NR.blu_captures++
		C.blu_bonus += 2
		C.red_bonus -= 1
		if(NR.blu_captures >= NR.captures_required)
			C.do_war_end(H, BLUE_WARTEAM)
		for(var/client/reg in C.regimians)
			to_chat(reg, "<span class='info'>We have captured their flag! [NR.blu_captures]/[NR.captures_required]</span>")
			if(aspect_chosen(/datum/round_aspect/halo))
				SEND_SOUND(reg, 'sound/vo/halo/flag_cap.mp3')
			else
				SEND_SOUND(reg, 'sound/misc/flag_captured.ogg')
		for(var/client/unio in C.unionists)
			to_chat(unio, "<span class='warning'>They've captured our flag. [NR.blu_captures]/[NR.captures_required]</span>")
			SEND_SOUND(unio, 'sound/misc/hel.ogg')
		return

	if(H.warfare_faction == BLUE_WARTEAM)
		to_chat(H, "<span class='info'>This belongs to us.</span>")
		return

	if(NR.blu_flag)
		to_chat(H, "<span class='info'>Someone else is carrying the flag.</span>")
		return

	NR.blu_flag = H
	H.add_filter("flag_highlight",1,list("type"="drop_shadow","color"=COLOR_BLUE,"size"=3))
	for(var/client/unio in C.unionists)
		to_chat(unio, "<span class='userdanger'>We have taken the enemy flag!</span>")
		if(aspect_chosen(/datum/round_aspect/halo))
			SEND_SOUND(unio, 'sound/vo/halo/flag_take.mp3')
		else
			SEND_SOUND(unio, 'sound/misc/flag_taken.ogg')
	for(var/client/reg in C.regimians)
		if(prob(1))
			to_chat(reg, "<span class='userdanger'>WADAFAK BITCH! OUR FLAG WAS TAKEN!!!</span>")
		else
			to_chat(reg, "<span class='userdanger'>OUR FLAG HAS BEEN TAKEN!!!</span>")
		if(aspect_chosen(/datum/round_aspect/halo))
			SEND_SOUND(reg, 'sound/vo/halo/flag_stolen.mp3')
		else
			SEND_SOUND(reg, 'sound/misc/hello.ogg')

/obj/structure/warobjective/ponr/red
	name = "Union's Flang"
	desc = "A very important flang."
	icon_state = "ponrred"

/obj/structure/warobjective/ponr/red/attack_hand(mob/user)
	var/mob/living/carbon/human/H
	var/datum/game_mode/warmongers/C = SSticker.mode
	var/datum/warmode/noreturn/NR = C.warmode
	if(ishuman(user))
		H = user

	if(NR.blu_flag == H)
		NR.blu_flag = null
		H.filters = list()

		NR.red_captures++
		C.red_bonus += 2
		C.blu_bonus -= 1
		if(NR.red_captures >= NR.captures_required)
			C.do_war_end(H, RED_WARTEAM)
		for(var/client/unio in C.unionists)
			to_chat(unio, "<span class='info'>We have captured their flag! [NR.red_captures]/[NR.captures_required]</span>")
			if(aspect_chosen(/datum/round_aspect/halo))
				SEND_SOUND(unio, 'sound/vo/halo/flag_cap.mp3')
			else
				SEND_SOUND(unio, 'sound/misc/flag_captured.ogg')
		for(var/client/reg in C.regimians)
			to_chat(reg, "<span class='warning'>They've captured our flag. [NR.red_captures]/[NR.captures_required]</span>")
			SEND_SOUND(reg, 'sound/misc/hel.ogg')
		return

	if(H.warfare_faction == RED_WARTEAM)
		to_chat(H, "<span class='info'>This belongs to us.</span>")
		return

	if(NR.red_flag)
		to_chat(H, "<span class='info'>Someone else is carrying the flag.</span>")
		return

	NR.red_flag = H
	H.add_filter("flag_highlight",1,list("type"="drop_shadow","color"=COLOR_RED,"size"=3))
	for(var/client/reg in C.regimians)
		to_chat(reg, "<span class='userdanger'>We have taken the enemy flag!</span>")
		if(aspect_chosen(/datum/round_aspect/halo))
			SEND_SOUND(reg, 'sound/vo/halo/flag_take.mp3')
		else
			SEND_SOUND(reg, 'sound/misc/flag_taken.ogg')
	for(var/client/unio in C.unionists)
		if(prob(1))
			to_chat(unio, "<span class='userdanger'>WADAFAK BITCH! OUR FLAG WAS TAKEN!!!</span>")
		else
			to_chat(unio, "<span class='userdanger'>OUR FLAG HAS BEEN TAKEN!!!</span>")
		if(aspect_chosen(/datum/round_aspect/halo))
			SEND_SOUND(unio, 'sound/vo/halo/flag_stolen.mp3')
		else
			SEND_SOUND(unio, 'sound/misc/hello.ogg')

// LD

/obj/structure/warobjective/assaultthrone
	name = "throne"
	desc = "Do not let the enemy sit on this with your crown."
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "throne2"
	density = FALSE
	can_buckle = 1
	pixel_x = -32
	buckle_lying = FALSE
	gametype = /datum/warmode/assault

/obj/structure/warobjective/assaultthrone/post_buckle_mob(mob/living/M)
	..()
	density = TRUE
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 8)

/obj/structure/warobjective/assaultthrone/post_unbuckle_mob(mob/living/M)
	..()
	density = FALSE
	M.reset_offsets("bed_buckle")

/obj/structure/warobjective/warthrone/Initialize()
	..()
	lordcolor(CLOTHING_RED,CLOTHING_YELLOW)

/obj/structure/warobjective/warthrone/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/structure/warobjective/warthrone/lordcolor(primary,secondary)
	if(!primary || !secondary)
		return
	var/mutable_appearance/M = mutable_appearance(icon, "throne_primary", -(layer+0.1))
	M.color = primary
	add_overlay(M)
	M = mutable_appearance(icon, "throne_secondary", -(layer+0.1))
	M.color = secondary
	add_overlay(M)
	GLOB.lordcolor -= src

// LD

/obj/structure/warobjective/warthrone
	name = "throne of the Union"
	desc = "Do not let the enemy sit on this with your crown."
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "throne2"
	density = FALSE
	can_buckle = 1
	pixel_x = -32
	buckle_lying = FALSE
	gametype = /datum/warmode/lords

/obj/structure/warobjective/warthrone/post_buckle_mob(mob/living/M)
	..()
	density = TRUE
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 8)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(istype(SSticker.mode, /datum/game_mode/warmongers))
		var/datum/game_mode/warmongers/C = SSticker.mode
		var/datum/warmode/lords/L = C.warmode
		if(L.winner == H)
			return // Gets rid of people farming triumphs
		switch(H.warfare_faction)
			if(RED_WARTEAM)
				if(istype(H.head, /obj/item/clothing/head/roguetown/warmongers/crownblu))
					C.do_war_end(H, RED_WARTEAM)
			if(BLUE_WARTEAM)
				if(istype(H.head, /obj/item/clothing/head/roguetown/warmongers/crownred))
					C.do_war_end(H, BLUE_WARTEAM)

/obj/structure/warobjective/warthrone/post_unbuckle_mob(mob/living/M)
	..()
	density = FALSE
	M.reset_offsets("bed_buckle")

/obj/structure/warobjective/warthrone/Initialize()
	..()
	lordcolor(CLOTHING_RED,CLOTHING_YELLOW)

/obj/structure/warobjective/warthrone/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/structure/warobjective/warthrone/lordcolor(primary,secondary)
	if(!primary || !secondary)
		return
	var/mutable_appearance/M = mutable_appearance(icon, "throne_primary", -(layer+0.1))
	M.color = primary
	add_overlay(M)
	M = mutable_appearance(icon, "throne_secondary", -(layer+0.1))
	M.color = secondary
	add_overlay(M)
	GLOB.lordcolor -= src

// Shopkeepers, back now with improvements!

/obj/structure/shopkeep
	name = "\improper KAITZAR-Sponzored Shopkeeper"
	desc = "A merchant, he has some things to sell. He is hanging from an airship by chain... he won't stick around for long."
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "shop"
	layer = 4.26
	plane = GAME_PLANE_UPPER
	pixel_x = 6
	pixel_y = 9
	anchored = TRUE
	density = FALSE
	var/leaving = FALSE
	var/faction = BLUE_WARTEAM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/shopkeep/red
	name = "\improper Beezer's Favorite Chef Shopkeeper"
	faction = RED_WARTEAM

/obj/structure/shopkeep/proc/leave()
	if(leaving)
		return
	leaving = TRUE
	flick("shop_leave", src)
	playsound(src, 'sound/misc/gate.ogg', 50, FALSE)
	QDEL_IN(src, 35)

/obj/structure/shopkeep/examine(mob/user)
	. = ..()
	if(istype(get_area(src), /area/rogue/indoors))
		. += "<span class='info'>There is a hole in the roof to allow the chains to get inside.</span>"

/obj/structure/shopkeep/attack_hand(mob/user)
	. = ..()
	var/datum/game_mode/warmongers/C = SSticker.mode
	var/mob/living/carbon/human/H
	if(ishuman(user))
		H = user
		if(H.warfare_faction != faction)
			say("OK! LETS GET TO BUSINE- wait a second... HEY YOU'RE NOT MEANT TO BE HERE!!!")
			playsound(loc, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
			return
	if(leaving)
		to_chat(user, "<span class='warning'>NO! NO! I FORGOT TO GET MY CHANGE! NOOOOOOOOO!</span>")
		user.playsound_local(src, 'sound/misc/zizo.ogg', 50, FALSE)
		return
	playsound(src, 'sound/misc/keyboard_enter.ogg', 100, FALSE, -1)

	var/list/shippables = list()
	for(var/s in subtypesof(/datum/warshippable))
		var/datum/warshippable/WS = new s()
		var/faction_check = TRUE
		if(WS.faction && WS.faction != H.warfare_faction)
			faction_check = FALSE
		if(C.reinforcementwave >= WS.reinforcement && faction_check)
			shippables[WS.name] = WS

	var/choice = browser_input_list(user, "AIRSHIPPED GOODS!", "BUY NOW!!!", shippables)
	var/datum/warshippable/shoppin = shippables[choice]
	if(!shoppin)
		return
	/*
	if(!do_after(user, 5 SECONDS, TRUE, loc))
		playsound(loc, 'sound/misc/machineno.ogg', 100, FALSE, -1)
		return
	*/

	switch(faction)
		if(RED_WARTEAM)
			if(C.red_bonus >= 1)
				C.red_bonus--
				playsound(loc, 'sound/misc/machinevomit.ogg', 100, FALSE, -1)
			else
				playsound(loc, 'sound/misc/machineno.ogg', 100, FALSE, -1)
				say("INSUFFICIENT FUNDS!!!")
				return
		if(BLUE_WARTEAM)
			if(C.blu_bonus >= 1)
				C.blu_bonus--
				playsound(loc, 'sound/misc/machinevomit.ogg', 100, FALSE, -1)
			else
				playsound(loc, 'sound/misc/machineno.ogg', 100, FALSE, -1)
				say("INSUFFICIENT FUNDS!!!")
				return
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)

	for(var/i in shoppin.items)
		if(shoppin.items.len > 1)
			sleep(rand(1,3))
		var/fuck = new i(get_turf(src))
		if(istype(fuck, /obj))
			var/obj/O = fuck
			O.pixel_y = 640
			animate(O, 1 SECONDS, easing = BOUNCE_EASING, pixel_y = 0)
			spawn(0.35 SECONDS)
				playsound(loc, 'sound/misc/fall.ogg', 100, FALSE, -1)

/obj/structure/capturepoint_shower
	name = "\improper grand orb"
	desc = "A relic of a former age. It hums with the power of ancient quackery."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "shower"
	resistance_flags = INDESTRUCTIBLE
	maptext_width = 64
	maptext_x = -16
	maptext_y = 20
	light_color = "#fcb000b8"
	var/area/rogue/assault/assault

/obj/structure/capturepoint_shower/proc/DoShit()
	var/datum/game_mode/warmongers/C = SSticker.mode

	if(!istype(C.warmode, /datum/warmode/assault))
		return
	var/datum/warmode/assault/AS = C.warmode // hehe
	START_PROCESSING(SSfastprocess, src)

	set_light(4)

	var/area/A = get_area(src)
	if(istype(A, /area/rogue/assault))
		var/area/rogue/assault/ASS = A
		assault = ASS
		AS.showers += src
		
		name = "[uppertext(assault.name)] ASSAULT POINT"

/obj/structure/capturepoint_shower/process()
	var/datum/game_mode/warmongers/C = SSticker.mode
	if(!istype(C.warmode, /datum/warmode/assault))
		return
	var/datum/warmode/assault/ASS = C.warmode // hehe
	maptext_y = rand(18,22)
	maptext_x = rand(-18,-19)
	if(assault.holder == "Regimians")
		maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#c18700b8'>CAPTURED</font></div>"
	else
		if(ASS.current_capture_point == assault.capture_order || (ASS.current_capture_point == 0 && assault.capture_order == 0))
			maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#fcb000b8'>[assault.holder]\n[ASS.attack_progress]/[assault.tocapture_points]</font></div>"
		else
			maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#fcb000b8'>[assault.holder]\n0/[assault.tocapture_points]</font></div>"

// capture point navigation

/atom/movable/screen/navigate_arrow
	icon = 'icons/effects/96x96.dmi'
	name = "navigation sense"
	icon_state = "navigate_arrow_appear"
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = rogueui_advsetup
	alpha = 120
	var/atom/thing
	var/mob/owner

/atom/movable/screen/navigate_arrow/New(mob/ownera)
	. = ..()
	owner = ownera

/atom/movable/screen/navigate_arrow/process()
	if(owner)
		animate(src, 0.2 SECONDS, TRUE, transform = matrix(get_angle(owner, thing), MATRIX_ROTATE))

/atom/movable/screen/navigate_arrow/proc/start_effect(atom/thingo, arrow_color, duration = INFINITY)
	START_PROCESSING(SSfastprocess, src)
	thing = thingo
	color = arrow_color
	if(duration != INFINITY)
		addtimer(CALLBACK(src, PROC_REF(end_effect)), duration)

/atom/movable/screen/navigate_arrow/proc/end_effect()
	icon_state = "navigate_arrow_disappear"
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_IN(src, 0.4 SECONDS)