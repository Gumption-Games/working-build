class_name NewIngPopup extends Popup

onready var size:Vector2 = $ColorRect.get_rect().size
onready var label = $ColorRect/IngName

func _destroy():
	self.call_deferred("queue_free")
