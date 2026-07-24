extends Node2D
class_name DigAndPuzzle


@onready
var sliding_puzzle: SlidingPuzzle = $SlidingPuzzle

@onready
var fossil_dig_grid: FossilDigGrid = $FossilDigGrid

@onready
var amsynth: ASynth = $amsynth

var csound_synth: CsoundInstance
var csound_parameters: Array[String]

const NOTES = [48, 50, 52, 53, 55, 57, 58, 60]


func _on_fossil_dig_grid_dig_finished() -> void:
	sliding_puzzle.input_enabled = true
	fossil_dig_grid.queue_free()


func _ready() -> void:
	CsoundServer.csound_ready.connect(_on_csound_ready)

	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())

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


func _input(input_event):
	if input_event is InputEventMIDI:
		print ("midi")
		var midi_event: InputEventMIDI = input_event

		if midi_event.message == MIDI_MESSAGE_NOTE_ON:
			csound_synth.note_on(0, midi_event.pitch, midi_event.velocity)
		if midi_event.message == MIDI_MESSAGE_NOTE_OFF:
			csound_synth.note_off(0, midi_event.pitch)


func _on_csound_ready(name: String):
	if name == "Main":
		csound_synth = CsoundServer.get_csound(name)
		amsynth.load_preset("res://presets/flute.json")


func _on_amsynth_parameter_changed(parameter: int, value: float) -> void:
	var parameter_name = get_parameter_name("synth", parameter)
	csound_synth.send_control_channel(parameter_name, value)
		

func get_parameter_name(instrument: String, parameter: int):
	return "%s.%s" % [instrument, csound_parameters[parameter]]


func _on_puzzle_piece_moved(number: int) -> void:
	csound_synth.event_string('i "synth" 0 10 0 %d 90' % (NOTES[number - 1]))
