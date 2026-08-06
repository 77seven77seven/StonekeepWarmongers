/datum/round_aspect
	var/name = "Round Aspect"

	var/description = "Uh oh."

	var/adminonly = FALSE // can only be forced by 'mins
	var/weight = 1 // 10+ - most common, 1 - least common

/datum/round_aspect/proc/apply()
	return

/datum/round_aspect/normal
	name = "Nothing!"
	description = "Normality above all."
	weight = 9

/datum/round_aspect/futurewar
	name = "The Future of Warfare"
	description = "These levershots are the future!"
	weight = 4

/datum/round_aspect/futurewar/apply()
	SSwarmongers.warfare_techlevel = WARMONGERS_TECHLEVEL_COWBOY

/datum/round_aspect/nomood
	name = "Moodless"
	description = "All soldiers are put through rigorous training to ensure they are emotionless."

/datum/round_aspect/stronglords
	name = "Strong Commanders"
	description = "Everyone knows the commander should be the strongest man in the platoon."
	weight = 5

/datum/round_aspect/suprememedics
	name = "Supreme Medics"
	description = "The healing is not as rewarding as the hurting."
	weight = 4

/datum/round_aspect/squishyhumans
	name = "Squishy Soldiers"
	description = "You're coming in terms with yourself, you're not as resilient as you thought."
	weight = 6

/datum/round_aspect/exploding
	name = "Explosive Death"
	description = "A terrible curse has descended upon us! If we die we explode!"
	weight = 2

/datum/round_aspect/noreloading
	name = "God of War's Blessing"
	description = "We are blessed!"

/* People aren't ready for this.
/datum/round_aspect/goblino
	name = "It's all goblins"
	description = "The Lords accidentally recruited goblins instead of humens."
*/

/datum/round_aspect/starvingmarvins
	name = "Starvin' Marvins"
	description = "Sadly, it's like old WARMONGERS all over again! Everyone is hungry and thirsty at the start of the round!"
	weight = 5

/datum/round_aspect/monkwarfare
	name = "Warmonkers"
	description = "Everyone on the battlefield is a natural in hand-to-hand combat. A monk, if you didn't get the joke."
	weight = 3

/datum/round_aspect/kicking
	name = "Kicking Nuts"
	description = "Every soldier attended their mandatory testicular warfare class."
	weight = 5

/datum/round_aspect/explodeatwill
	name = "Explode at Will"
	description = "Shouting your war cry causes you to explode due to a bomb inside your anus."
	adminonly = TRUE

/datum/round_aspect/supplypoints
	name = "Favors in the Right Places"
	description = "Because the commanders both have favors to the qartermaster guilds, they both get five supply points on the start of the battle."
	weight = 7

/datum/round_aspect/supplypoints/apply()
	var/datum/game_mode/warmongers/W = SSticker.mode
	W.blu_bonus = 24
	W.red_bonus = 24

/datum/round_aspect/superiorbreeds
	name = "The Superior Breed"
	description = "Hearses have twice as health or twice the speed!"
	weight = 6

/datum/round_aspect/rationsurplus
	name = "Ration Surplus"
	description = "A ration surplus on both sides has caused the soldiers to be quite well fed!"
	weight = 5

/datum/round_aspect/poorbastards
	name = "Poor Bastards"
	description = "We didn't have enough of a budget to pay for our firearms."
	weight = 2

/datum/round_aspect/poorbastards/apply()
	SSwarmongers.warfare_techlevel = WARMONGERS_TECHLEVEL_NONE

/datum/round_aspect/attackofdead
	name = "Attack of the Living Dead"
	description = "When a person dies, it's not the end."
	adminonly = TRUE // its so fucked up

/datum/round_aspect/whatthefuck
	name = "What? Just... why?"
	description = "When a person dies, they spawn... goblins?"
	adminonly = TRUE

/datum/round_aspect/veteranlords
	name = "Veteran Affairs"
	description = "The commanders aren't wusses. They fought wars before."
	weight = 6

/datum/round_aspect/bloodybastards
	name = "Bloody Bastards"
	description = "Everyone has more blood than usual."
	weight = 6

/datum/round_aspect/linefocus
	name = "Line Focused Warfare"
	description = "Barkshottes take longer to reload!"
	weight = 8

/datum/round_aspect/explodabarrels
	name = "Explodabarrels"
	description = "The battlefield is scattered with explosive barrels!"
	weight = 6
	var/spawncount = 1

/datum/round_aspect/explodabarrels/apply()
	. = ..()
	spawncount = rand(5,15)
	var/list/spawn_locs = GLOB.round_aspect_spawners.Copy()
	if(LAZYLEN(spawn_locs))
		for(var/i in 1 to spawncount)
			var/obj/effect/landmark/events/aspect_spawners/_T = pick_n_take(spawn_locs)
			if(_T)
				_T = get_turf(_T)
				if(isfloorturf(_T))
					var/obj/structure/fluff/explodabarrel/G = locate() in _T
					if(G)
						continue
					new /obj/structure/fluff/explodabarrel(_T)
					

/datum/round_aspect/drafted
	name = "Reinforcement Draft"
	description = "Respawning takes time and your class is randomized. Keeps the battle dynamic and chaotic, or so ChatGPT told me."
	adminonly = TRUE

/datum/round_aspect/halo
	name = "Haloic Ballads"
	description = "This battle has an announcer. How cool!"
	weight = 2