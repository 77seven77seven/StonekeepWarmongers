/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/deathgurgle
	key = "deathgurgle"
	key_third_person = ""
	emote_type = EMOTE_AUDIBLE
	only_forced_audio = TRUE
	vary = TRUE
	message = "gasps out their last breath."
	message_simple =  "falls limp."
	stat_allowed = UNCONSCIOUS
	mob_type_ignore_stat_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "strums an invisible lute."
	restraint_check = TRUE

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "blinks rapidly."

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	muzzle_ignore = TRUE
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return "clap"

/datum/emote/living/carbon/warcry
	key = "warcry"
	key_third_person = ""
	message = "shouts a war cry!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/warcry/run_emote(mob/user, params, type_override, intentional, targetted)
	. = ..()
	var/warcry = "WAR!!!"
	var/sound2play
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		switch(H.warfare_faction)
			if(RED_WARTEAM)
				warcry = "FOR DAH BEEZER!"
				sound2play = sound('sound/vo/wc/speech_ppu_taunt.ogg')
			if(BLUE_WARTEAM)
				warcry = "PRAISE IT!"
				sound2play = sound('sound/vo/wc/speech_regimer_taunt.ogg')

		if(aspect_chosen(/datum/round_aspect/explodeatwill))
			user.say(warcry)
			spawn(2 SECONDS)
				var/obj/item/rogue/bomb/B = new(get_turf(user))
				B.light()
				B.explode(TRUE)
				user.gib()

	if(user.client.hasPerk(/datum/warperk/mortalcombat))
		sound2play = 'sound/misc/mortalkombat.ogg'

	playsound(user, sound2play, 150, TRUE, -2, ignore_walls = FALSE, vary = FALSE)
	user.shoutbubble()
	ping_sound(user)
    
/mob/proc/shoutbubble()
    var/image/I = image('icons/mob/talk.dmi', src, "default2", FLY_LAYER)
    I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

    var/list/listening = view(6,src)
    var/list/speech_bubble_recipients = list()
    for(var/mob/M in listening)
        speech_bubble_recipients.Add(M.client)

    INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), I, speech_bubble_recipients, 30)

/mob/living/carbon/human/verb/emote_warcry()
	set name = "WARCRY"
	set category = "Noises"
	if(stat == CONSCIOUS)
		emote("warcry", intentional = TRUE)

/mob/living/carbon/human/verb/emote_warcry_f1()
	set name = ".warcry"
	emote_warcry()

/datum/emote/living/carbon/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth..."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey)

/datum/emote/living/carbon/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/screech
	key = "screech"
	key_third_person = "screeches"
	message = "screeches."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum(text2num(params)))
		return message

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers."
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	restraint_check = TRUE

/datum/emote/living/carbon/tail
	key = "tail"
	message = "waves their tail."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks."
