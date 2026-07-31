extends Node2D


@onready
var amsynth: ASynth = $Panel/amsynth

@onready
var option_button: OptionButton = $Panel/OptionButton

@onready
var ui: Panel = $Panel

@onready
var world: World = $SubViewportContainer/SubViewport/World

@onready
var camera: Camera2D = $Camera2D

@onready
var dig_and_puzzle: DigAndPuzzle = $DigAndPuzzle

@onready
var label: Label = $Label

@onready
var dirt_fill_grid: Node2D = $DirtFillGrid

var ui_visible: bool = false
var csound_synth: CsoundInstance
var csound_parameters: Array[String]

var using_keyboard: bool = false
var finished: bool = false


func _ready() -> void:
	CsoundServer.csound_ready.connect(_on_csound_ready)

	#OS.open_midi_inputs()
	#print(OS.get_connected_midi_inputs())

	csound_parameters = [
		"ASynthOsc.1.osc_waveform",
		"ASynthOsc.1.osc_pulsewidth",
		"ASynthOsc.1.osc_sync",
		"ASynthDetune.1.osc_range",
		"ASynthDetune.1.osc_pitch",
		"ASynthDetune.1.osc_detune",
		"ASynthOsc.2.osc_waveform",
		"ASynthOsc.2.osc_pulsewidth",
		"ASynthOsc.2.osc_sync",
		"ASynthDetune.2.osc_range",
		"ASynthDetune.2.osc_pitch",
		"ASynthDetune.2.osc_detune",
		"ASynthAmp.1.amp_attack",
		"ASynthAmp.1.amp_decay",
		"ASynthAmp.1.amp_sustain",
		"ASynthAmp.1.amp_release",
		"ASynthMix.1.osc_mix",
		"ASynthMix.1.osc_mix_mode",
		"ASynthRender.1.master_vol",
		"ASynthOverDrive.1.distortion_crunch",
		"ASynthFilter.1.filter_type",
		"ASynthFilter.1.filter_resonance",
		"ASynthFilter.1.filter_cutoff",
		"ASynthFilter.1.filter_kbd_track",
		"ASynthFilter.1.filter_env_amount",
		"ASynthFilter.1.filter_attack",
		"ASynthFilter.1.filter_decay",
		"ASynthFilter.1.filter_sustain",
		"ASynthFilter.1.filter_release",
		"ASynthLfo.1.lfo_waveform",
		"ASynthLfo.1.lfo_freq",
		"ASynthLfoFreq.1.freq_mod_amount",
		"ASynthLfoFreq.2.freq_mod_amount",
		"ASynthFilter.1.filter_mod_amount",
		"ASynthAmp.1.amp_mod_amount",
		"ASynthReverb.1.reverb_wet",
		"ASynthReverb.1.reverb_roomsize",
		"ASynthReverb.1.reverb_width",
		"ASynthReverb.1.reverb_damp",
		"ASynthInput.1.portamento_time",
		"ASynthInput.1.portamento_mode",
		"ASynthInput.1.keyboard_mode"
	]

	var popup_menu: PopupMenu = option_button.get_popup()
	for i in popup_menu.get_item_count():
		if popup_menu.is_item_radio_checkable(i):
			popup_menu.set_item_as_radio_checkable(i, false)

	csound_synth = CsoundServer.get_csound("Main")


func _on_csound_ready(name: String):
	if name == "Main":
		csound_synth = CsoundServer.get_csound(name)
		#active_instrument = "synth"
		option_button.selected = 0
		amsynth.load_preset("res://presets/dirt.json")

		option_button.selected = 1
		amsynth.load_preset("res://presets/guitar.json")

		option_button.selected = 2
		amsynth.load_preset("res://presets/bass1.json")

		option_button.selected = 3
		amsynth.load_preset("res://presets/dirty_bass.json")

		option_button.selected = 4
		amsynth.load_preset("res://presets/atmosphere.json")

		option_button.selected = 5
		amsynth.load_preset("res://presets/ambience.json")

		option_button.selected = 6
		amsynth.load_preset("res://presets/space.json")

		option_button.selected = 7
		amsynth.load_preset("res://presets/bass2.json")

		option_button.selected = 8
		amsynth.load_preset("res://presets/jump.json")

		option_button.selected = 9
		amsynth.load_preset("res://presets/shoot.json")

		option_button.selected = 10
		amsynth.load_preset("res://presets/swap.json")


func _input(input_event):
	if input_event is InputEventMIDI:
		print ("midi")
		var midi_event: InputEventMIDI = input_event

		if midi_event.message == MIDI_MESSAGE_NOTE_ON:
			csound_synth.note_on(0, midi_event.pitch, midi_event.velocity)
		if midi_event.message == MIDI_MESSAGE_NOTE_OFF:
			csound_synth.note_off(0, midi_event.pitch)

	if input_event is InputEventKey and input_event.pressed:
		using_keyboard = true


func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_ui"):
		ui_visible = not ui_visible
		ui.visible = ui_visible

	#TODO: remove duplicate code
	var count: int = 0
	for brain in world.brains.get_children():
		if brain.process_mode != Node.PROCESS_MODE_DISABLED:
			count += 1

	label.text = "%d / 20" % [20 - count]

	if count == 0 and not finished:
		world.input_enabled = false
		world.disable_audio()
		world.player.input_enabled = true
		world.quetzalcoatl.movement_enabled = false
		world.quetzalcoatl.hide()
		dirt_fill_grid.enabled = true
		dirt_fill_grid.quetzalcoatl.movement_enabled = true
		finished = true


func _on_amsynth_parameter_changed(parameter: int, value: float) -> void:
	var parameter_name = get_parameter_name(option_button.text, parameter)
	csound_synth.send_control_channel(parameter_name, value)
		

func get_parameter_name(instrument: String, parameter: int):
	return "%s.%s" % [instrument, csound_parameters[parameter]]


func get_parameter_values(instrument: String):
	var content = {}

	for parameter in range(0, len(csound_parameters)):
		var value = csound_synth.get_control_channel(get_parameter_name(instrument, parameter))
		content[str(parameter)] = str(value)

	return content


func _on_option_button_item_selected(index: int) -> void:
	var content = get_parameter_values(option_button.text)

	amsynth.update_knobs(content)
	amsynth.update_waveforms()


func _on_dig_and_puzzle_dig_finished() -> void:
	option_button.selected = 0
	amsynth.load_preset("res://presets/flute.json")


func _on_dig_and_puzzle_solved() -> void:
	var tween = get_tree().create_tween()
	var end = Vector2(camera.position.x, camera.position.y - 648)
	tween.tween_property(camera, "position", end, 2.0)

	await get_tree().create_timer(2.0).timeout

	#camera.queue_free()
	#dig_and_puzzle.queue_free()
	camera.hide()
	dig_and_puzzle.hide()

	option_button.selected = 0
	amsynth.load_preset("res://presets/dirt.json")

	world.player.input_enabled = true
	world.quetzalcoatl.movement_enabled = true
	world.brain.movement_enabled = true

	world.outside_audio()


func _on_dirt_fill_grid_finished() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://main.tscn")
