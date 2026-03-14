extends CharacterBody2D

@export_group("Settings")
@export var speed: float = 50.0
@export var quest_data: BaseQuest 

@onready var sprite: AnimatedSprite2D = $animation
@onready var interact_label: Label = $Label

var baloon = load("res://scenes/base_dialog/balloon.tscn")
var player_in_range: bool = false
var is_talking: bool = false
var last_direction: String = "bawah"

func _ready() -> void:
	interact_label.hide()
	sprite.play("idle_bawah")

func _physics_process(_delta: float) -> void:
	if is_talking:
		velocity = Vector2.ZERO
		return
	
	play_movement_animation()
	move_and_slide()

func play_movement_animation():
	var direction = "bawah"
	
	if abs(velocity.x) > abs(velocity.y):
		direction = "kanan" if velocity.x > 0 else "kiri"
	elif abs(velocity.y) > 0:
		direction = "bawah" if velocity.y > 0 else "atas"
	else:
		sprite.play("idle_" + last_direction)
		return

	last_direction = direction
	sprite.play("jalan_" + direction)

func _input(event):
	if event.is_action_pressed("interact") and player_in_range and not is_talking:
		mulai_dialog()

func mulai_dialog():
	if quest_data and quest_data.dialogue:
		is_talking = true
		DialogueManager.show_dialogue_balloon(quest_data.dialogue,"Awal")
		await DialogueManager.dialogue_ended
		is_talking = false
		cek_status_quest()

func cek_status_quest():
	pass

func _on_interaksi_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player" :
		player_in_range = true
		interact_label.show()


func _on_interaksi_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player" :
		player_in_range = false
		interact_label.hide()
