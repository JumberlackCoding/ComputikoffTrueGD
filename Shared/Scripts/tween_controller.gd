extends Control

signal generic_tween_finished(target_node: Control)
signal slide_in_finished(target_node: Control)
signal phase_in_finished(target_node: Control)
signal slide_phase_and_scale_finished(target_node: Control, direction_in: bool)

var tweens := {}
var z_indexes := {}

func _prepare_for_tween(target_node: Control, alpha_start: float = 1.0, position_start: Vector2 = Vector2.ZERO, position_by_ratio: bool = false, scale_start: Vector2 = Vector2.ONE) -> void:
    target_node.offset_transform_enabled = true
    target_node.offset_transform_visual_only = false
    z_indexes[target_node] = target_node.z_index
    target_node.z_index = 5

    if position_by_ratio:
        target_node.offset_transform_position_ratio = position_start
    else:
        target_node.offset_transform_position = position_start

    target_node.offset_transform_scale = scale_start
    target_node.modulate.a = alpha_start
    target_node.visible = true

func _cleanup_for_tween(target_node: Control) -> void:
    target_node.offset_transform_position = Vector2.ZERO
    target_node.offset_transform_position_ratio = Vector2.ZERO
    target_node.offset_transform_scale = Vector2.ONE
    target_node.modulate.a = 1

    if z_indexes.has(target_node):
        target_node.z_index = z_indexes[target_node]
    else:
        target_node.z_index = 0

    target_node.offset_transform_enabled = false

func _tween_safety_check(target_node: Control) -> void:
    if tweens.has(target_node):
        tweens[target_node].kill()
        tweens.erase(target_node)

func _debug_params(p: Dictionary):
    print("=== Debug Params ===")
    for key in p.keys():
        print(key, ": ", p[key])

func _get_offset_pos_property(use_ratio: bool) -> String:
    return "offset_transform_position_ratio" if use_ratio else "offset_transform_position"

func _get_offset_scale_property() -> String:
    return "offset_transform_scale"

func _get_offset_alpha_property() -> String:
    return "modulate:a"

func slide_in(target_node: Control, to_position: Vector2, position_by_ratio: bool, duration: float,
              transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node)

    var start: Vector2 = target_node.position - to_position
    var end: Vector2 = target_node.position
    var transform_property: String = _get_offset_pos_property(position_by_ratio)

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    await tween.finished
    _cleanup_for_tween(target_node)
    slide_in_finished.emit(target_node)

func slide_out(target_node: Control, to_position: Vector2, position_by_ratio: bool, duration: float,
               transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node)

    var start: Vector2 = target_node.position
    var end: Vector2 = target_node.position + to_position
    var transform_property: String = _get_offset_pos_property(position_by_ratio)

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    await tween.finished
    target_node.visible = false
    _cleanup_for_tween(target_node)
    generic_tween_finished.emit(target_node)


func slide_phase_and_scale(target_node: Control, position_start: Vector2, position_end: Vector2, position_by_ratio: bool, duration_slide: float, duration_scale: float, duration_phase: float,
                           slide_delay: float, scale_delay: float, phase_delay: float, phase_start: float, phase_end: float, scale_start: Vector2, scale_end: Vector2, direction_in: bool,
                           transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT, scale_pivot_ratio: Vector2 = Vector2(0.5, 0.5)) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node, phase_start, position_start, position_by_ratio, scale_start)
    target_node.offset_transform_pivot_ratio = scale_pivot_ratio

    var end_slide: Vector2 = - position_end
    var slide_transform_property: String = _get_offset_pos_property(position_by_ratio)
    var scale_transform_property: String = _get_offset_scale_property()
    var phase_transform_property: String = _get_offset_alpha_property()

    var params := {"target_node": target_node, "from_position": position_start, "to_position": position_end, "position_by_ratio": position_by_ratio, "duration_slide": duration_slide,
                   "duration_scale": duration_scale, "duration_phase": duration_phase, "slide_delay": slide_delay, "scale_delay": scale_delay, "phase_delay": phase_delay,
                   "phase_start": phase_start, "phase_end": phase_end, "start_scale": scale_start, "end_scale": scale_end, "direction_in": direction_in,
                   "transition_type": transition_type, "ease_type": ease_type, "scale_pivot_ratio": scale_pivot_ratio}

    _debug_params(params)

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, slide_transform_property, end_slide, duration_slide).from(position_start).set_delay(slide_delay)
    tween.parallel().tween_property(target_node, scale_transform_property, scale_end, duration_scale).from(scale_start).set_delay(scale_delay)
    tween.parallel().tween_property(target_node, phase_transform_property, phase_end, duration_phase).from(phase_start).set_delay(phase_delay)
    await tween.finished
    _cleanup_for_tween(target_node)
    slide_phase_and_scale_finished.emit(target_node, direction_in)

func phase_in(target_node: Control, duration: float, transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node, 0)

    var start: int = 0
    var end: int = 1
    var transform_property: String = _get_offset_alpha_property()

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    target_node.visible = true
    await tween.finished
    _cleanup_for_tween(target_node)
    phase_in_finished.emit(target_node)

func phase_out(target_node: Control, duration: float, transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node)

    var start: int = 1
    var end: int = 0
    var transform_property: String = _get_offset_alpha_property()

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    await tween.finished
    target_node.visible = false
    _cleanup_for_tween(target_node)
    generic_tween_finished.emit(target_node)

func tween_color_rect_color(target_node: Control, new_color: Color, duration: float, transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node)
    var colorRect = target_node as ColorRect

    if colorRect:
        var start: Color = colorRect.color
        var end: Color = new_color
        var transform_property: String = "color"

        var tween := target_node.create_tween()
        tweens[target_node] = tween
        tween.set_trans(transition_type)
        tween.set_ease(ease_type)
        tween.tween_property(target_node, transform_property, end, duration).from(start)
        await tween.finished

    _cleanup_for_tween(target_node)
    generic_tween_finished.emit(target_node)

func phase_and_scale_in(target_node: Control, duration_phase: float, start_phase: float, duration_scale: float, start_scale: Vector2, end_scale: Vector2, scale_pivot_ratio: Vector2,
                        transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node, start_phase)

    target_node.modulate.a = 0

    var end_phase: float = 1.0
    var phase_transform_property: String = _get_offset_alpha_property()
    var scale_transform_property: String = _get_offset_scale_property()
    target_node.offset_transform_pivot_ratio = scale_pivot_ratio

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, phase_transform_property, end_phase, duration_phase).from(start_phase)
    tween.parallel().tween_property(target_node, scale_transform_property, end_scale, duration_scale).from(start_scale)
    await tween.finished
    _cleanup_for_tween(target_node)
    generic_tween_finished.emit(target_node)

func phase_and_scale_out(target_node: Control, duration_phase: float, end_phase: float, duration_scale: float, start_scale: Vector2, end_scale: Vector2, scale_pivot_ratio: Vector2,
                         transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
    _prepare_for_tween(target_node)

    var start_phase: float = 1.0
    var phase_transform_property: String = _get_offset_alpha_property()
    var scale_transform_property: String = _get_offset_scale_property()
    target_node.offset_transform_pivot_ratio = scale_pivot_ratio

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, phase_transform_property, end_phase, duration_phase).from(start_phase)
    tween.parallel().tween_property(target_node, scale_transform_property, end_scale, duration_scale).from(start_scale)
    await tween.finished
    target_node.visible = false
    _cleanup_for_tween(target_node)
    generic_tween_finished.emit(target_node)

func shake(target_node: Control, to_position: Vector2, position_by_ratio: bool, repetition_duration: float, repetitions: int, intensity: float,
              transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _prepare_for_tween(target_node)

    var starting_pos = Vector2.ZERO
    var transform_property: String = _get_offset_pos_property(position_by_ratio)

    for rep in range(repetitions):
        _tween_safety_check(target_node)
        var start_1: Vector2 = starting_pos
        var end_1: Vector2 = starting_pos + (to_position.normalized() * intensity)
        print("S: ", start_1, " E: ", end_1)
        var tween := target_node.create_tween()
        tweens[target_node] = tween
        tween.set_trans(transition_type)
        tween.set_ease(ease_type)
        tween.tween_property(target_node, transform_property, end_1, repetition_duration).from(start_1)
        await tween.finished
        _tween_safety_check(target_node)
        var start_2: Vector2 = starting_pos + (to_position.normalized() * intensity)
        var end_2: Vector2 = starting_pos - (to_position.normalized() * intensity)
        tween = target_node.create_tween()
        tweens[target_node] = tween
        tween.set_trans(transition_type)
        tween.set_ease(ease_type)
        tween.tween_property(target_node, transform_property, end_2, repetition_duration * 2).from(start_2)
        await tween.finished
        _tween_safety_check(target_node)
        var start_3: Vector2 = starting_pos - (to_position.normalized() * intensity)
        var end_3: Vector2 = starting_pos
        tween = target_node.create_tween()
        tweens[target_node] = tween
        tween.set_trans(transition_type)
        tween.set_ease(ease_type)
        tween.tween_property(target_node, transform_property, end_3, repetition_duration).from(start_3)
        await tween.finished

    _cleanup_for_tween(target_node)
    generic_tween_finished.emit(target_node)

func all_tweens_finished() -> bool:
    var all_complete: bool = true
    for key in tweens:
        if tweens[key].is_running():
            all_complete = false
            break

    return all_complete
