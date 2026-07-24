extends Control

signal slide_in_finished(target_node: Control)
signal slide_out_finished(target_node: Control)
var tweens := {}

func slide_in(target_node: Control, relative_direction: Vector2, position_by_ratio: bool, duration: float,
              transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    target_node.offset_transform_enabled = true
    target_node.offset_transform_visual_only = false
    var start: Vector2 = target_node.position - relative_direction.normalized()
    var end: Vector2 = target_node.position

    # tweening safety check
    if tweens.has(target_node):
        tweens[target_node].kill()
        tweens.erase(target_node)

    var transform_property: String = "offset_transform_position_ratio" if position_by_ratio else "offset_transform_position"
    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    target_node.visible = true
    await tween.finished
    slide_in_finished.emit(target_node)

func slide_out(target_node: Control, relative_direction: Vector2, position_by_ratio: bool, duration: float,
              transition_type: Tween.TransitionType = Tween.TRANS_QUINT, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
    target_node.offset_transform_enabled = true
    target_node.offset_transform_visual_only = false
    var start: Vector2 = target_node.position
    var end: Vector2 = target_node.position + relative_direction.normalized()

    # tweening safety check
    if tweens.has(target_node):
        tweens[target_node].kill()
        tweens.erase(target_node)

    var transform_property: String = "offset_transform_position_ratio" if position_by_ratio else "offset_transform_position"
    var tween := target_node.create_tween()
    tweens[target_node] = tween
    tween.set_trans(transition_type)
    tween.set_ease(ease_type)
    tween.tween_property(target_node, transform_property, end, duration).from(start)
    await tween.finished
    target_node.visible = false
    slide_out_finished.emit(target_node)

func all_tweens_finished() -> bool:
    var all_complete: bool = true

    for key in tweens:
        if tweens[key].is_running():
            all_complete = false
            break

    return all_complete
