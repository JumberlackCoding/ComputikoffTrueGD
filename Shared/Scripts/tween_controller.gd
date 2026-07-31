extends Control

signal slide_in_finished(target_node: Control)
signal slide_out_finished(target_node: Control)
signal phase_in_finished(target_node: Control)
signal phase_out_finished(target_node: Control)
signal tween_color_finished(target_node: Control)

var tweens := {}

func _prepare_for_slide(target_node: Control) -> void:
    target_node.offset_transform_enabled = true
    target_node.offset_transform_visual_only = false
    target_node.visible = true

func _cleanup_for_slide(target_node: Control) -> void:
    target_node.offset_transform_position = Vector2.ZERO
    target_node.offset_transform_position_ratio = Vector2.ZERO
    target_node.offset_transform_enabled = false

func _tween_safety_check(target_node: Control) -> void:
    if tweens.has(target_node):
        tweens[target_node].kill()
        tweens.erase(target_node)

func slide_in(target_node: Control, relative_direction: Vector2, position_by_ratio: bool, duration: float,
              transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _prepare_for_slide(target_node)
    _tween_safety_check(target_node)

    var start: Vector2 = target_node.position - relative_direction.normalized()
    var end: Vector2 = target_node.position
    var transform_property: String = "offset_transform_position_ratio" if position_by_ratio else "offset_transform_position"

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    await tween.finished
    _cleanup_for_slide(target_node)
    slide_in_finished.emit(target_node)

func slide_out(target_node: Control, relative_direction: Vector2, position_by_ratio: bool, duration: float,
               transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _prepare_for_slide(target_node)
    _tween_safety_check(target_node)

    var start: Vector2 = target_node.position
    var end: Vector2 = target_node.position + relative_direction.normalized()
    var transform_property: String = "offset_transform_position_ratio" if position_by_ratio else "offset_transform_position"

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    await tween.finished
    target_node.visible = false
    _cleanup_for_slide(target_node)
    slide_out_finished.emit(target_node)

func phase_in(target_node: Control, duration: float, transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)

    var start: int = 0
    var end: int = 1
    var transform_property: String = "modulate:a"

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    target_node.visible = true
    await tween.finished
    phase_in_finished.emit(target_node)

func phase_out(target_node: Control, duration: float, transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)

    var start: int = 1
    var end: int = 0
    var transform_property: String = "modulate:a"

    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    await tween.finished
    target_node.visible = false
    target_node.modulate.a = 1
    phase_out_finished.emit(target_node)

func tween_color_rect_color(target_node: Control, new_color: Color, duration: float, transition_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    _tween_safety_check(target_node)
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
        tween_color_finished.emit(target_node)


func all_tweens_finished() -> bool:
    var all_complete: bool = true

    for attempts in range(3):
        for key in tweens:
            if tweens[key].is_running():
                all_complete = false
                break

        if all_complete:
            break
        else:
            await get_tree().process_frame

    return all_complete
