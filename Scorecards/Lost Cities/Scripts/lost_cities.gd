extends MarginContainer

@export var number_selector: Control

@onready var main_menu: MarginContainer = get_node("/root/MainMenu")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _connect_all_color_buttons()

func _connect_all_color_buttons() -> void:
    for button in get_tree().get_nodes_in_group("LostCitiesNumberButton"):
        button = button as Button

        if button:
            button.pressed.connect(_show_number_selector.bind(button))

func _show_number_selector(target: Control) -> void:
    var color_group: StringName
    var groups := target.get_groups()
    for group in groups:
        if group.match("LostCitiesColumn*"):
            color_group = group

    var below_button_number := target.name.substr(6).to_int() + 1
    var above_button_number := target.name.substr(6).to_int() - 1
    var previous_number := -1
    var next_number := 99

    # print("Sought Num: ", sought_number)

    for button in get_tree().get_nodes_in_group(color_group):
        button = button as Button

        if button:
            var num = button.name.substr(6).to_int()

            if num == below_button_number:
                previous_number = (button.get_node("Label") as Label).text.to_int()
                # print("Previous Num: ", previous_number)

            if num == above_button_number:
                next_number = (button.get_node("Label") as Label).text.to_int() if (button.get_node("Label") as Label).text.to_int() > 0 else next_number
                # print("Next Num: ", next_number)

    if below_button_number == 10 or previous_number > 0:
        main_menu.on_show_lc_num_selector(number_selector)
        number_selector.prepare_number_selector(target, previous_number, next_number)
    else:
        main_menu.on_shake_num_button(target)
