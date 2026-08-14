extends Control

@export var expand_time := 0.15

@export var toggle_button: Button
@export var collapse_control: Control
@export var collapsable_content: MarginContainer

@onready var main_menu: MarginContainer = get_tree().current_scene
var switch_buttons: Array[Node]

var tween: Tween
var first_run: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    collapse_control.clip_contents = true
    toggle_button.toggled.connect(_on_button_toggled)
    toggle_button.focus_exited.connect(manually_toggle_button_off)

    collapse_control.grow_vertical = Control.GROW_DIRECTION_END

    var button_parent: VBoxContainer = collapsable_content.get_node("ButtonParent")

    var data = main_menu.scorecard_data

    for card in data:
        var btn := Button.new()
        var lbl := Label.new()
        lbl.text = data[card].scorecard_name
        lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        lbl.theme_type_variation = "Scorecard_SwitchInstanceChildLabel"
        btn.theme_type_variation = "Scorecard_SwitchInstanceChildButton"
        lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
        btn.add_child(lbl)
        var instance: Control = data[card].get_instance()
        btn.name = instance.name
        button_parent.add_child(btn)
        btn.custom_minimum_size = Vector2(0, lbl.get_combined_minimum_size().y)
        switch_buttons.append(btn)
        btn.pressed.connect(main_menu.on_switch_scorecard_instance.bind(card))

    toggle_button.button_pressed = true
    button_parent.queue_sort()
    call_deferred("manually_toggle_button_off")

func _on_button_toggled(toggled_on: bool) -> void:
    if tween:
        tween.kill()

    if toggled_on:
        var rect: Rect2 = toggle_button.get_global_rect()

        collapse_control.position.x = rect.position.x
        collapse_control.position.y = rect.position.y + rect.size.y
        collapse_control.size.x = rect.size.x
        collapse_control.size.y = 0

        for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            if con.visible:
                for but in switch_buttons:
                    if con.name == but.name:
                        but.visible = false
                    else:
                        but.visible = true

        tween = create_tween()
        tween.tween_property(collapse_control, "custom_minimum_size:y", collapsable_content.size.y, expand_time)

        if not first_run:
            z_index = 150
            main_menu.set_input_blocker_connection(manually_toggle_button_off)
            main_menu.lock_ui()
    else:
        tween = create_tween()
        tween.tween_property(collapse_control, "custom_minimum_size:y", 0, expand_time)
        z_index = 0

func manually_toggle_button_off() -> void:
    toggle_button.button_pressed = false

    if first_run:
        first_run = false
