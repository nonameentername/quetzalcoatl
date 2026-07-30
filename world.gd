extends Node2D
class_name World

var random = RandomNumberGenerator.new()

@export
var brain_scene: PackedScene

@export
var input_enabled: bool:
	set(value):
		input_enabled = value
		if player:
			player.input_enabled = value
		if quetzalcoatl:
			quetzalcoatl.movement_enabled = value
	get():
		return input_enabled

@onready
var glitch_cooldown_timer: Timer = $GlitchTimer

@onready
var shader: ColorRect = $Shader

@onready
var player: Player = $Player

@onready
var quetzalcoatl: Quetzalcoatl = $Quetzalcoatl

@onready
var brains: Node2D = $Brains

@onready
var tile_map1: TileMapLayer = $TileMapLayer1

@onready
var tile_map2: TileMapLayer = $TileMapLayer2

@onready
var tile_map_swapped: bool = false

@onready
var effect: CPUParticles2D = $Area2D/CPUParticles2D

@onready
var space: AnimatedSprite2D = $Space

@onready
var button_r1: AnimatedSprite2D = $R1

var allow_glitch: bool = true

var control_tweens: Dictionary = {}

var tempo_tween: Tween
var current_tempo = 120

var csound: CsoundInstance

var synth_active = {}

const NOTES = [48, 50, 52, 53, 55, 57, 58]

var using_keyboard: bool = false



func _ready():
	CsoundServer.csound_ready.connect(_on_csound_ready)

	set_instrument_active("guitar", false)
	set_instrument_active("bass1", false)
	set_instrument_active("dirty_bass", false)
	set_instrument_active("atmosphere", false)
	set_instrument_active("ambience", false)
	set_instrument_active("space", false)
	set_instrument_active("bass2", false)

	csound = CsoundServer.get_csound("Main")

	update_tempo(120)


func _process(delta: float) -> void:
	var position: float = 2 + ((int(player.position.x) % 128) / 128.0)
	
	if not synth_active["guitar"] and csound:
		csound.send_control_channel("dirty_bass.ASynthLfo.1.lfo_freq", position)
		

func _input(event):
	if event is InputEventKey and event.pressed: # and not event.is_echo():
		using_keyboard = true


func _physics_process(delta):
	if not input_enabled:
		return
	
	if Input.is_action_just_pressed("swap"):
		space.hide()
		button_r1.hide()

		var pixelation_tween = get_tree().create_tween()

		#TODO: remove duplicate code

		var offset = randi_range(0, 6)
		csound.event_string('i "swap" 0 0.01 0 %d 90' % (NOTES[offset]))

		pixelation_tween.tween_method(
			func(value): shader.material.set_shader_parameter("pixelation", value),
			0.001,
			0.1,
			0.2
		)

		tile_map_swapped = not tile_map_swapped

		tile_map1.collision_enabled = not tile_map_swapped
		tile_map1.visible = not tile_map_swapped

		tile_map2.collision_enabled = tile_map_swapped
		tile_map2.visible = tile_map_swapped

		pixelation_tween.tween_method(
			func(value): shader.material.set_shader_parameter("pixelation", value),
			0.1,
			0.001,
			0.2
		)

	if player.position.y > 1000:

		#TODO: remove duplicate code

		var offset = randi_range(0, 6)
		csound.event_string('i "swap" 0 0.01 0 %d 90' % (NOTES[offset]))

		var pixelation_tween = get_tree().create_tween()

		pixelation_tween.tween_method(
			func(value): shader.material.set_shader_parameter("pixelation", value),
			0.001,
			0.1,
			0.2
		)

		player.position.x = 100
		player.position.y = 670

		pixelation_tween.tween_method(
			func(value): shader.material.set_shader_parameter("pixelation", value),
			0.1,
			0.001,
			0.2
		)

	var count: int = 0
	for brain in brains.get_children():
		if brain.process_mode != Node.PROCESS_MODE_DISABLED:
			count += 1

	if count == 0:
		#TODO: add ending
		update_tempo(120)


func _on_csound_ready(name: String):
	if name == "Main":
		csound = CsoundServer.get_csound(name)


func update_tempo(value):
	if tempo_tween:
		tempo_tween.kill()

	tempo_tween = get_tree().create_tween()
	tempo_tween.tween_method(
		func(value): csound.send_control_channel("tempo", value),
		current_tempo,
		value,
		2.0
	)

	current_tempo = value


func set_instrument_active(instrument: String, value: bool):
	synth_active[instrument] = value

	if csound:
		if value:
			csound.send_control_channel("play_%s" % (instrument), 1)
		else:
			csound.send_control_channel("play_%s" % (instrument), 0)


func set_score_position(value: float):
	csound.evaluate_code("setscorepos %f" % value)


func rewind_score():
	csound.evaluate_code("rewindscore")


func _on_outside_area_2d_body_entered(body: Node2D) -> void:
	outside_audio()


func outside_audio():
	if not player.input_enabled:
		return

	set_instrument_active("atmosphere", true)
	set_instrument_active("ambience", true)
	set_instrument_active("space", true)
	set_instrument_active("dirty_bass", false)
	set_instrument_active("drums", false)
	set_instrument_active("bass1", false)
	set_instrument_active("bass2", false)
	set_instrument_active("guitar", false)

	csound.send_control_channel("dirty_bass.ASynthRender.1.master_vol", 0.5)
	#rewind_score()


func disable_audio():
	set_instrument_active("atmosphere", false)
	set_instrument_active("ambience", false)
	set_instrument_active("space", false)
	set_instrument_active("dirty_bass", false)
	set_instrument_active("drums", false)
	set_instrument_active("bass1", false)
	set_instrument_active("bass2", false)
	set_instrument_active("guitar", false)


func _on_small_room_area_2d_body_entered(body: Node2D) -> void:
	set_instrument_active("atmosphere", true)
	set_instrument_active("ambience", true)
	set_instrument_active("space", true)
	set_instrument_active("dirty_bass", true)
	set_instrument_active("drums", true)
	set_instrument_active("bass1", false)
	set_instrument_active("bass2", false)
	set_instrument_active("guitar", false)

	csound.send_control_channel("dirty_bass.ASynthRender.1.master_vol", 0.5)

	#set_score_position(0)
	#rewind_score()


func _on_medium_room_area_2d_body_entered(body: Node2D) -> void:
	set_instrument_active("atmosphere", false)
	set_instrument_active("ambience", false)
	set_instrument_active("space", false)
	set_instrument_active("dirty_bass", true)
	set_instrument_active("drums", true)
	set_instrument_active("bass1", false)
	set_instrument_active("bass2", false)
	set_instrument_active("guitar", false)

	csound.send_control_channel("dirty_bass.ASynthRender.1.master_vol", 1.0)


func _on_large_room_area_2d_body_entered(body: Node2D) -> void:
	set_instrument_active("atmosphere", false)
	set_instrument_active("ambience", false)
	set_instrument_active("space", false)
	set_instrument_active("dirty_bass", true)
	set_instrument_active("drums", true)
	set_instrument_active("bass1", true)
	set_instrument_active("bass2", true)
	set_instrument_active("guitar", true)

	csound.send_control_channel("dirty_bass.ASynthLfo.1.lfo_freq", 2.479)
	csound.send_control_channel("dirty_bass.ASynthRender.1.master_vol", 0.5)


func _on_enemy_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		for brain in brains.get_children():
			brain.movement_enabled = true
		update_tempo(360)


func _on_player_brain_collision() -> void:
	if not allow_glitch:
		return

	allow_glitch = false

	glitch_cooldown_timer.start()

	var pixelation_tween = get_tree().create_tween()

	pixelation_tween.tween_method(
		func(value): shader.material.set_shader_parameter("pixelation", value),
		0.1,
		0.001,
		0.2
	)


func _on_glitch_timer_timeout() -> void:
	allow_glitch = true


func _on_player_jump() -> void:
	var offset = 0 #randi_range(0, 6)
	csound.event_string('i "jump" 0 0.01 0 %d 90' % (48 + offset))


func _on_player_shoot() -> void:
	var offset = randi_range(0, 6)
	csound.event_string('i "shoot" 0 0.01 0 %d 90' % (NOTES[offset]))


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Quetzalcoatl:
		effect.emitting = false
		effect.emitting = true
		csound.event_string('i "synth" 0 0.1 0 %d 90' % (64))


func _on_swap_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and not input_enabled:
		input_enabled = true
		if using_keyboard:
			space.show()
		else:
			button_r1.show()


func _on_water_area_2d_body_entered(body: Node2D) -> void:
	pass
