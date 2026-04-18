extends Node


signal veggie_count_changed(count: int)


var veggie_count: int = 0


func add_veggie() -> void:
	veggie_count += 1
	veggie_count_changed.emit(veggie_count)
	print("Inventory: veggie added — total ", veggie_count)


func consume_veggie() -> bool:
	if veggie_count <= 0:
		return false
	veggie_count -= 1
	veggie_count_changed.emit(veggie_count)
	print("Inventory: veggie consumed — total ", veggie_count)
	return true
