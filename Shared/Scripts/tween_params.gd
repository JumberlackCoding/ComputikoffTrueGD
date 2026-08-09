class_name TweenParams
extends Resource

@export var slide: SlideParams
@export var rotate: RotateParams
@export var scale: ScaleParams
@export var phase: PhaseParams
@export var color: ColorParams
@export var pivot: Vector2 = Vector2.ZERO ## Default [code]Vector2.ZERO[/code]
@export var pivot_ratio: Vector2 = Vector2(0.5, 0.5) ## Default [code]Vector2(0.5, 0.5)[/code]
@export var move_z_index_to_frontish: bool = true
@export var visual_only: bool = false ## Default [code]false[/code]
@export var final_visibility: bool = true ## Default [code]true[/code]
@export_range(0, 1, 0.01) var final_alpha: float = 1.0 ## Default [code]1.0[/code]
var target_node: Control ## Default [code]null[/code]

func _init(target = null) -> void:
    if target:
        target_node = target

func debug():
    print("=== TweenParams ===")
    for prop in get_property_list():
        match prop.name:
            "script", "RefCounted", "Resource", "resource_local_to_scene", "resource_path", "resource_name", "resource_scene_unique_id", "metadata/_custom_type_script":
                continue
        var val = get(prop.name)
        if val is Resource:
            print("--- ", prop.name, " ---")
            for subprop in val.get_property_list():
                match subprop.name:
                    "script", "RefCounted", "Resource", "resource_local_to_scene", "resource_path", "resource_name", "resource_scene_unique_id", "metadata/_custom_type_script":
                        continue
                print(subprop.name, ": ", val.get(subprop.name))
            print("--- ", prop.name, " ---")
        print(prop.name, ": ", get(prop.name))
    print("=== TweenParams ===\n\n")