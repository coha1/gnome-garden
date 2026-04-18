class_name ClockHud
extends Control


@onready var clock_label: Label = $ClockLabel
@onready var veggie_label: Label = $VeggieLabel
@onready var notification_label: Label = $NotificationLabel


var _notification_timer: float = 0.0


func _ready() -> void:
	Inventory.veggie_count_changed.connect(_on_veggie_count_changed)
	Notifications.notification_requested.connect(_on_notification_requested)
	_on_veggie_count_changed(Inventory.veggie_count)
	notification_label.visible = false


func _process(delta: float) -> void:
	clock_label.text = DayNightCycle.get_clock_string()

	if _notification_timer <= 0.0:
		return
	_notification_timer -= delta
	if _notification_timer <= 0.0:
		notification_label.visible = false


func _on_veggie_count_changed(count: int) -> void:
	veggie_label.text = "Veggies: " + str(count)


func _on_notification_requested(message: String, duration: float) -> void:
	notification_label.text = message
	notification_label.visible = true
	_notification_timer = duration
