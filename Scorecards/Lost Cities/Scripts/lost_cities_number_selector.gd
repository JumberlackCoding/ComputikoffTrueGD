extends Control

@export var disabled_text_color: Color

@onready var lost_cities: LostCities = %LostCities
@onready var button_container: GridContainer = $PanelContainer/MarginContainer/GridContainer
@onready var go_away_button: Button = $GoAwayButton
@onready var main_menu: MarginContainer = get_node("/root/MainMenu")

var colored_button_pressed: Button
var space_contains_vase: bool = false
var space_contains_arrow: bool = false
var delay_between_arrow_anims: float = 0.20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    visible = true
    go_away_button.pressed.connect(_go_away)

    for button in button_container.get_children():
        button = button as Button

        if button:
            button.pressed.connect(_number_selected.bind(button))

    call_deferred("_hide_after_ready")

func _hide_after_ready() -> void:
    visible = false

func _number_selected(button_selected: Control):
    var selection_label = button_selected.get_node("Label") as Label
    var colored_label = colored_button_pressed.get_node("Label") as Label

    if button_selected.name.match("Button*"):
        if selection_label and colored_label:
            var prev_text: String = colored_label.text
            colored_label.text = selection_label.text
            await _go_away()
            main_menu.lock_ui()
            if space_contains_vase:
                if prev_text.is_empty():
                    var vase := lost_cities.get_next_vase()
                    if vase:
                        await main_menu.animate_vase(vase)
                        vase.scribble()
            if space_contains_arrow:
                var next_button := lost_cities.get_next_button(colored_button_pressed)
                var lbl := next_button.get_node("Label") as Label
                if lbl:
                    # await get_tree().create_timer(delay_between_arrow_anims).timeout
                    await main_menu.animate_arrow_up(colored_button_pressed)
                    lbl.text = selection_label.text
                if next_button.has_node("Arrow"):
                    var next_next_button := lost_cities.get_next_button(next_button)
                    var lbl2 := next_next_button.get_node("Label") as Label
                    if lbl2:
                        # await get_tree().create_timer(delay_between_arrow_anims).timeout
                        await main_menu.animate_arrow_up(next_button)
                        lbl2.text = selection_label.text
            else:
                var prev_button := lost_cities.get_prev_button(colored_button_pressed)
                if prev_button and prev_button.has_node("Arrow"):
                    await main_menu.animate_arrow_down(colored_button_pressed)
                    var lbl3 := prev_button.get_node("Label") as Label
                    if lbl3:
                        lbl3.text = selection_label.text
                    var prev_prev_button := lost_cities.get_prev_button(prev_button)
                    if prev_prev_button.has_node("Arrow"):
                        await main_menu.animate_arrow_down(prev_button)
                        var lbl4 := prev_prev_button.get_node("Label") as Label
                        if lbl4:
                            lbl4.text = selection_label.text
            main_menu.try_unlock_ui()
    elif button_selected.name.match("Clear"):
        if colored_label:
            var prev_text: String = colored_label.text
            colored_label.text = ""
            await _go_away()
            main_menu.lock_ui()
            if not prev_text.is_empty() and colored_button_pressed.has_node("Vase"):
                var vase := lost_cities.get_cur_vase()
                if vase:
                    if vase:
                        await main_menu.animate_vase(vase)
                        vase.clear_scribbles()
            var clearing: bool = true
            var next_button := colored_button_pressed
            var cur_button := colored_button_pressed
            while (clearing):
                cur_button = next_button
                next_button = lost_cities.get_next_button(cur_button)
                if next_button:
                    var lbl := next_button.get_node("Label") as Label
                    if lbl and not lbl.text.is_empty():
                        await main_menu.animate_arrow_up(cur_button)
                        lbl.text = ""
                        if next_button.has_node("Vase"):
                            var vase := lost_cities.get_cur_vase()
                            if vase:
                                await main_menu.animate_vase(vase)
                                vase.clear_scribbles()
                else:
                    clearing = false
            var prev_button := lost_cities.get_prev_button(colored_button_pressed)
            if prev_button.has_node("Arrow"):
                await main_menu.animate_arrow_down(colored_button_pressed)
                var lbl3 := prev_button.get_node("Label") as Label
                if lbl3:
                    lbl3.text = ""
                var prev_prev_button := lost_cities.get_prev_button(prev_button)
                if prev_prev_button.has_node("Arrow"):
                    await main_menu.animate_arrow_down(prev_button)
                    var lbl4 := prev_prev_button.get_node("Label") as Label
                    if lbl4:
                        lbl4.text = ""
            main_menu.try_unlock_ui()

    await _go_away()
    _clear_colored_button()

func _go_away() -> void:
    if visible:
        await main_menu.on_hide_lc_num_selector(self, colored_button_pressed)

func _clear_colored_button() -> void:
    colored_button_pressed = null

func prepare_number_selector(button: Control, prev_num: int = -1, next_num: int = 99, vase: bool = false, arrow: bool = false):
    colored_button_pressed = button
    space_contains_vase = vase
    space_contains_arrow = arrow

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
        # if but and but.name.match("Clear"):
        #     if next_num <= 10:
        #         but.disabled = true
        #         (but.get_node("Label") as Label).add_theme_color_override("font_color", disabled_text_color)
        #     else:
        #         but.disabled = false
        #         (but.get_node("Label") as Label).remove_theme_color_override("font_color")
