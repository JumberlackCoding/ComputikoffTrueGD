class_name TweenController
extends Control

var active_tweens: Dictionary[Control, Tween] = {}
var base_z := {}

signal universal_tween_finished(params: TweenParams)

func _ready() -> void:
    universal_tween_finished.connect(cleanup_tween)

    _set_base_z()

func _set_base_z() -> void:
    print("hi")
    var all_nodes := _get_all_nodes()

    for node in all_nodes:
        if node is Control:
            base_z[node] = node.z_index

func _get_all_nodes() -> Array:
    var all_nodes := []
    _collect_node(get_tree().root, all_nodes)
    return all_nodes

func _collect_node(node: Node, out: Array) -> void:
    out.append(node)

    print(node.name)

    for child in node.get_children():
        _collect_node(child, out)

func _prepare_for_tween(target_node: Control, offset_pivot: Vector2 = Vector2.ZERO, offset_pivot_ratio: Vector2 = Vector2(0.5, 0.5), move_z_index_to_frontish: bool = true) -> void:
    if move_z_index_to_frontish:
        target_node.z_index += 10

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

    print(base_z)

    if params.move_z_index_to_frontish:
        if base_z.has(params.target_node):
            params.target_node.z_index = base_z[params.target_node]
        else:
            push_error("Failed to retrieve z_index for: ", params.target_node.name)

    params.target_node.offset_transform_enabled = false

    params.target_node.visible = params.final_visibility
    params.target_node.modulate.a = params.final_alpha

    if active_tweens.has(params.target_node):
        active_tweens.erase(params.target_node)

func _tween_safety_check(target_node: Control) -> void:
    if active_tweens.has(target_node):
        var old := active_tweens[target_node]
        if old and old.is_running():
            old.kill()
        active_tweens.erase(target_node)

func _get_offset_position_property(use_ratio: bool) -> String:
    return "offset_transform_position_ratio" if use_ratio else "offset_transform_position"

func _get_offset_rotation_property() -> String:
    return "offset_transform_rotation"

func _get_offset_scale_property() -> String:
    return "offset_transform_scale"

func _get_offset_alpha_property() -> String:
    return "modulate:a"

func _get_offset_color_property(target_node: Control) -> String:
    return "color" if target_node is ColorRect else "self_modulate"

func _add_prop(tween: Tween, target: Control, prop_name: String, start_val: Variant, end_val: Variant, duration: float, delay: float, trans_type: Tween.TransitionType, ease_type: Tween.EaseType) -> void:
        var track = tween.parallel().tween_property(target, prop_name, end_val, duration)
        track.from(start_val)
        track.set_delay(delay)
        track.set_trans(trans_type)
        track.set_ease(ease_type)

func universal_tween(params: TweenParams, perform_prepare_and_safety_check := true, signal_cleanup_when_finished := true, on_complete: Callable = Callable()) -> Tween:
    if not params.target_node:
        push_error("TweenParams missing target_node.")
        return null
    elif not params.target_node.is_inside_tree():
        push_error("TweenParams target_node is not inside the scene tree.")
        return null

    if perform_prepare_and_safety_check:
        _prepare_for_tween(params.target_node, params.pivot, params.pivot_ratio, params.move_z_index_to_frontish)
        _tween_safety_check(params.target_node)

    var tween := params.target_node.create_tween()
    active_tweens[params.target_node] = tween

    if params.slide:
        if perform_prepare_and_safety_check:
            _prepare_for_slide_tween(params.target_node, params.slide.start, params.slide.by_ratio)
        _add_prop(tween, params.target_node, _get_offset_position_property(params.slide.by_ratio), params.slide.start, params.slide.end, params.slide.duration, params.slide.delay, params.slide.transition_type, params.slide.ease_type)

    if params.rotate:
        if perform_prepare_and_safety_check:
            _prepare_for_rotate_tween(params.target_node, params.rotate.start)
        _add_prop(tween, params.target_node, _get_offset_rotation_property(), params.rotate.start, params.rotate.end, params.rotate.duration, params.rotate.delay, params.rotate.transition_type, params.rotate.ease_type)

    if params.scale:
        if perform_prepare_and_safety_check:
            _prepare_for_scale_tween(params.target_node, params.scale.start)
        _add_prop(tween, params.target_node, _get_offset_scale_property(), params.scale.start, params.scale.end, params.scale.duration, params.scale.delay, params.scale.transition_type, params.scale.ease_type)

    if params.phase:
        if perform_prepare_and_safety_check:
            _prepare_for_phase_tween(params.target_node, params.phase.start)
        _add_prop(tween, params.target_node, _get_offset_alpha_property(), params.phase.start, params.phase.end, params.phase.duration, params.phase.delay, params.phase.transition_type, params.phase.ease_type)

    if params.color:
        if perform_prepare_and_safety_check:
            _prepare_for_color_tween(params.target_node, params.color.start)
        _add_prop(tween, params.target_node, _get_offset_color_property(params.target_node), params.color.start, params.color.end, params.color.duration, params.color.delay, params.color.transition_type, params.color.ease_type)

    tween.tween_callback(_on_universal_tween_complete.bind(params, signal_cleanup_when_finished, on_complete))

    return tween

func _on_universal_tween_complete(params: TweenParams, do_cleanup: bool, last_action: Callable) -> void:
    if do_cleanup:
        cleanup_tween(params)

    if last_action and last_action.is_valid():
        last_action.call()

func tween_text(target: Label, final_text: String, duration: float, from_text: String = "99") -> Tween:
    var tween: Tween = target.create_tween()
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(target, "text", final_text, duration).from(from_text)
    return tween

func tween_text_size(target: Label, final_size: int, duration: float) -> void:
    var tween: Tween = target.create_tween()
    tween.set_trans(Tween.TRANS_LINEAR)
    var start_size = target.get_theme_font_size("font_size")
    tween.tween_method(
        func(new_size):
            target.add_theme_font_size_override("font_size", new_size), start_size, final_size, duration)

func tween_override_stylebox_shadow(lbl: Label, shadow_color: Color, shadow_final_size: int, duration: float) -> void:
    var existing_stylebox := lbl.get_theme_stylebox("normal")
    var new_stylebox := existing_stylebox.duplicate() as StyleBoxFlat
    lbl.add_theme_stylebox_override("normal", new_stylebox)
    new_stylebox.shadow_color = shadow_color

    var tween = lbl.create_tween()
    tween.tween_method(
        func(new_size):
            new_stylebox.shadow_size = new_size
            lbl.add_theme_stylebox_override("normal", new_stylebox), 0, shadow_final_size, duration)

func tween_remove_override_stylebox_shadow(lbl: Label, shadow_start_size: int, duration: float) -> void:
    var existing_stylebox := lbl.get_theme_stylebox("normal")
    var tween = lbl.create_tween()
    await tween.tween_method(
        func(new_size):
            existing_stylebox.shadow_size = new_size
            lbl.add_theme_stylebox_override("normal", existing_stylebox), shadow_start_size, 0, duration).finished
    lbl.remove_theme_stylebox_override("normal")

func wait_for_all(tweens: Array) -> void:
    for tween in tweens:
        if tween and tween.is_running():
            await tween.finished

        # print(key, " finished")

func print_all_tweens() -> void:
    print("========= All Tweens =========")
    for key in active_tweens:
        var v = active_tweens.get(key)
        print("Key: ", key, " for tween: ", v)
        if v and v.is_running():
            await v.finished
        # print(key, " slide finished")

func all_tweens_finished() -> bool:
    for key in active_tweens:
        var v = active_tweens.get(key)
        if v and v.is_running():
            return false

    return true
