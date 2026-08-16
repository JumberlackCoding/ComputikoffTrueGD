class_name TweenParams
extends Resource

@export var slide: SlideParams
@export var rotate: RotateParams
@export var scale: ScaleParams
@export var phase: PhaseParams
@export var color: ColorParams
@export var pivot: Vector2 = Vector2.ZERO ## Default [code]Vector2.ZERO[/code]
@export var pivot_ratio: Vector2 = Vector2(0.5, 0.5) ## Default [code]Vector2(0.5, 0.5)[/code]
@export var move_z_index_to_frontish: bool = false
@export var visual_only: bool = false ## Default [code]false[/code]
@export var final_visibility: bool = true ## Default [code]true[/code]
@export_range(0, 1, 0.01) var final_alpha: float = 1.0 ## Default [code]1.0[/code]
var target_node: Control ## Default [code]null[/code]

func _init(target = null) -> void:
    if target:
        target_node = target

## [param add_delay] = [code]true[/code] means the reset's delay will be offset by the original's delay [i]and[/i] duration while [code]false[/code] means
## there will be no additional delay. The reset's delay will be the same as the original's delay.
func reset(add_delay: bool = true) -> TweenParams:
    var new_params = TweenParams.new()

    new_params.target_node = target_node
    new_params.pivot = pivot
    new_params.pivot_ratio = pivot_ratio
    new_params.move_z_index_to_frontish = move_z_index_to_frontish
    new_params.visual_only = visual_only

    if slide:
        new_params.slide = SlideParams.new()
        new_params.slide.duration = slide.duration
        if add_delay:
            new_params.slide.delay = slide.duration + slide.delay # offset it so it executes right after the previous one without needing to await
        else:
            new_params.slide.delay = slide.delay
        new_params.slide.start = slide.end
        new_params.slide.by_ratio = slide.by_ratio
        new_params.slide.transition_type = slide.transition_type
        if slide.ease_type == Tween.EASE_IN:
            new_params.slide.ease_type = Tween.EASE_OUT
        elif slide.ease_type == Tween.EASE_OUT:
            new_params.slide.ease_type = Tween.EASE_IN
        else:
            new_params.slide.ease_type = slide.ease_type
    if rotate:
        new_params.rotate = RotateParams.new()
        new_params.rotate.duration = rotate.duration
        if add_delay:
            new_params.rotate.delay = rotate.duration + rotate.delay # offset it so it executes right after the previous one without needing to await
        else:
            new_params.rotate.delay = rotate.delay
        new_params.rotate.start = rotate.end
        new_params.rotate.transition_type = rotate.transition_type
        if rotate.ease_type == Tween.EASE_IN:
            new_params.rotate.ease_type = Tween.EASE_OUT
        elif rotate.ease_type == Tween.EASE_OUT:
            new_params.rotate.ease_type = Tween.EASE_IN
        else:
            new_params.rotate.ease_type = rotate.ease_type
    if scale:
        new_params.scale = ScaleParams.new()
        new_params.scale.duration = scale.duration
        if add_delay:
            new_params.scale.delay = scale.duration + scale.delay # offset it so it executes right after the previous one without needing to await
        else:
            new_params.scale.delay = scale.delay
        new_params.scale.start = scale.end
        new_params.scale.transition_type = scale.transition_type
        if scale.ease_type == Tween.EASE_IN:
            new_params.scale.ease_type = Tween.EASE_OUT
        elif scale.ease_type == Tween.EASE_OUT:
            new_params.scale.ease_type = Tween.EASE_IN
        else:
            new_params.scale.ease_type = scale.ease_type
    if phase:
        new_params.phase = PhaseParams.new()
        new_params.phase.duration = phase.duration
        if add_delay:
            new_params.phase.delay = phase.duration + phase.delay # offset it so it executes right after the previous one without needing to await
        else:
            new_params.phase.delay = phase.delay
        new_params.phase.start = phase.end
        new_params.phase.transition_type = phase.transition_type
        if phase.ease_type == Tween.EASE_IN:
            new_params.phase.ease_type = Tween.EASE_OUT
        elif phase.ease_type == Tween.EASE_OUT:
            new_params.phase.ease_type = Tween.EASE_IN
        else:
            new_params.phase.ease_type = phase.ease_type
    if color:
        new_params.color = ColorParams.new()
        new_params.color.duration = color.duration
        if add_delay:
            new_params.color.delay = color.duration + color.delay # offset it so it executes right after the previous one without needing to await
        else:
            new_params.color.delay = color.delay
        new_params.color.start = color.end
        new_params.color.transition_type = color.transition_type
        if color.ease_type == Tween.EASE_IN:
            new_params.color.ease_type = Tween.EASE_OUT
        elif color.ease_type == Tween.EASE_OUT:
            new_params.color.ease_type = Tween.EASE_IN
        else:
            new_params.color.ease_type = color.ease_type

    return new_params

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