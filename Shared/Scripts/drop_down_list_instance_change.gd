extends Control

@export var expand_time := 0.15

@export var toggle_button: Button
@export var collapse_control: Control
@export var collapsable_content: MarginContainer

@onready var main_menu: MarginContainer = get_node("/root/MainMenu")
@onready var switch_buttons: Array[Node] = $CollapseControl/CollapsableContent/VBoxContainer.get_children() as Array[Node]

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    collapse_control.clip_contents = true
    toggle_button.toggled.connect(_on_button_toggled)


    collapse_control.anchor_top = toggle_button.anchor_bottom
    collapse_control.anchor_bottom = toggle_button.anchor_bottom
    collapse_control.anchor_left = toggle_button.anchor_left
    collapse_control.anchor_right = toggle_button.anchor_right

    collapse_control.grow_vertical = Control.GROW_DIRECTION_END

    for but: Button in switch_buttons:
        var matching_instance: MarginContainer

        for con: MarginContainer in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            if con.name == but.name:
                matching_instance = con
                break

        if matching_instance:
            but.pressed.connect(main_menu.on_switch_instance.bind(matching_instance))


func _on_button_toggled(toggled_on: bool) -> void:
    if tween:
        tween.kill()

    if toggled_on:
        for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            if con.visible:
                for but in switch_buttons:
                    if con.name == but.name:
                        but.visible = false
                    else:
                        but.visible = true

        tween = create_tween()
        tween.tween_property(collapse_control, "custom_minimum_size:y", collapsable_content.size.y, expand_time)
    else:
        tween = create_tween()
        tween.tween_property(collapse_control, "custom_minimum_size:y", 0, expand_time)

func manually_toggle_button_off() -> void:
    toggle_button.button_pressed = false
    # _on_button_toggled(false)
