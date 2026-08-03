extends Control

@export var disabled_text_color: Color

@onready var button_container: GridContainer = $PanelContainer/MarginContainer/GridContainer
@onready var go_away_button: Button = $GoAwayButton
@onready var main_menu: MarginContainer = get_node("/root/MainMenu")

var colored_button_pressed: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    go_away_button.pressed.connect(_go_away)

    for button in button_container.get_children():
        button = button as Button

        if button:
            button.pressed.connect(_number_selected.bind(button))

func _number_selected(button: Control):
    var selection_label = button.get_node("Label") as Label
    var colored_label = colored_button_pressed.get_node("Label") as Label

    if button.name.match("Button*"):
        if selection_label and colored_label:
            colored_label.text = selection_label.text
    elif button.name.match("Clear"):
        if colored_label:
            colored_label.text = ""

    _go_away()

func _go_away():
    colored_button_pressed = null
    main_menu.on_hide_lc_num_selector(self)

func prepare_number_selector(button: Control, prev_num: int = -1, next_num: int = 99):
    colored_button_pressed = button

    for but in button_container.get_children():
        but = but as Button

        if but and but.name.match("Button*"):
            var number_on_button = (but.get_node("Label") as Label).text.to_int()

            if number_on_button and (number_on_button < prev_num or number_on_button > next_num):
                but.disabled = true
                (but.get_node("Label") as Label).add_theme_color_override("font_color", disabled_text_color)
            else:
                but.disabled = false
                (but.get_node("Label") as Label).remove_theme_color_override("font_color")
        if but and but.name.match("Clear"):
            if next_num <= 10:
                but.disabled = true
                (but.get_node("Label") as Label).add_theme_color_override("font_color", disabled_text_color)
            else:
                but.disabled = false
                (but.get_node("Label") as Label).remove_theme_color_override("font_color")
