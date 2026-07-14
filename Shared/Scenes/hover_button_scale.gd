@tool
extends Control

var scale_xy_separately: bool = false:
    set(value):
        scale_xy_separately = value
        notify_property_list_changed()

var scale_xy: float = 1.1
var scale_x: float = 1.1
var scale_y: float = 1.1

var tween: Tween
var button: BaseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if Engine.is_editor_hint():
        return

    if get_parent() is BaseButton:
        button = get_parent()
    else:
        push_error("Expected parent to be BaseButton. Found ", get_parent().get_class(), ".")

    if button:
        button.offset_transform_enabled = true
        button.button_down.connect(_on_button_activate)
        button.button_up.connect(_on_button_deactivate)
        button.mouse_entered.connect(_on_button_activate)
        button.mouse_exited.connect(_on_button_deactivate)

# Manually construct the property list for the inspector
func _get_property_list() -> Array[Dictionary]:
    var properties: Array[Dictionary] = []

    # 1. Add the checkbox property
    properties.append({
        "name": "scale_xy_separately",
        "type": TYPE_BOOL
    })

    # 2. Add the scale fields conditionally
    match scale_xy_separately:
        false:
            properties.append({
                "name": "scale_xy",
                "type": TYPE_FLOAT
            })
        true:
            properties.append({
                "name": "scale_x",
                "type": TYPE_FLOAT
            })
            properties.append({
                "name": "scale_y",
                "type": TYPE_FLOAT
            })

    return properties

func _on_button_activate():
    if Engine.is_editor_hint():
        return

    if tween:
        tween.kill()

    tween = get_parent().create_tween()
    tween.set_trans(Tween.TRANS_QUINT)
    tween.set_ease(Tween.EASE_OUT)
    var newScale: Vector2 = Vector2(scale_x, scale_y) if scale_xy_separately else Vector2(scale_xy, scale_xy)
    tween.tween_property(get_parent(), "offset_transform_scale", newScale, 0.2)

func _on_button_deactivate():
    if Engine.is_editor_hint():
        return

    if tween:
        tween.kill()

    tween = get_parent().create_tween()
    tween.set_trans(Tween.TRANS_QUINT)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(get_parent(), "offset_transform_scale", Vector2(1, 1), 0.2)
