extends AnimationTree

class_name UnitAnimator


func play_anim(animation_type):
	match animation_type:
		Globals.AnimationType.IDLE:
			set_anim("Idle")
		Globals.AnimationType.WALKING:
			set_anim("Walking")
		Globals.AnimationType.SHOOTING:
			set_anim("Shooting")
		Globals.AnimationType.HIT:
			set_anim("Hit")
			

func set_anim(name):
	self["parameters/playback"].travel(name)
