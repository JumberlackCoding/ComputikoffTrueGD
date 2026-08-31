class_name LostCities
extends MarginContainer

@export var vase_texture: Texture2D
@export var arrow_texture: Texture2D
@export var vase_arrow_alpha: float
@export_color_no_alpha var colors: Array[Color] = [Color( "ff8787" ), Color( "e1a06f" ), Color( "ded410" ), Color( "52c840" ), Color( "27b9f0" ), Color( "b195fe" ),
    Color( "fabd83" )]
enum color { RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, VASE_DICE_BRIDGE }
@export var confirmation_box: Control

@onready var main_manager: MarginContainer = get_tree().current_scene
@onready var tween_orchestrator = $TweenOrchestrator

const COLOR_COLUMN_POINTS = [-20, -15, -10, 5, 10, 15, 30, 35, 50, 0]
const VASE_DICE_COLUMN_POINTS = [-40, -30, -20, 10, 20, 30, 60, 70, 100, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _color_the_buttons()
    _setup_arrows_and_vases()

func _color_the_buttons() -> void:
    for con in get_tree().get_nodes_in_group( "LostCitiesColorRed" ):
        con = con as Control
        if con:
            con.self_modulate = colors[color.RED]
    for con in get_tree().get_nodes_in_group( "LostCitiesColorOrange" ):
        con = con as Control
        if con:
            con.self_modulate = colors[color.ORANGE]
    for con in get_tree().get_nodes_in_group( "LostCitiesColorYellow" ):
        con = con as Control
        if con:
            con.self_modulate = colors[color.YELLOW]
    for con in get_tree().get_nodes_in_group( "LostCitiesColorGreen" ):
        con = con as Control
        if con:
            con.self_modulate = colors[color.GREEN]
    for con in get_tree().get_nodes_in_group( "LostCitiesColorBlue" ):
        con = con as Control
        if con:
            con.self_modulate = colors[color.BLUE]
    for con in get_tree().get_nodes_in_group( "LostCitiesColorPurple" ):
        con = con as Control
        if con:
            con.self_modulate = colors[color.PURPLE]
    for con in get_tree().get_nodes_in_group( "LostCitiesColorVaseBridgeDice" ):
        con = con as Control
        if con:
            con.self_modulate = colors[color.VASE_DICE_BRIDGE]


func _attach_vase( b: Button ) -> void:
    var vase: TextureRect = TextureRect.new()
    vase.name = "Vase"
    vase.texture = vase_texture
    vase.set_anchor( SIDE_LEFT, 0.3 )
    vase.set_anchor( SIDE_RIGHT, 0.7 )
    vase.set_anchor( SIDE_TOP, 0.2 )
    vase.set_anchor( SIDE_BOTTOM, 0.8 )
    vase.self_modulate.a = vase_arrow_alpha
    b.add_child( vase )
    b.get_child( 1 ).move_to_front()

func _attach_arrow( b: Button ) -> void:
    var arrow: TextureRect = TextureRect.new()
    arrow.name = "Arrow"
    arrow.texture = arrow_texture
    arrow.set_anchor( SIDE_LEFT, 0.3 )
    arrow.set_anchor( SIDE_RIGHT, 0.7 )
    arrow.set_anchor( SIDE_TOP, 0.2 )
    arrow.set_anchor( SIDE_BOTTOM, 0.8 )
    arrow.self_modulate.a = vase_arrow_alpha
    b.add_child( arrow )
    b.get_child( 1 ).move_to_front()

func _setup_arrows_and_vases() -> void:
    for button in get_tree().get_nodes_in_group( "LostCitiesVaseInButton" ):
        button = button as Button
        _attach_vase( button )

    for button in get_tree().get_nodes_in_group( "LostCitiesArrowInButton" ):
        button = button as Button
        _attach_arrow( button )

func get_number( button: Button ) -> int:
    return button.get_node( "Label" ).text.to_int() if button else -1

func _get_highest_entered_number_index( column: Array[Node] ) -> int:
    var highest_index: int = -1

    for i in range( column.size() ):
        var button: Button = column[i] as Button

        if get_number( button ) > 0:
            highest_index = i
        else:
            break

    return highest_index

func _get_highest_scribbled_index( column: Array[Node] ) -> int:
    var highest_index: int = -1

    for i in range( column.size() ):
        var button: Button = column[i] as Button

        if button:
            if button.is_scribbled():
                highest_index = i
            else:
                break

    return highest_index

func _get_bridge_points( bridges: Array[Node] ) -> int:
    var points := 0

    for bridge in bridges:
        if bridge.is_circled():
            points += 20

    return points

func _get_color_column_points( index: int ) -> int:
    return COLOR_COLUMN_POINTS[index]

func _get_vase_dice_column_points( index: int ) -> int:
    return VASE_DICE_COLUMN_POINTS[index]

func _check_for_neg_hundred( points: int, col: String ) -> int:
    var actual_points: int = points

    if get_node( "%" + col + "Symbol" ).is_xed():
        if points == 0:
            actual_points = -100
        else:
            actual_points *= 2

    return actual_points

func _check_for_zero_dice( points: int ) -> int:
    if points == 100:
        points = 0

    return points

func calculate() -> Dictionary[String, Variant]:
    var data := { }

    var red_column := get_tree().get_nodes_in_group( "LostCitiesColumnRed" )
    var orange_column := get_tree().get_nodes_in_group( "LostCitiesColumnOrange" )
    var yellow_column := get_tree().get_nodes_in_group( "LostCitiesColumnYellow" )
    var green_column := get_tree().get_nodes_in_group( "LostCitiesColumnGreen" )
    var blue_column := get_tree().get_nodes_in_group( "LostCitiesColumnBlue" )
    var purple_column := get_tree().get_nodes_in_group( "LostCitiesColumnPurple" )
    var vase_column := get_tree().get_nodes_in_group( "LostCitiesColumnVase" )
    var dice_column := get_tree().get_nodes_in_group( "LostCitiesColumnDice" )
    var bridges := get_tree().get_nodes_in_group( "LostCitiesBridges" )

    red_column.reverse()
    orange_column.reverse()
    yellow_column.reverse()
    green_column.reverse()
    blue_column.reverse()
    purple_column.reverse()
    vase_column.reverse()
    dice_column.reverse()

    data["red_points"] = _check_for_neg_hundred( _get_color_column_points( _get_highest_entered_number_index( red_column ) ), "Red" )
    data["red_highest_index"] = _get_highest_entered_number_index( red_column )
    data["red_column"] = red_column
    data["orange_points"] = _check_for_neg_hundred( _get_color_column_points( _get_highest_entered_number_index( orange_column ) ), "Orange" )
    data["orange_highest_index"] = _get_highest_entered_number_index( orange_column )
    data["orange_column"] = orange_column
    data["yellow_points"] = _check_for_neg_hundred( _get_color_column_points( _get_highest_entered_number_index( yellow_column ) ), "Yellow" )
    data["yellow_highest_index"] = _get_highest_entered_number_index( yellow_column )
    data["yellow_column"] = yellow_column
    data["green_points"] = _check_for_neg_hundred( _get_color_column_points( _get_highest_entered_number_index( green_column ) ), "Green" )
    data["green_highest_index"] = _get_highest_entered_number_index( green_column )
    data["green_column"] = green_column
    data["blue_points"] = _check_for_neg_hundred( _get_color_column_points( _get_highest_entered_number_index( blue_column ) ), "Blue" )
    data["blue_highest_index"] = _get_highest_entered_number_index( blue_column )
    data["blue_column"] = blue_column
    data["purple_points"] = _check_for_neg_hundred( _get_color_column_points( _get_highest_entered_number_index( purple_column ) ), "Purple" )
    data["purple_highest_index"] = _get_highest_entered_number_index( purple_column )
    data["purple_column"] = purple_column
    data["vase_points"] = _get_vase_dice_column_points( _get_highest_scribbled_index( vase_column ) )
    data["vase_highest_index"] = _get_highest_scribbled_index( vase_column )
    data["vase_column"] = vase_column
    data["dice_points"] = _check_for_zero_dice( _get_vase_dice_column_points( _get_highest_scribbled_index( dice_column ) ) )
    data["dice_highest_index"] = _get_highest_scribbled_index( dice_column )
    data["dice_column"] = dice_column
    data["bridges_points"] = _get_bridge_points( bridges )
    data["bridges_column"] = bridges

    var total_points: int = 0
    for key in data.keys():
        if key.match( "*_points" ):
            total_points += data[key]

    data["total_points"] = total_points

    return data

func get_color_column( colored_button: Button ) -> StringName:
    var groups = colored_button.get_groups()
    var columns := groups.filter( func( g ):
        return "Column" in g )
    var column: StringName = "" if columns.is_empty() else columns[0]
    return column

func get_next_button( colored_button: Button ) -> Button:
    var groups = colored_button.get_groups()
    var column := groups.filter( func( g ):
        return "Column" in g )
    # print(colored_button_pressed.name, '\n', groups, '\n', column)

    var next_button := "Button" + str( colored_button.name.substr( "Button".length() ).to_int() - 1 )
    var next_button_inst: Button
    for but in get_tree().get_nodes_in_group( column[0] ):
        if but.name == next_button:
            next_button_inst = but
            break
    return next_button_inst

func get_prev_button( colored_button: Button ) -> Button:
    var groups = colored_button.get_groups()
    var column := groups.filter( func( g ):
        return "Column" in g )
    # print(colored_button_pressed.name, '\n', groups, '\n', column)

    var next_button := "Button" + str( colored_button.name.substr( "Button".length() ).to_int() + 1 )
    var next_button_inst: Button
    for but in get_tree().get_nodes_in_group( column[0] ):
        if but.name == next_button:
            next_button_inst = but
            break
    return next_button_inst

func get_next_vase() -> Button:
    var column := get_tree().get_nodes_in_group( "LostCitiesColumnVase" )
    column.reverse()

    var but: Button = null
    for vase in column:
        if vase.is_scribbled():
            continue
        else:
            but = vase
            break
    return but

func get_cur_vase() -> Button:
    var column := get_tree().get_nodes_in_group( "LostCitiesColumnVase" )

    var but: Button = null
    for vase in column:
        if not vase.is_scribbled():
            continue
        else:
            but = vase
            break
    return but
