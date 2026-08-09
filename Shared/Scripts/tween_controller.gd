extends Control

var slide_tweens := {}
var rotate_tweens := {}
var scale_tweens := {}
var phase_tweens := {}
var color_tweens := {}
var z_indexes := {}

func _prepare_for_tween(target_node: Control, offset_pivot: Vector2 = Vector2.ZERO, offset_pivot_ratio: Vector2 = Vector2(0.5, 0.5), move_z_index_to_frontish: bool = true) -> void:
    if move_z_index_to_frontish:
        z_indexes[target_node] = target_node.z_index
        target_node.z_index = 5

    target_node.offset_transform_pivot = offset_pivot
    target_node.offset_transform_pivot_ratio = offset_pivot_ratio
    target_node.visible = true

func _prepare_for_slide_tween(target_node: Control, slide_start: Vector2 = Vector2.ZERO, slide_by_ratio: bool = false) -> void:
    target_node.offset_transform_enabled = true

    if slide_by_ratio:
        target_node.offset_transform_position_ratio = slide_start
    else:
        target_node.offset_transform_position = slide_start

func _prepare_for_rotate_tween(target_node: Control, rotate_start: float = 0.0) -> void:
    target_node.offset_transform_enabled = true
    target_node.offset_transform_rotation = rotate_start

func _prepare_for_scale_tween(target_node: Control, scale_start: Vector2 = Vector2.ONE) -> void:
    target_node.offset_transform_enabled = true
    target_node.offset_transform_scale = scale_start

func _prepare_for_phase_tween(target_node: Control, phase_start: float = 1.0) -> void:
    target_node.modulate.a = phase_start

func _prepare_for_color_tween(target_node: Control, color_start: Color = Color.WHITE) -> void:
    var colorRect: ColorRect = target_node as ColorRect

    if colorRect:
        colorRect.color = color_start
    else:
        target_node.self_modulate = color_start

func cleanup_tween(params: TweenParams) -> void:
    params.target_node.offset_transform_position = Vector2.ZERO
    params.target_node.offset_transform_position_ratio = Vector2.ZERO
    params.target_node.offset_transform_scale = Vector2.ONE

    if params.move_z_index_to_frontish:
        if z_indexes.has(params.target_node):
            params.target_node.z_index = z_indexes[params.target_node]
        else:
            params.target_node.z_index = 0

    params.target_node.offset_transform_enabled = false

    params.target_node.visible = params.final_visibility
    params.target_node.modulate.a = params.final_alpha

func _tween_safety_check(target_node: Control, type: String) -> void:
    match type:
        "slide":
            if slide_tweens.has(target_node):
                slide_tweens[target_node].kill()
                slide_tweens.erase(target_node)
        "rotate":
            if rotate_tweens.has(target_node):
                rotate_tweens[target_node].kill()
                rotate_tweens.erase(target_node)
        "scale":
            if scale_tweens.has(target_node):
                scale_tweens[target_node].kill()
                scale_tweens.erase(target_node)
        "phase":
            if phase_tweens.has(target_node):
                phase_tweens[target_node].kill()
                phase_tweens.erase(target_node)
        "color":
            if color_tweens.has(target_node):
                color_tweens[target_node].kill()
                color_tweens.erase(target_node)
        _: push_error("Invalid type of tween submitted")

func _get_offset_position_property(use_ratio: bool) -> String:
    return "offset_transform_position_ratio" if use_ratio else "offset_transform_position"

func _get_offset_rotation_property() -> String:
    return "offset_transform_rotation"

func _get_offset_scale_property() -> String:
    return "offset_transform_scale"

func _get_offset_alpha_property() -> String:
    return "modulate:a"

func _get_offset_color_property(target_node: Control) -> String:
    return "color" if target_node is ColorRect else "modulate"

func universal_tween(params: TweenParams) -> Dictionary:
    if not params.target_node:
        push_error("TweenParams missing target_node")

    _prepare_for_tween(params.target_node, params.pivot, params.pivot_ratio, params.move_z_index_to_frontish)
    var slide_tween: Tween
    var rotate_tween: Tween
    var scale_tween: Tween
    var phase_tween: Tween
    var color_tween: Tween

    if params.slide:
        _tween_safety_check(params.target_node, "slide")
        _prepare_for_slide_tween(params.target_node, params.slide.start, params.slide.by_ratio)
        slide_tween = params.target_node.create_tween()
        slide_tweens[params.target_node] = slide_tween
        slide_tween.set_trans(params.slide.transition_type)
        slide_tween.set_ease(params.slide.ease_type)
        var slide_transform_property: String = _get_offset_position_property(params.slide.by_ratio)
        slide_tween.tween_property(params.target_node, slide_transform_property, params.slide.end, params.slide.duration).from(params.slide.start).set_delay(params.slide.delay)

    if params.rotate:
        _tween_safety_check(params.target_node, "rotate")
        _prepare_for_rotate_tween(params.target_node, params.rotate.start)
        rotate_tween = params.target_node.create_tween()
        rotate_tweens[params.target_node] = rotate_tween
        rotate_tween.set_trans(params.rotate.transition_type)
        rotate_tween.set_ease(params.rotate.ease_type)
        var rotate_transform_property: String = _get_offset_rotation_property()
        rotate_tween.tween_property(params.target_node, rotate_transform_property, params.rotate.end, params.rotate.duration).from(params.rotate.start).set_delay(params.rotate.delay)

    if params.scale:
        _tween_safety_check(params.target_node, "scale")
        _prepare_for_scale_tween(params.target_node, params.scale.start)
        scale_tween = params.target_node.create_tween()
        scale_tweens[params.target_node] = scale_tween
        scale_tween.set_trans(params.scale.transition_type)
        scale_tween.set_ease(params.scale.ease_type)
        var scale_transform_property: String = _get_offset_scale_property()
        scale_tween.tween_property(params.target_node, scale_transform_property, params.scale.end, params.scale.duration).from(params.scale.start).set_delay(params.scale.delay)

    if params.phase:
        _tween_safety_check(params.target_node, "phase")
        _prepare_for_phase_tween(params.target_node, params.phase.start)
        phase_tween = params.target_node.create_tween()
        phase_tweens[params.target_node] = phase_tween
        phase_tween.set_trans(params.phase.transition_type)
        phase_tween.set_ease(params.phase.ease_type)
        var phase_transform_property: String = _get_offset_alpha_property()
        phase_tween.tween_property(params.target_node, phase_transform_property, params.phase.end, params.phase.duration).from(params.phase.start).set_delay(params.phase.delay)

    if params.color:
        _tween_safety_check(params.target_node, "color")
        _prepare_for_color_tween(params.target_node, params.color.start)
        color_tween = params.target_node.create_tween()
        color_tweens[params.target_node] = color_tween
        color_tween.set_trans(params.color.transition_type)
        color_tween.set_ease(params.color.ease_type)
        var color_transform_property: String = _get_offset_color_property(params.target_node)
        color_tween.tween_property(params.target_node, color_transform_property, params.color.end, params.color.duration).from(params.color.start).set_delay(params.color.delay)

    return {"slide": slide_tween, "rotate": rotate_tween, "scale": scale_tween, "phase": phase_tween, "color": color_tween}

func wait_for_all(tweens: Variant) -> void:
    if tweens is Array:
        for tween in tweens:
            for key in tween.keys():
                var v = tween.get(key)

                if v and v.is_running():
                    await v.finished

                # print(key, " finished")
    elif tweens is Dictionary:
        for key in tweens.keys():
                var v = tweens.get(key)

                if v and v.is_running():
                    await v.finished

                # print(key, " finished")

func all_tweens_finished() -> bool:
    for key in slide_tweens:
        if slide_tweens[key].is_running():
            return false

    for key in rotate_tweens:
        if rotate_tweens[key].is_running():
            return false

    for key in scale_tweens:
        if scale_tweens[key].is_running():
            return false

    for key in phase_tweens:
        if phase_tweens[key].is_running():
            return false

    for key in color_tweens:
        if color_tweens[key].is_running():
            return false

    return true
