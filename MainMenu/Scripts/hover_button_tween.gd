extends Control

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var button = get_parent() as BaseButton
    button.offset_transform_enabled = true
    button.button_down.connect(_on_button_activate)
    button.button_up.connect(_on_button_deactivate)
    button.mouse_entered.connect(_on_button_activate)
    button.mouse_exited.connect(_on_button_deactivate)

func _on_button_activate():
    if tween:
        tween.kill()
    
    tween = get_parent().create_tween()
    tween.set_trans(Tween.TRANS_QUINT)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(get_parent(), "offset_transform_scale", Vector2(1.04, 1.04), 0.2)

func _on_button_deactivate():
    if tween:
        tween.kill()
    
    tween = get_parent().create_tween()
    tween.set_trans(Tween.TRANS_QUINT)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(get_parent(), "offset_transform_scale", Vector2(1, 1), 0.2)