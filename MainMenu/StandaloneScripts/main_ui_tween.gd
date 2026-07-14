extends Control

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if tween:
        tween.kill()
    
    tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "offset_transform_position_ratio", Vector2(0, 0), 1.25)