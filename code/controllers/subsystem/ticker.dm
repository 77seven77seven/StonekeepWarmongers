#define ROUND_START_MUSIC_LIST "string/round_start_sounds.txt"


GLOBAL_VAR_INIT(round_timer, INITIAL_ROUND_TIMER)

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/current_state = GAME_STATE_STARTUP	//state of current round (used by process()) Use the defines GAME_STATE_* !
	var/force_ending = 0					//Round was ended by admin intervention
	// If true, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE
	var/setup_done = FALSE //All game setup done including mode post setup and

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/datum/round_aspect/round_aspect = null
	var/forcing_aspect = FALSE

	var/login_music							//music played in pregame lobby
	var/round_end_sound						//music/jingle played when the world reboots
	var/round_end_sound_sent = TRUE			//If all clients have loaded it

	var/warfare_ready_to_die = FALSE		// If the barriers for fair play have been removed yet.
	var/warfare_techlevel = WARMONGERS_TECHLEVEL_FLINTLOCKS

	var/oneteammode = FALSE // players only allowed to choose grenzelhoft

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.

	var/delay_end = 0						//if set true, the round will not restart on it's own
	var/admin_delay_notice = ""				//a message to display to anyone who tries to restart the world after a delay
	var/ready_for_reboot = FALSE			//all roundend preparation done with, all that's left is reboot

	var/triai = 0							//Global holder for Triumvirate
	var/tipped = 0							//Did we broadcast the tip of the day yet?
	var/selected_tip						// What will be the tip of the day?

	var/timeLeft						//pregame timer
	var/start_at
	//576000 dusk
	//376000 day
	var/gametime_offset = 288001		//Deciseconds to add to world.time for station time.
	var/station_time_rate_multiplier = 50		//factor of station time progressal vs real time.
	var/time_until_vote = 120 MINUTES
	var/last_vote_time = null
	var/firstvote = TRUE

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap

	var/maprotatechecked = 0

	var/news_report

	var/late_join_disabled

	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/round_start_irl = 0
	var/list/round_start_events
	var/list/round_end_events
	var/mode_result = "undefined"
	var/end_state = "undefined"
	var/job_change_locked = FALSE
	var/list/royals_readied = list()
	var/rulertype = "King" // reports whether king or queen rules
	var/rulermob = null // reports what the ruling mob is.
	var/failedstarts = 0
	var/list/manualmodes = list()

	//**ROUNDEND STATS**
	var/deaths = 0			//total deaths in the round

	var/heartfelt_deaths = 0
	var/grenzelhoft_deaths = 0

	var/blood_lost = 0
	var/tri_gained = 0
	var/tri_lost = 0
	var/list/cuckers = list()
	var/cums = 0
	var/musketsshot = 0

	var/end_party = FALSE
	var/last_lobby = 0

/datum/controller/subsystem/ticker/Initialize(timeofday)
	load_mode()

	var/list/byond_sound_formats = list(
		"mid"  = TRUE,
		"midi" = TRUE,
		"mod"  = TRUE,
		"it"   = TRUE,
		"s3m"  = TRUE,
		"xm"   = TRUE,
		"oxm"  = TRUE,
		"wav"  = TRUE,
		"ogg"  = TRUE,
		"raw"  = TRUE,
		"wma"  = TRUE,
		"aiff" = TRUE
	)

	var/list/provisional_title_music = flist("[global.config.directory]/title_music/sounds/")
	var/list/music = list()
	var/use_rare_music = prob(1)

	for(var/S in provisional_title_music)
		var/lower = lowertext(S)
		var/list/L = splittext(lower,"+")
		switch(L.len)
			if(3) //rare+MAP+sound.ogg or MAP+rare.sound.ogg -- Rare Map-specific sounds
				if(use_rare_music)
					if(L[1] == "rare" && L[2] == SSmapping.config.map_name)
						music += S
					else if(L[2] == "rare" && L[1] == SSmapping.config.map_name)
						music += S
			if(2) //rare+sound.ogg or MAP+sound.ogg -- Rare sounds or Map-specific sounds
				if((use_rare_music && L[1] == "rare") || (L[1] == SSmapping.config.map_name))
					music += S
			if(1) //sound.ogg -- common sound
				if(L[1] == "exclude")
					continue
				music += S

//	var/old_login_music = trim(file2text("data/last_round_lobby_music.txt"))
//	if(music.len > 1)
//		music -= old_login_music

	for(var/S in music)
		var/list/L = splittext(S,".")
		if(L.len >= 2)
			var/ext = lowertext(L[L.len]) //pick the real extension, no 'honk.ogg.exe' nonsense here
			if(byond_sound_formats[ext])
				continue
		music -= S

	if(isemptylist(music))
		music = world.file2list(ROUND_START_MUSIC_LIST, "\n")
		login_music = pick(music)
	else
		login_music = "[global.config.directory]/title_music/sounds/[pick(music)]"

	login_music = pick('sound/music/dreadfulstench.ogg','sound/music/practiceofwar.ogg','sound/music/faceoff.ogg')

	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase	= generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match

	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	if(CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = rand(0, 23) HOURS
	else if(CONFIG_GET(flag/shift_time_realtime))
		gametime_offset = world.timeofday
	return ..()

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
//			if(Master.initializations_finished_with_no_players_logged_in)
//			start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			for(var/client/C in GLOB.clients)
				window_flash(C, ignorepref = TRUE) //let them know lobby has opened up.
//			to_chat(world, "<span class='boldnotice'>Welcome to [station_name()]!</span>")
//			send2chat(new /datum/tgs_message_content("New round starting on [SSmapping.config.map_name]!"), CONFIG_GET(string/chat_announce_new_game))
			current_state = GAME_STATE_PREGAME
			//Everyone who wants to be an observer is now spawned
			create_observers()
			fire()
		if(GAME_STATE_PREGAME)
			//lobby stats for statpanels
			if(isnull(timeLeft))
				timeLeft = max(0,start_at - world.time)
			totalPlayers = LAZYLEN(GLOB.new_player_list)
			totalPlayersReady = 0
			for(var/i in GLOB.new_player_list)
				var/mob/dead/new_player/player = i
				if(player.ready == PLAYER_READY_TO_PLAY)
					++totalPlayersReady

			if(start_immediately)
				timeLeft = 0

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
#ifdef MATURESERVER
				send_tip_of_the_round()
#endif
				tipped = TRUE

			if(timeLeft <= 0)
				send2chat(new /datum/tgs_message_content("New round starting on [SSmapping.config.map_name]!"), CONFIG_GET(string/chat_announce_new_game))
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				start_at = world.time + 600
				timeLeft = null
				Master.SetRunLevel(RUNLEVEL_LOBBY)

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)
			check_queue()
			check_maprotate()

			if(!roundend_check_paused && mode.check_finished(force_ending) || force_ending)
				current_state = GAME_STATE_FINISHED
				toggle_ooc(TRUE) // Turn it on
				toggle_dooc(TRUE)
				declare_completion(force_ending)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)
			/*
			if(firstvote)
				if(world.time > round_start_time + time_until_vote)
					SSvote.initiate_vote("endround", "The Gods")
					time_until_vote = 40 MINUTES
					last_vote_time = world.time
					firstvote = FALSE
			else
				if(world.time > last_vote_time + time_until_vote)
					SSvote.initiate_vote("endround", "The Gods")
			*/

/datum/controller/subsystem/ticker
	var/last_bot_update = 0

/datum/controller/subsystem/ticker/proc/checkreqroles()
	var/list/readied_jobs = list()
	var/list/required_jobs = list("Queen","King")
#ifdef DEPLOY_TEST
	required_jobs = list()
	readied_jobs = list("King")
#endif
#ifdef ROGUEWORLD
	required_jobs = list()
#endif
	for(var/V in required_jobs)
		for(var/mob/dead/new_player/player in GLOB.player_list)
			if(!player)
				continue
			if(player.client.prefs.job_preferences[V] == JP_HIGH)
				if(player.ready == PLAYER_READY_TO_PLAY)
					if(player.client.prefs.lastclass == V)
						if(player.IsJobUnavailable(V) != JOB_AVAILABLE)
							to_chat(player, "<span class='warning'>You cannot be [V] and thus are not considered.</span>")
							continue
					readied_jobs.Add(V)
	if(("King" in readied_jobs) || ("Queen" in readied_jobs))
		if("King" in readied_jobs)
			rulertype = "King"
		else
			rulertype = "Queen"
	else
		var/list/stuffy = list("Set a Ruler to 'high' in your class preferences to start the game!", "PLAY Ruler NOW!", "A Ruler is required to start.", "Pray for a Ruler.", "One day, there will be a Ruler.", "Just try playing Ruler.", "If you don't play Ruler, the game will never start.", "We need at least one Ruler to start the game.", "We're waiting for you to pick Ruler to start.", "Still no Ruler is readied..", "I'm going to lose my mind if we don't get a Ruler readied up.","No. The game will not start because there is no Ruler.","What's the point of ROGUETOWN without a Ruler?")
		to_chat(world, "<span class='purple'>[pick(stuffy)]</span>")
		return FALSE

#ifdef DEPLOY_TEST
	var/amt_ready = 999
#else
	var/amt_ready = 0
#endif

#ifdef ROGUEWORLD
	amt_ready = 999
#endif

	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(!player)
			continue
		if(player.ready == PLAYER_READY_TO_PLAY)
			amt_ready++
	if(amt_ready < 2)
		to_chat(world, "<span class='purple'>[amt_ready]/2 players ready.</span>")
/*		failedstarts++
		if(failedstarts > 7)
			to_chat(world, "<span class='purple'>[failedstarts]/13</span>")
		if(failedstarts >= 13)
			to_chat(world, "<span class='greentext'>Starting ROGUEFIGHT...</span>")
			var/icon/ikon
			var/file_path = "icons/roguefight_title.dmi"
			ASSERT(fexists(file_path))
			ikon = new(fcopy_rsc(file_path))
			if(SStitle.splash_turf && ikon)
				SStitle.splash_turf.icon = ikon
			for(var/mob/dead/new_player/player in GLOB.player_list)
				player.playsound_local(player, 'sound/music/wartitle.ogg', 100, TRUE)*/
		return FALSE
	job_change_locked = TRUE
	return TRUE

/datum/controller/subsystem/ticker
	var/isroguefight = FALSE
	var/isrogueworld = FALSE

/proc/aspect_chosen(datum/round_aspect/aspect)
	if(istype(SSticker.round_aspect, aspect))
		return TRUE

/datum/controller/subsystem/ticker/proc/pickaspect()
	if(!forcing_aspect)
		var/list/possibilities = list()
		for(var/thing in subtypesof(/datum/round_aspect))//Populate possible aspects list.
			var/datum/round_aspect/A = thing
			if(!A.adminonly)
				possibilities += A
		var/chosen = pick(possibilities)
		round_aspect = new chosen
		round_aspect.apply()

/datum/controller/subsystem/ticker/proc/setup()
	message_admins("<span class='boldannounce'>Starting game...</span>")
	var/init_start = world.timeofday
		//Create and announce mode
	var/list/datum/game_mode/runnable_modes
	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		runnable_modes = config.get_runnable_modes()

		if(GLOB.master_mode == "secret")
			hide_mode = 1
			if(GLOB.secret_force_mode != "secret")
				var/datum/game_mode/smode = config.pick_mode(GLOB.secret_force_mode)
				if(!smode.can_start())
					message_admins("<span class='notice'>Unable to force secret [GLOB.secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.</span>")
				else
					mode = smode

		if(!mode)
			if(!runnable_modes.len)
				message_admins("<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
				return 0
			mode = pickweight(runnable_modes)
			if(!mode)	//too few roundtypes all run too recently
				mode = pick(runnable_modes)

	else
		mode = config.pick_mode(GLOB.master_mode)
		if(!mode.can_start())
			message_admins("<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players and [mode.required_enemies] eligible antagonists needed. Reverting to pre-game lobby.")
			qdel(mode)
			mode = null
			SSjob.ResetOccupations()
			return 0

//	if(failedstarts >= 13)
//		qdel(mode)
//		mode = new /datum/game_mode/roguewar
//		if(istype(C, /datum/game_mode/chaosmode))
//			if(isrogueworld)
//				C.allmig = TRUE
//		else
//
//			else
//				C.roguefight = TRUE
//				isroguefight = TRUE

#ifdef ROGUEWORLD
	if(mode)
		if(istype(mode, /datum/game_mode/chaosmode))
			var/datum/game_mode/chaosmode/C = mode
			isrogueworld = TRUE
			C.allmig = TRUE
#endif

	CHECK_TICK
	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	can_continue = src.mode.pre_setup()		//Choose antagonists
	CHECK_TICK

//	if(istype(mode, /datum/game_mode/roguewar))
//		unready_all()

	CHECK_TICK

	can_continue = can_continue && SSjob.DivideOccupations(mode.required_jobs) 				//Distribute jobs
	CHECK_TICK

	src.mode.after_DO()

	if(!GLOB.Debug2)
		if(!can_continue)
			log_game("[mode.name] failed pre_setup, cause: [mode.setup_error]")
			QDEL_NULL(mode)
			message_admins("<B>Error setting up [GLOB.master_mode].</B> Reverting to pre-game lobby.")
			SSjob.ResetOccupations()
			return 0
	else
		message_admins("<span class='notice'>DEBUG: Bypassing prestart checks...</span>")

	log_game("GAME SETUP: Divide Occupations success")

	CHECK_TICK
//	if(hide_mode)
//		var/list/modes = new
//		for (var/datum/game_mode/M in runnable_modes)
//			modes += M.name
//		modes = sortList(modes)
//		message_admins("<b>The gamemode is: secret!\nPossibilities:</B> [english_list(modes)]")
//	else
//		mode.announce()

	if(!CONFIG_GET(flag/ooc_during_round))
		toggle_ooc(FALSE) // Turn it off

	CHECK_TICK
	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	if(!isrogueworld && !isroguefight)
		create_characters() //Create player characters
		log_game("GAME SETUP: create characters success")
		collect_minds()
		log_game("GAME SETUP: collect minds success")
		equip_characters()
		log_game("GAME SETUP: equip characters success")

		GLOB.data_core.manifest()
		log_game("GAME SETUP: manifest success")

		transfer_characters()	//transfer keys to the new mobs
		log_game("GAME SETUP: transfer characters success")

	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()

	log_game("GAME SETUP: round start events success")
	LAZYCLEARLIST(round_start_events)
	SSrole_class_handler.RoundStart()
	CHECK_TICK
	if(isrogueworld)
		for(var/obj/structure/fluff/traveltile/TT in GLOB.traveltiles)
			if(TT.aallmig)
				TT.aportalgoesto = TT.aallmig
		for(var/i in GLOB.mob_living_list)
			var/mob/living/L = i
			var/turf/T = get_turf(L)
			if(!T || !(T.z in list(2,3,4,5)))
				continue
			qdel(L)
		for(var/i in SSmachines.processing)
			var/obj/machinery/light/L = i
			if(istype(L))
				var/turf/T = get_turf(L)
				if(!T || !(T.z in list(2,3,4,5)))
					continue
				qdel(L)

	log_game("GAME SETUP: Game start took [(world.timeofday - init_start)/10]s")
	round_start_time = world.time
	round_start_irl = REALTIMEOFDAY
//	SSshuttle.emergency.startTime = world.time
//	SSshuttle.emergency.setTimer(ROUNDTIMERBOAT)

	CHECK_TICK

	SSdbcore.SetRoundStart()
	pickaspect()

	to_chat(world, "<span class='notice'><span class='typewrite'>♔ Praise the Crown! ♔</span></span>")
	
	spawn(10)
		to_chat(world, "<span class='notice'>This battle's aspect is: [round_aspect.name]</span>")
		to_chat(world, "<span class='info'>[round_aspect.description]</span>")
	spawn(15)
		if(end_party)
			to_chat(world, "<span class='notice'><B>THIS IS THE FINAL STRUGGLE. DON'T LET THOSE BASTARDS WIN! IT'S NOW OR NEVER!!!</B></span>")
		if(oneteammode)
			to_chat(world, "<span class='notice'><B>This time you can only play as the Grenzelhofts.</B></span>")

	// handle setting the war mode for this round, this is retarded, but im too lazy to do it any other way
	var/datum/game_mode/warfare/W = mode
	if(findtext(SSmapping.config?.map_name, "PONR"))
		W.warmode = GAMEMODE_PONR
	if(findtext(SSmapping.config?.map_name, "LS"))
		W.warmode = GAMEMODE_STAND
	if(findtext(SSmapping.config?.map_name, "LD"))
		W.warmode = GAMEMODE_LORD

	CHECK_TICK

	for(var/client/C in GLOB.clients)
		if(oneteammode)
			C.warfare_faction = "Grenzelhofts"
		if(end_party)
			C.mob.playsound_local(C.mob, 'sound/warmongers.ogg', 70, FALSE)
		else
			C.mob.playsound_local(C.mob, 'sound/vote_start.ogg', 70, FALSE)

//	SEND_SOUND(world, sound('sound/misc/roundstart.ogg'))
	current_state = GAME_STATE_PLAYING

	CHECK_TICK

	Master.SetRunLevel(RUNLEVEL_GAME)
/*
	if(SSevents.holidays)
		to_chat(world, "<span class='notice'>and...</span>")
		for(var/holidayname in SSevents.holidays)
			var/datum/holiday/holiday = SSevents.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")
*/

	CHECK_TICK

	PostSetup()
	CHECK_TICK
	log_game("GAME SETUP: postsetup success")

	return TRUE

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	mode.post_setup()
	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	send2irc("Server", "Round [GLOB.round_id ? "#[GLOB.round_id]:" : "of"] [hide_mode ? "secret":"[mode.name]"] has started[allmins.len ? ".":" with no active admins online!"]")
	setup_done = TRUE

	job_change_locked = FALSE

//	setup_hell()
	SStriumphs.fire_on_PostSetup()
	for(var/i in GLOB.start_landmarks_list)
		var/obj/effect/landmark/start/S = i
		if(istype(S))							//we can not runtime here. not in this important of a proc.
			S.after_round_start()
		else
			stack_trace("[S] [S.type] found in start landmarks list, which isn't a start landmark!")


//These callbacks will fire after roundstart key transfer
/datum/controller/subsystem/ticker/proc/OnRoundstart(datum/callback/cb)
	if(!HasRoundStarted())
		LAZYADD(round_start_events, cb)
	else
		cb.InvokeAsync()

//These callbacks will fire before roundend report
/datum/controller/subsystem/ticker/proc/OnRoundend(datum/callback/cb)
	if(current_state >= GAME_STATE_FINISHED)
		cb.InvokeAsync()
	else
		LAZYADD(round_end_events, cb)

/datum/controller/subsystem/ticker/proc/station_explosion_detonation(atom/bomb)
	if(bomb)	//BOOM
		var/turf/epi = bomb.loc
		qdel(bomb)
		if(epi)
			explosion(epi, 0, 256, 512, 0, TRUE, TRUE, 0, TRUE)

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(!player)
			message_admins("THERES A FUCKING NULL IN THE NEW_PLAYER_LIST, REPORT IT TO STONEKEEP DEVELOPMENT STAFF NOW!")
			continue
		if(!player.mind)
			message_admins("THERES A MIND LACKING PLAYER IN THE NEW_PLAYER_LIST, REPORT IT TO STONEKEEP DEVELOPMENT STAFF NOW!")
			continue
		if(player.ready == PLAYER_READY_TO_PLAY)
			GLOB.joined_player_list += player.ckey
			player.create_character(FALSE)
		else
			player.new_player_panel()
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/select_ruler()
	switch(rulertype)
		if("King")
			for(var/mob/living/carbon/human/K in world)
				if(istype(K, /mob/living/carbon/human/dummy))
					continue
				if(K.job == "King")
					rulermob = K
					return
		if("Queen")
			for(var/mob/living/carbon/human/Q in world)
				if(istype(Q, /mob/living/carbon/human/dummy))
					continue
				if(Q.job == "Queen")
					rulermob = Q
					return

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/P = i
		if(P.new_character && P.new_character.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/equip_characters()
//	var/captainless=1
	var/list/valid_characters = list()
	for(var/mob/dead/new_player/new_player as anything in GLOB.new_player_list)
		var/mob/living/carbon/human/player = new_player.new_character
		if(istype(player) && player.mind?.assigned_role)
//			if(player.mind.assigned_role == "Captain")
//				captainless=0
			if(player.mind.assigned_role != player.mind.special_role)
				valid_characters[player] = new_player
	sortTim(valid_characters, GLOBAL_PROC_REF(cmp_assignedrole_dsc))
	for(var/mob/character as anything in valid_characters)
		var/mob/new_player = valid_characters[character]
		SSjob.EquipRank(new_player, character.mind.assigned_role, joined_late = FALSE)
		if(CONFIG_GET(flag/roundstart_traits) && ishuman(character))
			SSquirks.AssignQuirks(character, new_player.client, TRUE)
		CHECK_TICK
//	if(captainless)
//		for(var/i in GLOB.new_player_list)
//			var/mob/dead/new_player/N = i
//			if(N.new_character)
//				to_chat(N, "<span class='notice'>Captainship not forced on anyone.</span>")
//			CHECK_TICK

/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		var/mob/living = player.transfer_character()
		if(living)
			qdel(player)
			living.notransform = TRUE
			if(living.client)
				var/atom/movable/screen/splash/S = new(living.client, TRUE)
				S.Fade(TRUE)
			livings += living
	if(livings.len)
		addtimer(CALLBACK(src, PROC_REF(release_characters), livings), 30, TIMER_CLIENT_TIME)

/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE

/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	return
/*	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = world.file2list("string/tips.txt")
//		var/list/memetips = world.file2list("string/sillytips.txt")
//		if(randomtips.len && prob(95))
		m = pick(randomtips)
//		else if(memetips.len)
//			m = pick(memetips)
	if(m)
		to_chat(world, "<span class='purple'>Before we begin, remember: [html_encode(m)]</span>")
*/
/datum/controller/subsystem/ticker/proc/check_queue()
	if(!queued_players.len)
		return
	var/hpc = CONFIG_GET(number/hard_popcap)
	if(!hpc)
		listclearnulls(queued_players)
		for (var/mob/dead/new_player/NP in queued_players)
			to_chat(NP, "<span class='danger'>The alive players limit has been released!<br><a href='?src=[REF(NP)];late_join=override'>[html_encode(">>Join Game<<")]</a></span>")
			SEND_SOUND(NP, sound('sound/blank.ogg'))
			NP.LateChoices()
		queued_players.len = 0
		queue_delay = 0
		return

	queue_delay++
	var/mob/dead/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			listclearnulls(queued_players)
			if(living_player_count() < hpc)
				if(next_in_line && next_in_line.client)
					to_chat(next_in_line, "<span class='danger'>A slot has opened! You have approximately 20 seconds to join. <a href='?src=[REF(next_in_line)];late_join=override'>\>\>Join Game\<\<</a></span>")
					SEND_SOUND(next_in_line, sound('sound/blank.ogg'))
					next_in_line.LateChoices()
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, "<span class='danger'>No response received. You have been removed from the line.</span>")
			queued_players -= next_in_line
			queue_delay = 0

/datum/controller/subsystem/ticker/proc/check_maprotate()
	if (!CONFIG_GET(flag/maprotation))
		return
	if (SSshuttle.emergency && SSshuttle.emergency.mode != SHUTTLE_ESCAPE || SSshuttle.canRecall())
		return
	if (maprotatechecked)
		return

	maprotatechecked = 1

	//map rotate chance defaults to 75% of the length of the round (in minutes)
	if (!prob((world.time/600)*CONFIG_GET(number/maprotatechancedelta)))
		return
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, maprotate))

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending
	hide_mode = SSticker.hide_mode
	mode = SSticker.mode

	login_music = SSticker.login_music
	round_end_sound = SSticker.round_end_sound

	minds = SSticker.minds

	delay_end = SSticker.delay_end

	triai = SSticker.triai
	tipped = SSticker.tipped
	selected_tip = SSticker.selected_tip

	timeLeft = SSticker.timeLeft

	totalPlayers = SSticker.totalPlayers
	totalPlayersReady = SSticker.totalPlayersReady

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked
	round_start_time = SSticker.round_start_time
	round_start_irl = SSticker.round_start_irl

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked

	switch (current_state)
		if(GAME_STATE_SETTING_UP)
			Master.SetRunLevel(RUNLEVEL_SETUP)
		if(GAME_STATE_PLAYING)
			Master.SetRunLevel(RUNLEVEL_GAME)
		if(GAME_STATE_FINISHED)
			Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Nanotrasen News Network"
	switch(news_report)
		if(NUKE_SYNDICATE_BASE)
			news_message = "In a daring raid, the heroic crew of [station_name()] detonated a nuclear device in the heart of a terrorist base."
		if(STATION_DESTROYED_NUKE)
			news_message = "We would like to reassure all employees that the reports of a Syndicate backed nuclear attack on [station_name()] are, in fact, a hoax. Have a secure day!"
		if(STATION_EVACUATED)
			news_message = "The crew of [station_name()] has been evacuated amid unconfirmed reports of enemy activity."
		if(BLOB_WIN)
			news_message = "[station_name()] was overcome by an unknown biological outbreak, killing all crew on board. Don't let it happen to you! Remember, a clean work station is a safe work station."
		if(BLOB_NUKE)
			news_message = "[station_name()] is currently undergoing decontanimation after a controlled burst of radiation was used to remove a biological ooze. All employees were safely evacuated prior, and are enjoying a relaxing vacation."
		if(BLOB_DESTROYED)
			news_message = "[station_name()] is currently undergoing decontamination procedures after the destruction of a biological hazard. As a reminder, any crew members experiencing cramps or bloating should report immediately to security for incineration."
		if(CULT_ESCAPE)
			news_message = "Security Alert: A group of religious fanatics have escaped from [station_name()]."
		if(CULT_FAILURE)
			news_message = "Following the dismantling of a restricted cult aboard [station_name()], we would like to remind all employees that worship outside of the Chapel is strictly prohibited, and cause for termination."
		if(CULT_SUMMON)
			news_message = "Company officials would like to clarify that [station_name()] was scheduled to be decommissioned following meteor damage earlier this year. Earlier reports of an unknowable eldritch horror were made in error."
		if(NUKE_MISS)
			news_message = "The Syndicate have bungled a terrorist attack [station_name()], detonating a nuclear weapon in empty space nearby."
		if(OPERATIVES_KILLED)
			news_message = "Repairs to [station_name()] are underway after an elite Syndicate death squad was wiped out by the crew."
		if(OPERATIVE_SKIRMISH)
			news_message = "A skirmish between security forces and Syndicate agents aboard [station_name()] ended with both sides bloodied but intact."
		if(REVS_WIN)
			news_message = "Company officials have reassured investors that despite a union led revolt aboard [station_name()] there will be no wage increases for workers."
		if(REVS_LOSE)
			news_message = "[station_name()] quickly put down a misguided attempt at mutiny. Remember, unionizing is illegal!"
		if(WIZARD_KILLED)
			news_message = "Tensions have flared with the Space Wizard Federation following the death of one of their members aboard [station_name()]."
		if(STATION_NUKED)
			news_message = "[station_name()] activated its self destruct device for unknown reasons. Attempts to clone the Captain so he can be arrested and executed are underway."
		if(CLOCK_SUMMON)
			news_message = "The garbled messages about hailing a mouse and strange energy readings from [station_name()] have been discovered to be an ill-advised, if thorough, prank by a clown."
		if(CLOCK_SILICONS)
			news_message = "The project started by [station_name()] to upgrade their silicon units with advanced equipment have been largely successful, though they have thus far refused to release schematics in a violation of company policy."
		if(CLOCK_PROSELYTIZATION)
			news_message = "The burst of energy released near [station_name()] has been confirmed as merely a test of a new weapon. However, due to an unexpected mechanical error, their communications system has been knocked offline."
		if(SHUTTLE_HIJACK)
			news_message = "During routine evacuation procedures, the emergency shuttle of [station_name()] had its navigation protocols corrupted and went off course, but was recovered shortly after."

	if(news_message)
		send2otherserver(news_source, news_message,"News_Report")

/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.timeLeft))
		return max(0, start_at - world.time)
	return timeLeft

/datum/controller/subsystem/ticker/proc/SetTimeLeft(newtime)
	if(newtime >= 0 && isnull(timeLeft))	//remember, negative means delayed
		start_at = world.time + newtime
	else
		timeLeft = newtime

//Everyone who wanted to be an observer gets made one now
/datum/controller/subsystem/ticker/proc/create_observers()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_OBSERVE && player.mind)
			//Break chain since this has a sleep input in it
			addtimer(CALLBACK(player, TYPE_PROC_REF(/mob/dead/new_player, make_me_an_observer)), 1)

/datum/controller/subsystem/ticker/proc/load_mode()
	var/mode = trim(file2text("data/mode.txt"))
	if(mode)
		GLOB.master_mode = mode
	else
		GLOB.master_mode = "warmode"
	log_game("Saved mode is '[GLOB.master_mode]'")

/datum/controller/subsystem/ticker/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	WRITE_FILE(F, the_mode)

/datum/controller/subsystem/ticker/proc/SetRoundEndSound(the_sound)
	set waitfor = FALSE
	round_end_sound_sent = FALSE
	round_end_sound = fcopy_rsc(the_sound)
	for(var/thing in GLOB.clients)
		var/client/C = thing
		if (!C)
			continue
		C.Export("##action=load_rsc", round_end_sound)
	round_end_sound_sent = TRUE

/datum/controller/subsystem/ticker/proc/Reboot(reason, end_string, delay)
	set waitfor = FALSE
	if(usr && !check_rights(R_SERVER, TRUE))
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldannounce'>A game master has delayed the round end.</span>")
		return

	SStriumphs.end_triumph_saving_time()
	to_chat(world, "<span class='boldannounce'>Rebooting World in [DisplayTimeText(delay)]. [reason]</span>")

	var/start_wait = world.time
	UNTIL(round_end_sound_sent || (world.time - start_wait) > (delay * 2))	//don't wait forever
	sleep(delay - (world.time - start_wait))

	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		return
	if(end_string)
		end_state = end_string

	var/statspage = CONFIG_GET(string/roundstatsurl)
	var/gamelogloc = CONFIG_GET(string/gamelogurl)
	if(statspage)
		to_chat(world, "<span class='info'>Round statistics and logs can be viewed <a href=\"[statspage][GLOB.round_id]\">at this website!</a></span>")
	else if(gamelogloc)
		to_chat(world, "<span class='info'>Round logs can be located <a href=\"[gamelogloc]\">at this website!</a></span>")

	log_game("<span class='boldannounce'>Rebooting World. [reason]</span>")

	if(end_party)
		to_chat(world, "<span class='boldannounce'>It's over!</span>")
		world.Del()
	else
		world.Reboot()

/datum/controller/subsystem/ticker/Shutdown()
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	save_admin_data()
	update_everything_flag_in_db()

	text2file(login_music, "data/last_round_lobby_music.txt")

/datum/controller/subsystem/ticker/proc/ReadyToDie()
	var/datum/game_mode/warfare/W = mode
	if(!warfare_ready_to_die)
		to_chat(world, "<span class='userdanger'>[pick("FOR THE CROWN! FOR THE EMPIRE!","CHILDREN OF THE NATION, TO YOUR STATIONS!","I'M NOT AFRAID TO DIE!")]</span>")
		if(!(oneteammode))
			W.reinforcements()
		warfare_ready_to_die = TRUE

		// https://imgur.com/a/mzWBurl

		for(var/mob/M in GLOB.player_list)
			SEND_SOUND(M, 'sound/music/wolfintro.ogg')

		for(var/obj/structure/warfarebarrier/WB in world)
			qdel(WB)

		var/obj/structure/warobjective/WO = locate()
		if(WO)
			WO.beginround()

/proc/GetMainGunForWarfareHeartfelt()
	switch(SSticker.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/bayo
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/repeater
		if(WARMONGERS_TECHLEVEL_AUTO)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/supermachine
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/proc/GetMainGunForWarfareGrenzelhoft()
	switch(SSticker.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/bayo/grenz
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/repeater
		if(WARMONGERS_TECHLEVEL_AUTO)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/supermachine
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/proc/GetSidearmForWarfare()
	switch(SSticker.warfare_techlevel)
		if(WARMONGERS_TECHLEVEL_FLINTLOCKS)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/flintlock/pistol
		if(WARMONGERS_TECHLEVEL_COWBOY)
			return /obj/item/gun/ballistic/revolver/grenadelauncher/revolvashot
		if(WARMONGERS_TECHLEVEL_NONE)
			return null

/datum/controller/subsystem/ticker/proc/SendReinforcements()
	var/datum/game_mode/warfare/W = mode

	var/obj/effect/landmark/blureinforcement/blu = locate(/obj/effect/landmark/blureinforcement) in GLOB.landmarks_list
	var/obj/effect/landmark/redreinforcement/red = locate(/obj/effect/landmark/redreinforcement) in GLOB.landmarks_list

	W.reinforcementwave++
	var/list/reinforcementinas = list()
	switch(W.reinforcementwave)
		if(1)
			reinforcementinas += "/obj/item/bomb"
			reinforcementinas += "/obj/item/bomb/fire/weak"
		if(2)
			reinforcementinas += "/obj/item/bomb"
			reinforcementinas += "/obj/item/bomb"
			reinforcementinas += "/obj/item/bomb/fire/weak"
			reinforcementinas += "/obj/item/bomb/smoke"
			reinforcementinas += "/obj/item/flint"
			SSticker.warfare_techlevel = WARMONGERS_TECHLEVEL_FLINTLOCKS
		if(3)
			reinforcementinas += "/obj/item/bomb/smoke"
			reinforcementinas += "/obj/item/bomb/fire"
			reinforcementinas += "/obj/item/bomb/poison"
			reinforcementinas += "/obj/item/bomb"
			reinforcementinas += "/obj/item/bomb"
		if(4)
			reinforcementinas += "/obj/item/bomb/fire"
			reinforcementinas += "/obj/item/bomb/fire"
			reinforcementinas += "/obj/item/bomb/poison"
			reinforcementinas += "/obj/item/bomb/poison"
			SSticker.warfare_techlevel = WARMONGERS_TECHLEVEL_COWBOY
		if(5)
			reinforcementinas += "/obj/item/bomb"
			reinforcementinas += "/obj/item/bomb"
			reinforcementinas += "/obj/item/bomb/fire"
			reinforcementinas += "/obj/item/bomb/smoke"
			reinforcementinas += "/obj/item/bomb/poison"
			reinforcementinas += "/obj/item/bomb/poison"
	to_chat(world, "<span class='info'><span class='typewrite'>Reinforcements have arrived.</span></span>")
	for(var/mob/M in GLOB.player_list)
		if(aspect_chosen(/datum/round_aspect/halo))
			SEND_SOUND(M, 'sound/vo/halo/reinforcements.mp3')
		else
			SEND_SOUND(M, 'sound/music/traitor.ogg')
	for(var/i in reinforcementinas)
		var/typepath = text2path(i)
		new typepath(red.loc)
		new typepath(blu.loc)