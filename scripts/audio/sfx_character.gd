extends AudioStreamPlayer2D

@export var steps_sand: Array[AudioStream] = [null, null, null, null]
@export var steps_soil: Array[AudioStream] = [null, null, null, null]
@export var steps_wood: Array[AudioStream] = [null, null, null, null] 
@export var steps_grass: Array[AudioStream] = [null, null, null, null] 

@export var footstep_interval: float = 0.4

var _current_surface: String = ""
var _is_walking: bool = false
var _footstep_timer: Timer

func _ready() -> void:
	_footstep_timer = Timer.new()
	_footstep_timer.wait_time = footstep_interval
	_footstep_timer.one_shot = true
	_footstep_timer.timeout.connect(_on_footstep_timer_timeout)
	add_child(_footstep_timer)
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
		
	_current_surface = surface_type
	_is_walking = true
	
	if not playing and _footstep_timer.is_stopped():
		_play_random_clip(valid_clips)

func stop_footstep() -> void:
	_is_walking = false
	_current_surface = ""
	_footstep_timer.stop()
	stop()

func _play_random_clip(valid_clips: Array[AudioStream]) -> void:
	stream = valid_clips.pick_random()
	play()

func _on_footstep_timer_timeout() -> void:
	if _is_walking and _current_surface != "":
		play_footstep(_current_surface)

# Connect to the built-in finished signal to trigger the timer
func _on_finished() -> void:
	if _is_walking:
		_footstep_timer.start(footstep_interval)

func _notification(what: int) -> void:
	if what == NOTIFICATION_POSTINITIALIZE:
		finished.connect(_on_finished)
