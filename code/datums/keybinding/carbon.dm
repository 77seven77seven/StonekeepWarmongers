/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB


/datum/keybinding/carbon/toggle_throw_mode
	hotkey_keys = list("R")
	classic_keys = list("R") // END
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	category = CATEGORY_CARBON

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE

//****** Base Intents ******

/datum/keybinding/carbon/intent_one
	hotkey_keys = list("1")
	name = "intent_one"
	full_name = "Cycle Intent Slot 1"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/intent_one/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.rog_intent_change(1)
/*	if(C.active_hand_index == 2)
		if(C.swap_hand(1))
			C.rog_intent_change(1)
	else
		if(C.l_index == 1)
			C.rog_intent_change(3)
		else
			C.rog_intent_change(1)*/

	return TRUE

/datum/keybinding/carbon/intent_two
	hotkey_keys = list("2")
	name = "intent_two"
	full_name = "Cycle Intent Slot 2"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/intent_two/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.rog_intent_change(2)
	return TRUE

/datum/keybinding/carbon/intent_three
	hotkey_keys = list("3")
	name = "intent_three"
	full_name = "Cycle Intent Slot 3"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/intent_three/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.rog_intent_change(3)
	return TRUE

/datum/keybinding/carbon/intent_four
	hotkey_keys = list("4")
	name = "intent_four"
	full_name = "Cycle Intent Slot 4"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/intent_four/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.rog_intent_change(4)
	return TRUE

// middle mouse button intents, mmb intents

/datum/keybinding/carbon/bite_intent
	hotkey_keys = list("H")
	name = "intent_bite"
	full_name = "Select Bite Intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/bite_intent/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.mmb_intent_change(QINTENT_BITE)
	return TRUE

/datum/keybinding/carbon/jump_intent
	hotkey_keys = list("J")
	name = "intent_jump"
	full_name = "Select Jump Intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/jump_intent/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.mmb_intent_change(QINTENT_JUMP)
	return TRUE

/datum/keybinding/carbon/kick_intent
	hotkey_keys = list("K")
	name = "intent_kick"
	full_name = "Select Kick Intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/kick_intent/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.mmb_intent_change(QINTENT_KICK)
	return TRUE