extends Control

@export var slide_in_duration: float = 1.25

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if tween:
        tween.kill()

    tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "offset_transform_position_ratio", Vector2(0, 0), slide_in_duration)