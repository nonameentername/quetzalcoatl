extends Node2D
class_name DigAndPuzzle


@onready
var sliding_puzzle: SlidingPuzzle = $SlidingPuzzle

@onready
var fossil_dig_grid: FossilDigGrid = $FossilDigGrid

var csound_synth: CsoundInstance

const NOTES = [48, 50, 52, 53, 55, 57, 58, 60]

signal dig_finished


func _ready() -> void:
	CsoundServer.csound_ready.connect(_on_csound_ready)


func _on_csound_ready(name: String):
	if name == "Main":
		csound_synth = CsoundServer.get_csound(name)


func _on_fossil_dig_grid_dig_finished() -> void:
	await get_tree().create_timer(0.2).timeout

	dig_finished.emit()

	sliding_puzzle.input_enabled = true
	fossil_dig_grid.queue_free()


func _on_puzzle_piece_moved(number: int) -> void:
	csound_synth.event_string('i "synth" 0 10 0 %d 90' % (NOTES[number - 1]))


func _on_fossil_dig_piece_clearing() -> void:
	csound_synth.event_string('i "synth" 0 0.1 0 %d 90' % (64))
