/datum/status_effect/stress
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/stress/stressinsane
	id = "insane"
	affected_stats = list("constitution" = -1, "endurance" = -2, "speed" = -2)
	alert_type = /atom/movable/screen/alert/status_effect/stress/stressinsane

/atom/movable/screen/alert/status_effect/stress/stressinsane
	name = "REMORSE"
	desc = "“Known amongst the ranks as the Remorse, this ailment strikes even the hardiest veterans. After months under the whine of Hellfire, men speak of voices—mocking them with the screams of the fallen. Their hands shake as though gripped by invisible talons, and the world around them blurs into a haze of lead and blood. Some take to nightly ozium to quiet the storm; others fall silent, staring at the sky as if it might crack open once more.”"
	icon_state = "stressinsane"

/datum/status_effect/stress/stressvbad
	id = "stressvbad"
	affected_stats = list("constitution" = -1,"endurance" = -1, "speed" = -1)
	alert_type = /atom/movable/screen/alert/status_effect/stress/stressvbad

/atom/movable/screen/alert/status_effect/stress/stressvbad
	name = "Shocked"
	desc = "PLEASE! PLEASE! JUST GET ME OUT OF HERE! I DON'T WANT TO DIE!"
	icon_state = "stressvbad"

/datum/status_effect/stress/stressbad
	id = "stressbad"
	affected_stats = list("speed" = -1)
	alert_type = /atom/movable/screen/alert/status_effect/stress/stressbad

/atom/movable/screen/alert/status_effect/stress/stressbad
	name = "Stressed"
	desc = "Please... I'd rather be shot in the head than left to bleed out in the mud with a cut throat..."
	icon_state = "stressbad"

/datum/status_effect/stress/stressvgood
	id = "stressvgood"
	affected_stats = list("fortune" = 1)
	alert_type = /atom/movable/screen/alert/status_effect/stress/good/stressvgood

/atom/movable/screen/alert/status_effect/stress/good/stressvgood
	name = "Nirvana"
	desc = "My body is a temple, and my mind a garden."
	icon_state = "stressvgood"
