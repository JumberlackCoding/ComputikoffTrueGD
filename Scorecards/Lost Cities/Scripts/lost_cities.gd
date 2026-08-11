extends MarginContainer

@export var number_selector: Control

@onready var main_menu: MarginContainer = get_tree().current_scene

const COLOR_COLUMN_POINTS = [-20, -15, -10, 5, 10, 15, 30, 35, 50, 0]
const VASE_DICE_COLUMN_POINTS = [-40, -30, -20, 10, 20, 30, 60, 70, 100, 0]

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
        main_menu.on_show_lc_num_selector(number_selector, target)
        number_selector.prepare_number_selector(target, previous_number, next_number)
    else:
        main_menu.on_shake_num_button(target)

func _get_number(button: Button) -> int:
    return button.get_node("Label").text.to_int()

func _get_highest_entered_number_index(column: Array[Node]) -> int:
    var highest_index: int = -1

    for i in range(column.size()):
        var button: Button = column[i] as Button

        if button:
            if _get_number(button) > 0:
                highest_index = i
            else:
                break

    return highest_index

func _get_highest_scribbled_index(column: Array[Node]) -> int:
    var highest_index: int = -1

    for i in range(column.size()):
        var button: Button = column[i] as Button

        if button:
            if button.is_scribbled():
                highest_index = i
            else:
                break

    return highest_index

func _get_bridge_points(bridges: Array[Node]) -> int:
    var points := 0

    for bridge in bridges:
        if bridge.is_circled():
            points += 20

    return points

func _get_color_column_points(index: int) -> int:
    return COLOR_COLUMN_POINTS[index]

func _get_vase_dice_column_points(index: int) -> int:
    return VASE_DICE_COLUMN_POINTS[index]

func _check_for_neg_hundred(points: int, color: String) -> int:
    var actual_points: int = points

    if get_node("%" + color + "Symbol").is_xed():
        if points == 0:
            actual_points = -100
        else:
            actual_points *= 2

    return actual_points

func _check_for_zero_dice(points: int) -> int:
    if points == 100:
        points = 0

    return points

func calculate() -> Dictionary:
    var points := {}

    var red_column := get_tree().get_nodes_in_group("LostCitiesColumnRed")
    var orange_column := get_tree().get_nodes_in_group("LostCitiesColumnOrange")
    var yellow_column := get_tree().get_nodes_in_group("LostCitiesColumnYellow")
    var green_column := get_tree().get_nodes_in_group("LostCitiesColumnGreen")
    var blue_column := get_tree().get_nodes_in_group("LostCitiesColumnBlue")
    var purple_column := get_tree().get_nodes_in_group("LostCitiesColumnPurple")
    var vase_column := get_tree().get_nodes_in_group("LostCitiesColumnVase")
    var dice_column := get_tree().get_nodes_in_group("LostCitiesColumnDice")
    var bridges := get_tree().get_nodes_in_group("LostCitiesBridges")

    red_column.reverse()
    orange_column.reverse()
    yellow_column.reverse()
    green_column.reverse()
    blue_column.reverse()
    purple_column.reverse()
    vase_column.reverse()
    dice_column.reverse()

    points["red"] = _check_for_neg_hundred(_get_color_column_points(_get_highest_entered_number_index(red_column)), "Red")
    points["red_count"] = _get_highest_entered_number_index(red_column)
    points["orange"] = _check_for_neg_hundred(_get_color_column_points(_get_highest_entered_number_index(orange_column)), "Orange")
    points["orange_count"] = _get_highest_entered_number_index(orange_column)
    points["yellow"] = _check_for_neg_hundred(_get_color_column_points(_get_highest_entered_number_index(yellow_column)), "Yellow")
    points["yellow_count"] = _get_highest_entered_number_index(yellow_column)
    points["green"] = _check_for_neg_hundred(_get_color_column_points(_get_highest_entered_number_index(green_column)), "Green")
    points["green_count"] = _get_highest_entered_number_index(green_column)
    points["blue"] = _check_for_neg_hundred(_get_color_column_points(_get_highest_entered_number_index(blue_column)), "Blue")
    points["blue_count"] = _get_highest_entered_number_index(blue_column)
    points["purple"] = _check_for_neg_hundred(_get_color_column_points(_get_highest_entered_number_index(purple_column)), "Purple")
    points["purple_count"] = _get_highest_entered_number_index(purple_column)
    points["vase"] = _get_vase_dice_column_points(_get_highest_scribbled_index(vase_column))
    points["vase_count"] = _get_highest_scribbled_index(vase_column)
    points["dice"] = _check_for_zero_dice(_get_vase_dice_column_points(_get_highest_scribbled_index(dice_column)))
    points["dice_count"] = _get_highest_scribbled_index(dice_column)
    points["bridges"] = _get_bridge_points(bridges)


    var total_points: int = 0
    for key in points.keys():
        if !key.match("*_count"):
            total_points += points[key]

    points["total"] = total_points
    return points
