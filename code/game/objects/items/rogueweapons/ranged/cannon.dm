// immovable cannons. no hand cannons, sorry. (jk)

/obj/structure/cannon // cannon
	name = "barkstone"
	desc = "A large weapon, mounted up on heavy-duty tracks, making it somewhat easy to move around even the roughest terrain."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "cannona"
	anchored = FALSE
	density = TRUE
	max_integrity = 9999
	drag_slowdown = 1 // If it took so long it would be not really fun.
	w_class = WEIGHT_CLASS_GIGANTIC // INSTANTLY crushed
	var/shootingdown = FALSE // if we are shooting one tile infront of us below (if its an open space)
	var/obj/item/ammo_casing/caseless/rogue/cball/loaded

	var/fireangle = 0 // straight forward

	var/obj/effect/point/indicator
	var/last_scroll_time = 0

/obj/structure/cannon/proc/update_indicator()
	if(!indicator || QDELETED(indicator))
		indicator = new(src)
	indicator.forceMove(get_turf(src))
	indicator.alpha = 255
	indicator.pixel_y = 10

	var/matrix/M = matrix()
	var/true_angle = fireangle + dir2angle(dir)

	M.Turn(true_angle)
	indicator.transform = M

/obj/structure/cannon/proc/start_indicator_timeout()
	var/current_scroll_time = last_scroll_time

	spawn(3 SECONDS)
		if(last_scroll_time == current_scroll_time)
			animate(indicator, 10, alpha = 0)
			sleep(10)
			qdel(indicator)

/obj/structure/cannon/MouseWheel(delta_x, delta_y, location, control, params)
	. = ..()
	var/mob/M = usr
	if(!M)
		return

	if(delta_y > 0)
		fireangle += 5
	else
		fireangle -= 5
	fireangle = clamp(fireangle, -30, 30)
	last_scroll_time = world.time

	update_indicator()
	start_indicator_timeout()

	to_chat(M, "<span class='info'>...[fireangle]...</span>")

/obj/structure/cannon/examine(mob/user)
	. = ..()
	if(loaded)
		. += "<span class='info'>It is loaded.</span>"
	if(shootingdown)
		. += "<span class='danger'>It will shoot the things below.</span>"
	. += "<span class='tutorial'>Use mouse wheel to change direction you're firing in.</span>"
	. += "<span class='tutorial'>Load with big lead balls, then use a torch, lantern or flint to fire.</span>"
	. += "<span class='tutorial'>Use rightclick to make it shoot at the tile below if infront of an open space.</span>"

/obj/structure/cannon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_casing/caseless/rogue/cball))
		if(loaded)
			return
		user.visible_message("<span class='notice'>\The [user] begins loading \the [I] into \the [src].</span>")
		playsound(src, 'sound/combat/cannon_loading.ogg', 35)
		if(!do_after(user, 5 SECONDS, TRUE, src))
			return
		user.dropItemToGround(I, TRUE, TRUE)
		I.forceMove(src)
		loaded = I
		user.visible_message("<span class='notice'>\The [user] loads \the [I] into \the [src].</span>")
		playsound(src, 'sound/foley/trap_arm.ogg', 65)
	if(istype(I, /obj/item/flashlight/flare/torch))
		var/obj/item/flashlight/flare/torch/LR = I
		if(!loaded || !SSwarmongers.warfare_ready_to_die)
			to_chat(user, "<span class='danger'>No, that would be stupid.</span>")
			return
		if(LR.on)
			playsound(src.loc, 'sound/items/firelight.ogg', 100)
			if(shootingdown)
				var/step = get_step(src, dir)
				if(!istype(step, /turf/open/transparent/openspace))
					to_chat(user, "<span class='danger'>IT'S SHOOTING DOWN! I'LL BLOW MYSELF UP!</span>")
			if(do_after(user, 0.6 SECONDS, TRUE, src))
				user.visible_message("<span class='danger'>\The [user] lights \the [src]!</span>")
				fire(user)
	if(istype(I, /obj/item/flint))
		var/obj/item/flint/F = I
		if(!loaded || !SSwarmongers.warfare_ready_to_die)
			to_chat(user, "<span class='danger'>No, that would be stupid.</span>")
			return
		F.afterattack(src, user, TRUE)
		playsound(src.loc, 'sound/items/firelight.ogg', 100)
		if(shootingdown)
			var/step = get_step(src, dir)
			if(!istype(step, /turf/open/transparent/openspace))
				to_chat(user, "<span class='danger'>IT'S SHOOTING DOWN! I'LL BLOW MYSELF UP!</span>")
		if(do_after(user, 0.6 SECONDS, TRUE, src))
			user.visible_message("<span class='danger'>\The [user] lights \the [src]!</span>")
			fire(user)
	else
		return ..()

/obj/structure/cannon/attack_right(mob/user)
	. = ..()
	if(!SSwarmongers.warfare_ready_to_die)
		to_chat(user, "<span class='danger'>Why in the world would I ever do that? Why would I waste time pointing it down if I can't even use it to kill the enemy right now?</span>")
		return
	if(!shootingdown)
		visible_message("<span class='info'>[user] begins tilting \the [src] to point down.</span>", "<span class='info'>I begin tilting \the [src] to point down a little...</span>")
	else
		visible_message("<span class='info'>[user] begins tilting \the [src] to point up.</span>", "<span class='info'>I begin tilting \the [src] to point up a little...</span>")
	if(do_after(user, 3  SECONDS, TRUE, src))
		shootingdown = !shootingdown
		playsound(src.loc, 'sound/foley/winch.ogg', 100, extrarange = 3)

/obj/structure/cannon/proc/fire(var/mob/firer)
	if(!loaded)
		return
	for(var/mob/living/carbon/H in hearers(7, src))
		shake_camera(H, 6, 5)
		H.blur_eyes(4)
		firearm_recoil_camera(H, 2, 5, dir)
		if(prob(30))
			H.playsound_local(get_turf(H), 'sound/foley/tinnitus.ogg', 45, FALSE)
	for(var/mob/living/carbon/human/H in get_step(src, turn(dir, 180)))
		var/turf/turfa = get_ranged_target_turf(src, turn(dir, 180), 4)
		H.throw_at(turfa, 40, 1, null, FALSE)
		H.take_overall_damage(45)
		H.unlock_achievement(new /datum/achievement/backblast())
		visible_message("<span class='danger'>\The [H] is thrown back from \the [src]'s recoil!</span>")
	flick("cannona_firea", src)

	var/turfina = get_turf(src)
	if(shootingdown)
		var/step = get_step(src, dir)
		if(istype(step, /turf/open/transparent/openspace))
			turfina = get_step_multiz(step, DOWN)
		else
			explosion(get_turf(src), heavy_impact_range = 4, light_impact_range = 6, flame_range = 0, smoke = TRUE, soundin = pick('sound/misc/explode/bottlebomb (1).ogg','sound/misc/explode/bottlebomb (2).ogg','sound/misc/explode/bottlebomb (3).ogg'))

	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z,src.z))
			continue
		var/turf/M_turf = get_turf(M)
		var/far_smith_sound = sound(pick('sound/ambience/distantcannon1.ogg','sound/ambience/distantcannon2.ogg','sound/ambience/distantcannon3.ogg'))
		if(M_turf)
			var/dist = get_dist(M_turf, loc)
			if(dist < 7)
				continue
			M.playsound_local(M_turf, null, 100, 1, get_rand_frequency(), falloff = 1, S = far_smith_sound)
	playsound(src.loc, 'sound/misc/explode/explosion.ogg', 100, FALSE, 6)
	new /obj/effect/particle_effect/smoke(get_turf(src))
	sleep(4)

	var/true_angle = fireangle + dir2angle(dir)

	var/obj/projectile/fired_projectile = new loaded.projectile_type(turfina)

	fired_projectile.preparePixelProjectile(get_step(src, dir), src)
	fired_projectile.firer = firer
	fired_projectile.fired_from = src
	fired_projectile.fire(true_angle)
	QDEL_NULL(loaded)

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/handcannon // for the memes
	name = "hand barkstone"
	desc = "HOLY FUCK!"
	fire_sound = 'sound/misc/explode/explosion.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musk/cannona
	dropshrink = 0.5

/obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/handcannon/update_icon()
	icon_state = "cannona"

/obj/item/ammo_box/magazine/internal/shot/musk/cannona
	ammo_type = /obj/item/ammo_casing/caseless/rogue/cball
	caliber = "cannoball"
	max_ammo = 1
	start_empty = TRUE

// artillery (fucking OP)

/obj/structure/bombard
	name = "bombtard"
	desc = "A metal tube capable of launching bombs high into the sky at an angle to come crashing down on the foe, even if they cower behind cover."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "bombardier"
	anchored = FALSE
	density = TRUE
	max_integrity = 9999
	drag_slowdown = 1 // If it took so long it would be not really fun.
	w_class = WEIGHT_CLASS_GIGANTIC // INSTANTLY crushed
	var/plusy = 0 // no pussy jokes.
	var/firing = FALSE
	var/obj/item/rogue/bomb/loaded

/obj/structure/bombard/alt // regime
	name = "mortard"
	desc = "A metallic-like tube capable of launching bombs high into the clouds at an angle to come crashing down on the fellows or foes depending on your mood, even if they cover behind cower."
	icon_state = "bombardier_alt"
	
/obj/structure/bombard/Moved(atom/OldLoc, Dir)
	. = ..()
	switch(Dir)
		if(NORTH)
			plusy = abs(plusy)
		if(SOUTH)
			plusy = -abs(plusy)

/obj/structure/bombard/MiddleClick(mob/user, params)
	if(ishuman(user))
		var/oldy = y
		var/newy = oldy + plusy
		var/turf/epicenter = locate(x,newy,z)

		if(!epicenter)
			to_chat(user, "<span class='danger'>I can't see shit. These coordinates must be bad.</span>")
			return

		if(epicenter.density)
			to_chat(user, "<span class='danger'>I can't see shit. I can't just shoot inside a solid object..</span>")
			return

		if(istype(epicenter, /turf/open/transparent/openspace))
			epicenter = get_step_multiz(epicenter, DOWN)
		var/area/rogue/A = get_area(epicenter)
		if(A.safe_from_mortar)
			to_chat(user, "<span class='danger'>I can't see shit. Seems like I can't shoot there.</span>")
			return

		to_chat(user, "<span class='notice'>I try to look through the magnifying glass on \the [src].</span>")
		if(do_after(user, 2 SECONDS, TRUE, src))
			// these vars are reset automatically when a person tries to move
			user.client.eye = epicenter
			user.client.perspective = EYE_PERSPECTIVE
			user.update_cone_show()
			user.RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, TYPE_PROC_REF(/mob/living, stop_looking))

/obj/structure/bombard/examine(mob/user)
	. = ..()
	if(plusy)
		. += "<span class='info'>The azirath is set to [plusy]. Which means it will shoot [plusy] urists the direction it is facing.</span>"
	if(loaded)
		. += "<span class='info'>It is loaded.</span>"
	. += "<span class='tutorial'>Use rightclick to change the amount of tiles it will fire the direction it is facing in.</span>"
	. += "<span class='tutorial'>Use middleclick to see what tile you're aiming at.</span>"
	. += "<span class='tutorial'>Load with bombs.</span>"

/obj/structure/bombard/attack_right(mob/user)
	. = ..()
	var/agka = input(user, "Insert azirath for target (pyrimuth equals location of bombardier)", "WARMONGERS") as null|num
	if(isnull(agka))
		return

	agka = abs(agka)

	var/target_y = y

	switch(dir)
		if(NORTH)
			target_y = y + agka
		if(SOUTH)
			target_y = y - agka

	target_y = clamp(target_y, 1, world.maxy)
	plusy = target_y - y

	to_chat(user, "<span class='info'>New Target: [target_y] azirath</span>")
	playsound(src, 'sound/misc/keyboard_enter.ogg', 100, FALSE, -1)

/obj/structure/bombard/attackby(obj/item/I, mob/user, params)
	if(dir == WEST || dir == EAST)
		to_chat(user, "<span class='warning'>Shooting that direction would be a waste of resources.</span>")
		return
	if(istype(I, /obj/item/ammo_casing/caseless/rogue/cball))
		to_chat(user, "<span class='warning'>It won't work, I need a bomb.</span>")
		return
	if(istype(I, /obj/item/rogue/bomb))
		if(loaded)
			return
		user.visible_message("<span class='notice'>\The [user] begins loading \the [I] into \the [src].</span>")
		playsound(src, 'sound/combat/cannon_loading.ogg', 35)
		if(!do_after(user, 5 SECONDS, TRUE, src))
			return
		user.dropItemToGround(I, TRUE, TRUE)
		I.forceMove(src)
		loaded = I
		user.visible_message("<span class='notice'>\The [user] loads \the [I] into \the [src].</span>")
		playsound(src, 'sound/foley/trap_arm.ogg', 65)
	if(istype(I, /obj/item/flashlight/flare/torch))
		var/obj/item/flashlight/flare/torch/LR = I
		if(firing)
			to_chat(user, "<span class='danger'>I caught up with you, bastard. You're stupid. You can't do that.</span>")
			return
		if(!loaded || !SSwarmongers.warfare_ready_to_die)
			to_chat(user, "<span class='danger'>No, that would be stupid.</span>")
			return
		if(LR.on)
			playsound(src.loc, 'sound/items/firelight.ogg', 100)
			user.visible_message("<span class='danger'>\The [user] lights \the [src]!</span>")
			fire()
	if(istype(I, /obj/item/flint))
		var/obj/item/flint/F = I
		if(firing)
			to_chat(user, "<span class='danger'>I caught up with you, bastard. You're stupid. You can't do that.</span>")
			return
		if(!loaded || !SSwarmongers.warfare_ready_to_die)
			to_chat(user, "<span class='danger'>No, that would be stupid.</span>")
			return
		F.afterattack(src, user, TRUE)
		playsound(src.loc, 'sound/items/firelight.ogg', 100)
		user.visible_message("<span class='danger'>\The [user] lights \the [src]!</span>")
		fire()
	else
		return ..()

/obj/structure/bombard/proc/fire()
	var/oldy = y
	var/newy = oldy + plusy

	var/turf/epicenter = locate(x,newy,z)
	if(istype(epicenter, /turf/open/transparent/openspace))
		epicenter = epicenter.below()
	var/area/rogue/A = get_area(epicenter)

	if(A.safe_from_mortar)
		sleep(2)
		visible_message("<span class='danger'>\The [src] stutters and sputters! Seems like there's some ancient force preventing anything being bombarded on the target coordinates...</span>")
		return
	
	if(!epicenter || epicenter.density)
		sleep(2)
		visible_message("<span class='danger'>\The [src] stutters and sputters!</span>")
		return
	
	firing = TRUE

	for(var/mob/living/carbon/H in hearers(7, src))
		shake_camera(H, 1, 1)
		H.blur_eyes(4)
		if(prob(30))
			H.playsound_local(get_turf(H), 'sound/foley/tinnitus.ogg', 45, FALSE)
	for(var/mob/living/carbon/human/H in get_step(src, turn(dir, 180)))
		var/turf/turfa = get_ranged_target_turf(src, turn(dir, 180), 2)
		H.throw_at(turfa, 10, 1, null, FALSE)
		H.take_overall_damage(45)
		H.unlock_achievement(new /datum/achievement/backblast())
		visible_message("<span class='danger'>\The [H] is thrown back from \the [src]'s recoil!</span>")
	flick("[initial(icon_state)]_firea", src)
	playsound(src.loc, 'sound/misc/explode/explosion.ogg', 100, FALSE)

	var/obj/effect/warning/G = new(epicenter)

	playsound(epicenter, pick('sound/ambience/rocketfire.ogg','sound/ambience/rocketfire2.ogg'), 100, FALSE, 5)

	spawn(2.1 SECONDS)
		qdel(G)
		loaded.forceMove(epicenter)
		loaded.light()
		loaded.explode(TRUE)
		firing = FALSE
		QDEL_NULL(loaded)

	var/angle
	switch(dir)
		if(NORTH) angle = 90
		if(SOUTH) angle = 270
		if(EAST)  angle = 0
		if(WEST)  angle = 180
	angle += rand(-15, 15)

	var/px = round(64 * cos(angle))
	var/py = round(64 * sin(angle))

	var/obj/effect/temp_visual/small_smoke/gunsmoke/S = new(get_turf(src))
	var/matrix/ARE = matrix()
	ARE.Scale(4, 4)
	ARE.Turn(rand(50,350))
	animate(S, time = 50, alpha = 0, pixel_x = px, pixel_y = py, transform = ARE, easing = SINE_EASING)

	//new /obj/effect/particle_effect/smoke(get_turf(src)) // i want to show the cool animation

// maxim bb gun

/obj/structure/maxim
	name = "\improper Gatlyn's Crankbox"
	desc = "A rapid firing, crank-operated barker mounted on a wheeled carriage so it can be quickly moved around the battlefield."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "machina"
	anchored = FALSE
	density = TRUE
	max_integrity = 9999
	drag_slowdown = 2 // If it took so long it would be not really fun.
	w_class = WEIGHT_CLASS_GIGANTIC // INSTANTLY crushed
	var/list/firesounds = list('sound/combat/Ranged/firebow-shot-01.ogg', 'sound/combat/Ranged/firebow-shot-02.ogg', 'sound/combat/Ranged/firebow-shot-03.ogg')
	var/bullets = 0 // starts with zero
	var/maxima_bulletina = 50
	var/fireangle = 0 // straight forward

	var/obj/effect/point/indicator
	var/last_scroll_time = 0

/obj/structure/maxim/alt
	name = "\improper KAITZAR's Organ"
	desc = "A six-shot firing, crank-operated barker mounted on a wheeled carriage so it can be quickly moved around the battlefield. Nicknamed the 'One man firing squad' by Regimers. Popular method of execution in the capital."
	icon_state = "machina2"
	maxima_bulletina = 18

/obj/structure/maxim/alt/attack_hand(mob/user)
	if(prob(1))
		to_chat(user, "<span class='info'>The trigger got stuck... try again!</span>")
		playsound(src.loc, 'sound/foley/muskclick.ogg', 100, FALSE)
		return
	for(var/i=0,i<6,i++)
		sleep(rand(1,4))
		fire(user)

/obj/structure/maxim/attackby(obj/item/I, mob/user, params)
	if(bullets >= maxima_bulletina)
		to_chat(user, "<span class='info'>None fit anymore.</span>")
		return
	if(istype(I, /obj/item/ammo_casing/caseless/rogue/bullet))
		to_chat(user, "<span class='notice'>You begin crushing up the ball...</span>")
		if(do_after(user, 5 SECONDS, TRUE, src))
			to_chat(user, "<span class='info'>You break the ball into five small pellets and load them into the machine.</span>")
			playsound(src, 'sound/foley/trap_arm.ogg', 65)
			bullets += 5
			user.dropItemToGround(I, TRUE, TRUE)
			qdel(I)
	if(istype(I, /obj/item/ammo_casing/caseless/rogue/cball))
		to_chat(user, "<span class='notice'>Too big to fit... you'll need to smash that.</span>") // Nobody is gonna get this, but this is a reference to There is No Game: Wrong Dimension in the credits level!
	if(istype(I, /obj/item/rogue/maxim_ammo))
		playsound(src, 'sound/foley/trap_arm.ogg', 65)
		bullets += 25
		bullets = min(bullets,maxima_bulletina)
		user.dropItemToGround(I, TRUE, TRUE)
		qdel(I)

/obj/structure/maxim/examine(mob/user)
	. = ..()
	if(bullets)
		. += "<span class='info'>It is loaded. ([bullets])</span>"
	. += "<span class='tutorial'>Use mouse wheel to change direction you're firing in.</span>"
	. += "<span class='tutorial'>Load with lead balls or smashed up big lead balls.</span>"

/obj/structure/maxim/proc/fire(mob/user)
	if(!bullets)
		playsound(src.loc, 'sound/foley/muskclick.ogg', 100, FALSE)
		return
	var/turf/T = get_turf(src)
	//var/turf/target = get_ranged_target_turf(src, dir, 7) // seven7
	var/turf/target = get_step(src, dir)
	var/obj/projectile/bullet/reusable/bullet/maxim/A = new(T)
	A.muzzle_type = null // Fuck you.
	
	var/true_angle = fireangle + dir2angle(dir)
	flick("[initial(icon_state)]_firea", src)
	playsound(src.loc, pick(firesounds), 100, FALSE)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.lying)
			firearm_recoil_camera(H, 1, 1, angle2dir(true_angle))

	A.preparePixelProjectile(target, T)
	A.firer = user
	A.fired_from = src
	A.fire(true_angle - rand(5,-5))
	bullets--

	//new /obj/effect/temp_visual/small_smoke/halfsecond(get_turf(src))

	var/angle
	switch(dir)
		if(NORTH) angle = 90
		if(SOUTH) angle = 270
		if(EAST)  angle = 0
		if(WEST)  angle = 180
	angle += rand(-15, 15)

	var/px = round(64 * cos(angle))
	var/py = round(64 * sin(angle))

	var/obj/effect/temp_visual/small_smoke/gunsmoke/S = new(get_turf(src))
	var/matrix/ARE = matrix()
	ARE.Scale(0.8, 0.8)
	ARE.Turn(rand(50,350))
	animate(S, time = 10, alpha = 0, pixel_x = px, pixel_y = py, transform = ARE, easing = SINE_EASING)

/obj/structure/maxim/attack_hand(mob/user)
	if(prob(1))
		to_chat(user, "<span class='info'>The trigger got stuck... try again!</span>")
		playsound(src.loc, 'sound/foley/muskclick.ogg', 100, FALSE)
		return
	fire(user)

/obj/structure/maxim/proc/update_indicator()
	if(!indicator || QDELETED(indicator))
		indicator = new(src)
	indicator.forceMove(get_turf(src))
	indicator.alpha = 255
	indicator.pixel_y = 10

	var/matrix/M = matrix()
	var/true_angle = fireangle + dir2angle(dir)

	M.Turn(true_angle)
	indicator.transform = M

/obj/structure/maxim/proc/start_indicator_timeout()
	var/current_scroll_time = last_scroll_time

	spawn(3 SECONDS)
		if(last_scroll_time == current_scroll_time)
			animate(indicator, 10, alpha = 0)
			sleep(10)
			qdel(indicator)

/obj/structure/maxim/MouseWheel(delta_x, delta_y, location, control, params)
	. = ..()
	var/mob/M = usr
	if(!M)
		return

	if(delta_y > 0)
		fireangle += 5
	else
		fireangle -= 5
	fireangle = clamp(fireangle, -45, 45)
	last_scroll_time = world.time

	update_indicator()
	start_indicator_timeout()

	to_chat(M, "<span class='info'>...[fireangle]...</span>")