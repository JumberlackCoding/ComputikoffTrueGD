extends Control

@export var scene_to_load: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if get_parent() is BaseButton:
        get_parent().pressed.connect(_on_click)
    else:
        push_error("Expected parent to be BaseButton. Found ", get_parent().get_class(), ".")

func _on_click() -> void:
    get_tree().change_scene_to_file(scene_to_load)
