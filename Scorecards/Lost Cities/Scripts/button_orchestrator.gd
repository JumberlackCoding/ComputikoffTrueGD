extends Control

@onready var lost_cities = get_parent()
@onready var tween_orch = get_parent().get_node( "TweenOrchestrator" )
@onready var number_selector = get_parent().get_node( "NumberSelectorLayer" ).get_node( "LostCitiesNumberSelector" )
@onready var confirmation_box = get_parent().get_node( "ConfirmBoxLayer" ).get_node( "ConfirmationBox" )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    %LostCitiesCalculateButton.pressed.connect( _calculate )
    %LostCitiesClearButton.pressed.connect( _clear )
    _connect_all_color_buttons()

func _connect_all_color_buttons() -> void:
    for button in get_tree().get_nodes_in_group( "LostCitiesNumberButton" ):
        button = button as Button
        var vase = false
        var arrow = false

        if button.is_in_group( "LostCitiesVaseInButton" ):
            vase = true
        if button.is_in_group( "LostCitiesArrowInButton" ):
            arrow = true

        if button:
            button.pressed.connect( _show_number_selector.bind( button, vase, arrow ) )

func _show_number_selector( colored_button_pressed: Control, contains_vase: bool = false, contains_arrow: bool = false ) -> void:
    var above_number: int = lost_cities.get_number( lost_cities.get_next_button( colored_button_pressed ) )
    var below_number: int = lost_cities.get_number( lost_cities.get_prev_button( colored_button_pressed ) )

    if colored_button_pressed.name == "Button9" or below_number > 0:
        number_selector.prepare_number_selector( colored_button_pressed, below_number, above_number, contains_vase, contains_arrow )
        tween_orch.animate_show_lc_num_selector( number_selector, colored_button_pressed )
    else:
        tween_orch.animate_shake_num_button( colored_button_pressed )

func _calculate() -> void:
    tween_orch.animate_calculate( lost_cities.calculate() )

func _clear() -> void:
    confirmation_box.set_confirmation_box_confirm_action( tween_orch.animate_lost_cities_clear )
    confirmation_box.set_confirmation_box_confirm_action( tween_orch.close_lc_confirmbox, false )
    show_confirmation_box()

func show_confirmation_box() -> void:
    tween_orch.open_lc_confirmbox()
