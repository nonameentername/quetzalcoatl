extends Node2D
class_name DigAndPuzzle


@onready
var sliding_puzzle: SlidingPuzzle = $SlidingPuzzle

@onready
var fossil_dig_grid: FossilDigGrid = $FossilDigGrid

@onready
var cursor: Area2D = $GridCursor

@onready
var label: Label = $Label

var csound_synth: CsoundInstance

const NOTES = [48, 50, 52, 53, 55, 57, 58, 60]

var tutorial: bool = true

signal dig_finished
signal solved


func _ready() -> void:
	CsoundServer.csound_ready.connect(_on_csound_ready)
	csound_synth = CsoundServer.get_csound("Main")


func _on_csound_ready(name: String):
	if name == "Main":
		csound_synth = CsoundServer.get_csound(name)


func _physics_process(delta):
	if tutorial:
		label.text = "%d / 6" % [cursor.keys.size()]
		if cursor.keys.size() == 6:
			tutorial = false
	elif fossil_dig_grid:
		label.text = "%d / 9" % [fossil_dig_grid.blocks_cleared]
	else:
		label.hide()


func _on_fossil_dig_grid_dig_finished() -> void:
	await get_tree().create_timer(0.2).timeout

	dig_finished.emit()

	sliding_puzzle.input_enabled = true
	fossil_dig_grid.queue_free()


func _on_puzzle_piece_moved(number: int) -> void:
	csound_synth.event_string('i "synth" 0 10 0 %d 90' % (NOTES[number - 1]))


func _on_fossil_dig_piece_clearing() -> void:
	csound_synth.event_string('i "synth" 0 0.1 0 %d 90' % (64))


func _on_sliding_puzzle_solved() -> void:
	sliding_puzzle.input_enabled = false
	cursor.visible = false

	for puzzle_piece in sliding_puzzle.puzzle_pieces:
		await get_tree().create_timer(0.2).timeout 
		csound_synth.event_string('i "synth" 0 10 0 %d 90' % (NOTES[puzzle_piece.number - 1]))
		puzzle_piece.pulse_glow()

	var start = [1, 3, 2, 1]

	for i in range(0, start.size()):
		for puzzle_piece in sliding_puzzle.puzzle_pieces:
			puzzle_piece.pulse_glow()

		csound_synth.event_string('i "synth" 0 10 0 %d 90' % (NOTES[start[i]]))
		csound_synth.event_string('i "synth" 0 10 0 %d 90' % (NOTES[start[i] + 2]))
		csound_synth.event_string('i "synth" 0 10 0 %d 90' % (NOTES[start[i] + 4]))

		await get_tree().create_timer(0.3).timeout 

	solved.emit()
