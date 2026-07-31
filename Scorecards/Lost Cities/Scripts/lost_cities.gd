extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _connect_all_color_buttons()

func _connect_all_color_buttons() -> void:
    for button in get_tree().get_nodes_in_group("LostCitiesNumberButton"):
        button = button as Button

        if button:
            button.pressed.connect(_show_number_selector.bind(button))

func _show_number_selector(target: Control) -> void:
    pass