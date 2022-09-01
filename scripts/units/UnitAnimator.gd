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
			get_parent().play_fire_vfx()
		Globals.AnimationType.HIT:
			set_anim("Hit")
		Globals.AnimationType.RELOADING:
			set_anim("Reloading")
			

func set_anim(name):
	self["parameters/playback"].travel(name)
