extends Node2D
class_name World

var random = RandomNumberGenerator.new()

@export
var brain_scene: PackedScene

@onready
var brain_spawn_timer: Timer = $SpawnTimer

@onready
var glitch_cooldown_timer: Timer = $GlitchTimer

@onready
var spawn_location: PathFollow2D = $SpawnPath/SpawnLocation

@onready
var shader: ColorRect = $Shader

@onready
var player: Player = $Player

var number_of_brains = 0
var allow_glitch: bool = true

var control_tweens: Dictionary = {}

var tempo_tween: Tween
var current_tempo = 120

var csound: CsoundInstance
var csound_synth: CsoundInstance

var synth_active = {}

const NOTES = [48, 50, 52, 53, 55, 57, 58]



func _ready():
	CsoundServer.csound_layout_changed.connect(csound_layout_changed)
	CsoundServer.csound_ready.connect(_on_csound_ready)

	synth_active["guitar"] = false
	synth_active["bass1"] = false
	synth_active["dirty_bass"] = false
	synth_active["atmosphere"] = false
	synth_active["ambience"] = false
	synth_active["space"] = false
	synth_active["bass2"] = false


func _process(delta: float) -> void:
	var position: float = 2 + ((int(player.position.x) % 128) / 128.0)
	
	if not synth_active["guitar"]:
		pass
		#dirty_bass
		#csound_synth.send_control_channel("SYNTH_LFO_FREQ_INPUT_CONTROL", position)


func csound_layout_changed():
	csound = CsoundServer.get_csound("Main")
	csound.midi_note_on.connect(_on_midi_note_on)
	csound.midi_note_off.connect(_on_midi_note_off)


func _on_csound_ready(name: String):
	if name == "Main":
		csound_synth = CsoundServer.get_csound(name)


func _on_midi_note_on(channel, note, velocity):
	#print("Note On: channel: ", channel, " note: ", note, " velocity: ", velocity)

	if csound_synth and channel == 1 and synth_active["guitar"]:
		csound_synth.note_on(0, note, velocity)

	if csound_synth and channel == 2 and synth_active["bass1"]:
		csound_synth.note_on(0, note, velocity)

	if csound_synth and channel == 3 and synth_active["dirty_bass"]:
		csound_synth.note_on(0, note, velocity)

	if csound_synth and channel == 4 and synth_active["atmosphere"]:
		csound_synth.note_on(0, note, velocity)

	if csound_synth and channel == 5 and synth_active["ambience"]:
		csound_synth.note_on(0, note, velocity)

	if csound_synth and channel == 6 and synth_active["space"]:
		csound_synth.note_on(0, note, velocity)

	if csound_synth and channel == 8 and synth_active["bass2"]:
		csound_synth.note_on(0, note, velocity)


func _on_midi_note_off(channel, note):
	#print("Note Off: channel: ", channel, " note: ", note)

	if csound_synth and channel == 1:
		csound_synth.note_off(0, note)

	if csound_synth and channel == 2:
		csound_synth.note_off(0, note)

	if csound_synth and channel == 3:
		csound_synth.note_off(0, note)

	if csound_synth and channel == 4:
		csound_synth.note_off(0, note)

	if csound_synth and channel == 5:
		csound_synth.note_off(0, note)

	if csound_synth and channel == 6:
		csound_synth.note_off(0, note)

	if csound_synth and channel == 8:
		csound_synth.note_off(0, note)


func _on_timer_timeout() -> void:
	if number_of_brains > 200:
		brain_spawn_timer.stop()
		return

	spawn_location.progress_ratio = random.randf()
	
	var brain: Node2D = brain_scene.instantiate()
	
	add_child(brain)
	move_child(brain, 7)

	number_of_brains += 1

	brain.global_position = spawn_location.global_position


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


func set_drums_enabled(value: bool):
	return

	if value:
		csound.send_control_channel("play_drums", 1)
	else:
		csound.send_control_channel("play_drums", 0)


func set_score_position(value: float):
	csound.evaluate_code("setscorepos %f" % value)


func _on_outside_area_2d_body_entered(body: Node2D) -> void:
	synth_active["dirty_bass"] = false
	#csound_synth.send_control_channel("SYNTH_VOLUME_INPUT_CONTROL", 0)
	set_drums_enabled(false)


func _on_small_room_area_2d_body_entered(body: Node2D) -> void:
	synth_active["atmosphere"] = true
	synth_active["ambience"] = true
	synth_active["space"] = true

	if not synth_active["dirty_bass"]:
		synth_active["dirty_bass"] = true
		#csound_synth.send_control_channel("SYNTH_VOLUME_INPUT_CONTROL", 1)
		set_drums_enabled(true)
		#set_score_position(0)


func _on_medium_room_area_2d_body_entered(body: Node2D) -> void:
	synth_active["atmosphere"] = false
	synth_active["ambience"] = false
	synth_active["space"] = false

	synth_active["bass1"] = false
	synth_active["bass2"] = false
	synth_active["guitar"] = false


func _on_large_room_area_2d_body_entered(body: Node2D) -> void:
	synth_active["bass1"] = true
	synth_active["bass2"] = true
	synth_active["guitar"] = true

	#csound_synth.send_control_channel("SYNTH_LFO_FREQ_INPUT_CONTROL", 2.72)


func _on_enemy_area_2d_body_entered(body: Node2D) -> void:
	brain_spawn_timer.start()

	#update_tempo(360)


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
	#csound_synth.event_string('i "jump" 0 0.01 0 %d 90' % (48 + offset))


func _on_player_shoot() -> void:
	var offset = randi_range(0, 6)
	#csound_synth.event_string('i "shoot" 0 0.01 0 %d 90' % (NOTES[offset]))
