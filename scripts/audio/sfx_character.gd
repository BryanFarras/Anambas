extends AudioStreamPlayer2D

@export var steps_sand: Array[AudioStream] = [null, null, null, null]
@export var steps_soil: Array[AudioStream] = [null, null, null, null]
@export var steps_wood: Array[AudioStream] = [null, null, null, null]

func play_footstep(surface_type: String) -> void:
	var clips: Array[AudioStream] = []
	
	match surface_type.to_lower():
		"sand":
			clips = steps_sand
		"soil":
			clips = steps_soil
		"wood":
			clips = steps_wood
		_:
			push_warning("SFX Character: unknown surface type '%s'" % surface_type)
			return
			
	var valid_clips = clips.filter(func(clip): return clip != null)
	if valid_clips.is_empty():
		return
		
	stream = valid_clips.pick_random()
	play()
