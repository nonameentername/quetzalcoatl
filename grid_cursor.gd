extends Area2D

var tutorial: bool = true
var digging: bool = true

var keys = {}

var current_dig: FossilDigPiece
var current_puzzle_piece: PuzzlePiece

@onready
var up: AnimatedSprite2D = $Up

@onready
var down: AnimatedSprite2D = $Down

@onready
var left: AnimatedSprite2D = $Left

@onready
var right: AnimatedSprite2D = $Right

@onready
var jump: AnimatedSprite2D = $Jump

@onready
var shoot: AnimatedSprite2D = $Shoot


func _ready() -> void:
	Input.use_accumulated_input = false


func _physics_process(delta):
	if Input.is_action_just_pressed("left"):
		keys["left"]  = true
		left.play()

	elif Input.is_action_just_pressed("right"):
		keys["right"]  = true
		right.play()

	elif Input.is_action_just_pressed("up"):
		keys["up"]  = true
		up.play()

	elif Input.is_action_just_pressed("down"):
		keys["down"]  = true
		down.play()

	elif Input.is_action_just_pressed("shoot"):
		keys["shoot"]  = true
		shoot.play()

	elif Input.is_action_just_pressed("jump"):
		keys["jump"]  = true
		jump.play()

	if keys.size() == 6 and tutorial:
		tutorial = false

		up.hide()
		down.hide()
		left.hide()
		right.hide()
		jump.hide()
		shoot.hide()

	if tutorial:
		return

	var end: Vector2

	if Input.is_action_just_pressed("left"):
		end = Vector2(position.x - 128, position.y)
		tween_position(end)
	elif Input.is_action_just_pressed("right"):
		end = Vector2(position.x + 128, position.y)
		tween_position(end)
	elif Input.is_action_just_pressed("up"):
		end = Vector2(position.x, position.y - 128)
		tween_position(end)
	elif Input.is_action_just_pressed("down"):
		end = Vector2(position.x, position.y + 128)
		tween_position(end)

	if Input.is_action_just_pressed("shoot"):
		if digging and current_dig:
			current_dig.dig()
		if current_puzzle_piece:
			current_puzzle_piece.try_move()

	if Input.is_action_just_pressed("jump"):
		#TODO: remove duplicate code
		if digging and current_dig:
			current_dig.dig()
		if current_puzzle_piece:
			current_puzzle_piece.try_move()

func tween_position(end: Vector2):
	end = end.clamp(
		Vector2.ZERO,
		Vector2(1024, 512)
	)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", end, 0.1)


func _on_body_entered(body: Node2D) -> void:
	if body is FossilDigPiece:
		current_dig = body

	if body is PuzzlePiece:
		current_puzzle_piece = body


func _on_body_exited(body: Node2D) -> void:
	if body == current_dig:
		current_dig = null

	if body == current_puzzle_piece:
		current_puzzle_piece = null


func _on_dig_and_puzzle_dig_finished() -> void:
	digging = false
