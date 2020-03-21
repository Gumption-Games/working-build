class_name NewIngPopup extends Popup

func _destroy():
	self.call_deferred("queue_free")
