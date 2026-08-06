extends Control

@export_group("Scorecard Data")
@export var scorecard_name: StringName
@export var background_color: Color
@export_node_path("TextureRect") var logo_path: NodePath
@export_node_path("MarginContainer") var instance_path: NodePath

func get_instance() -> Control:
    return get_tree().current_scene.get_node(str(instance_path).substr(6))

func get_logo() -> Control:
    return get_tree().current_scene.get_node(str(logo_path).substr(6))
