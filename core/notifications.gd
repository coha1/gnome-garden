extends Node


signal notification_requested(message: String, duration: float)


func notify(message: String, duration: float = 3.0) -> void:
	notification_requested.emit(message, duration)
