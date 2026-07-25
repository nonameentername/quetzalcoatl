extends CharacterBody2D
class_name Quetzalcoatl


var body_scene: PackedScene

@export
var follow_path: PathFollow2D

@onready
var sprite: Sprite2D = $Head

@onready
var tail: StaticBody2D = $Tail

var direction: Vector2

enum Direction { UP, DOWN, LEFT, RIGHT, NONE }
var current_direction: Direction
var current_velocity: Vector2

var direction_velocity: int = 20048
var next_direction: Direction = Direction.RIGHT

var number_segments = 40
var segments: Array[QuetzalcoatlBody]


func _ready() -> void:
	body_scene = preload("res://quetzalcoatl_body.tscn")

	for i in range(0, number_segments):
		var segment: QuetzalcoatlBody = body_scene.instantiate()
		segments.push_back(segment)
		segment.show_behind_parent = true
		add_child(segment)

	segments.reverse()

	current_direction = Direction.RIGHT


func _physics_process(delta: float) -> void:
	follow_path.progress += 5.0

	var head_progress := follow_path.progress

	# Head
	follow_path.progress = head_progress - 1.0
	var head_previous_position := follow_path.position

	follow_path.progress = head_progress + 1.0
	var head_next_position := follow_path.position

	follow_path.progress = head_progress
	position = follow_path.position

	var head_direction := head_next_position.direction_to(
		head_previous_position
	).normalized()

	sprite.rotation = head_direction.angle()
	sprite.flip_v = head_direction.x < 0

	# Body segments
	for index in range(segments.size()):
		var segment: QuetzalcoatlBody = segments[index]
		var offset := (index + 1) * 64.0

		follow_path.progress = head_progress - offset
		var segment_position := follow_path.position

		follow_path.progress -= 1.0
		var previous_position := follow_path.position

		follow_path.progress += 2.0
		var next_position := follow_path.position

		segment.global_position = segment_position
		segment.direction = next_position.direction_to(
			previous_position
		).normalized()

	# Tail
	var tail_offset := (segments.size() + 1) * 64.0
	follow_path.progress = head_progress - tail_offset

	var tail_position := follow_path.position

	follow_path.progress -= 1.0
	var tail_previous_position := follow_path.position

	follow_path.progress += 2.0
	var tail_next_position := follow_path.position

	var tail_direction := tail_next_position.direction_to(
		tail_previous_position
	).normalized()

	tail.global_position = tail_position
	tail.rotation = tail_direction.angle()

	# Restore the follower to the head.
	follow_path.progress = head_progress

	move_and_slide()
