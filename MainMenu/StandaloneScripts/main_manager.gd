class_name MainMenuManager
extends MarginContainer

@export_category("Main Menu Tween Properties")
@export_group("Main Menu Category Buttons", "cat_buts_")
# @export var cat_buts_main_category_container: Control
@export var cat_buts_transition_higher_out_props: TweenParams
@export var cat_buts_transition_deeper_in_props: TweenParams
@export var cat_buts_transition_higher_in_props: TweenParams
@export var cat_buts_transition_deeper_out_props: TweenParams

@export_group("Main Menu Scorecards List Container")
@export var main_scorecard_list_container: Control

@export_group("Top Instance Container")
@export var top_instance_container: Control

@export_category("Shared UI Tween Properties")
@export_group("Switch Instance Properties", "scorecard_switch_instance_")
@export var scorecard_switch_instance_in_properties: TweenParams  ## Properties for tweening new scorecard instance in[br]Likely just phasing
@export var scorecard_switch_instance_out_properties: TweenParams  ## Properties for tweening new scorecard instance out[br]Likely just phasing
## Properties for tweening the background color between the current instance and the one coming in.
## Color [code]start[/code] and [code]end[/code] are handled programmatically. [code]start[/code] is taken from the current background color.
## [code]end[/code] is taken from the [code]scorecard_data.background_color[/code] for the new instance
@export var scorecard_switch_instance_background_properties: TweenParams

@export_category("Lost Cities Tween Properties")
@export_group("Invalid Button Selection", "lc_shake_")
@export var lc_shake_repetitions: int
@export var lc_shake_tween_parameters: TweenParams

@export_group("Colored Button To Number Selection Transition")
@export_subgroup("Transition to open number selector", "lc_col_to_num_sel_")
@export var lc_col_to_num_sel_num_selector_properties: TweenParams
## Colored Button [code]slide_end[/code], [code]slide_by_ratio[/code], and [code]scale_end[/code] are programatically overwritten
@export var lc_col_to_num_sel_color_button_properties: TweenParams
@export_subgroup("Transition to close number selector", "lc_num_sel_to_col_")
@export var lc_num_sel_to_col_num_selector_properties: TweenParams
## Colored Button [code]slide_start[/code], [code]slide_by_ratio[/code], and [code]scale_scale[/code] are programatically overwritten
@export var lc_num_sel_to_col_color_button_properties: TweenParams

@export_group("Arrow and Vase Animation Properties", "lc_")
@export var lc_arrow_animation_properties: TweenParams
@export var lc_vase_animation_properties: TweenParams

@export_group("Calculate Animation Properties", "lc_calc_")
@export var lc_calc_text_animation_duration: float
@export var lc_calc_minimum_delay_between_columns: float
@export var lc_calc_column_climb_delay: float
@export var lc_calc_final_score_shadow_color: Color
@export var lc_calc_final_score_shadow_final_size: int
@export var lc_calc_final_score_shadow_duration: float
@export var lc_calc_column_properties: TweenParams
@export var lc_calc_final_score_properties: TweenParams

@export_group("Clear Animation Properties", "lc_clear_")
@export var lc_clear_top_level_props_begin: TweenParams
@export var lc_clear_top_level_props_finish: TweenParams
@export var lc_clear_individual_clearable_props_1: TweenParams
@export var lc_clear_individual_clearable_props_2: TweenParams
@export var lc_clear_individual_clearable_props_3: TweenParams
@export var lc_clear_individual_clearable_props_4: TweenParams
@export var lc_clear_individual_clearable_props_5: TweenParams

@export_group("Confirmation Box Properties", "lc_confirmbox_")
@export var lc_confirmbox_confirmation_box: Control
@export var lc_confirmbox_open_properties: TweenParams
@export var lc_confirmbox_close_properties: TweenParams

@export_category("Other Properties")
@export_group("Shared Nodes")
@export var main_menu_container: Control
@export var background_color_rect: ColorRect
@export var main_menu_button: BaseButton
@export var input_blocker: Button
@export var instance_switch_ddl: Control

enum Scorecard { FLIP7, LOST_CITIES, YAHTZEE }
@export var scorecard_data: Dictionary[Scorecard, Control] = { Scorecard.FLIP7: null, Scorecard.LOST_CITIES: null, Scorecard.YAHTZEE: null }

@export_group("Navigation")
# Navigation setup
enum Page { MAIN, GAME_SELECT, SCORECARD_SELECT, GAME_SCORECARD_INSTANCE, MAIN_MENU_INSTANCE }
@export var pages: Dictionary[Page, Control] = { Page.MAIN: null, Page.GAME_SCORECARD_INSTANCE: null }
var current_page: Page = Page.MAIN
var page_history: Array[Page] = []

@export_group("Main Menu Settings", "main_menu_")
@export var main_menu_background_color: Color = Color( "c1e0fc" )

# Setup all the node references
@onready var games_grid_back_button: BaseButton
@onready var scorecards_flip7_button: BaseButton = main_scorecard_list_container.get_node(
        "ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/Flip7Container/Flip7Button" )
@onready var scorecards_lost_cities_button: BaseButton = main_scorecard_list_container.get_node(
        "ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/LostCitiesContainer/LostCitiesButton" )
@onready var scorecards_yahtzee_button: BaseButton = main_scorecard_list_container.get_node(
        "ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/YahtzeeContainer/YahtzeeButton" )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    TweenController.set_base_z()

    # Make event connections
    scorecards_flip7_button.pressed.connect( _on_flip7_grid_button_pressed )
    scorecards_lost_cities_button.pressed.connect( _on_lost_cities_grid_button_pressed )
    scorecards_yahtzee_button.pressed.connect( _on_yahtzee_grid_button_pressed )

    # In instance buttons
    main_menu_button.pressed.connect( _on_in_instance_main_menu_button_pressed )

    call_deferred( "_hide_top_instance" )

func _hide_top_instance() -> void:
    top_instance_container.visible = false

func _nav_deeper_to( page: Page ) -> void:
    page_history.append( current_page )
    _animate_deeper( current_page, page )
    current_page = page

func _nav_back() -> void:
    if (page_history.is_empty()):
        return

    var previous_page = page_history.pop_back()
    if current_page == Page.GAME_SCORECARD_INSTANCE:
        _prep_main_menu()
    _animate_higher( current_page, previous_page )
    current_page = previous_page

func _prep_main_menu() -> void:
    pages[Page.MAIN].visible = true

    var color_params := scorecard_switch_instance_background_properties.duplicate( true )
    color_params.target_node = background_color_rect
    color_params.color.start = background_color_rect.color
    color_params.color.end = main_menu_background_color
    await TweenController.universal_tween( color_params ).finished
    try_unlock_ui()

func _nav_to_main_menu() -> void:
    _prep_main_menu()
    _animate_higher( current_page, Page.MAIN )
    page_history.clear()
    page_history.append( Page.MAIN )
    current_page = Page.MAIN

# This function handles only the transition between main containers. An instance's specific controls will
# be tweened in the prepare function
func _animate_deeper( current: Page, next: Page ) -> void:
    lock_ui()

    var current_container = pages[current]
    var next_container = pages[next]
    cat_buts_transition_higher_out_props.target_node = current_container
    cat_buts_transition_deeper_in_props.target_node = next_container
    TweenController.universal_tween( cat_buts_transition_higher_out_props )

    var tweens := []
    tweens.append( TweenController.universal_tween( cat_buts_transition_deeper_in_props ) )
    await TweenController.wait_for_all( tweens )
    try_unlock_ui()

func _animate_higher( current: Page, previous_page: Page ) -> void:
    lock_ui()
    var current_container = pages[current]
    var previous_container = pages[previous_page]
    cat_buts_transition_higher_in_props.target_node = previous_container
    cat_buts_transition_deeper_out_props.target_node = current_container
    var tweens := []
    tweens.append( TweenController.universal_tween( cat_buts_transition_higher_in_props ) )
    tweens.append( TweenController.universal_tween( cat_buts_transition_deeper_out_props ) )
    await TweenController.wait_for_all( tweens )
    try_unlock_ui()

func _on_flip7_grid_button_pressed() -> void:
    _prep_scorecard_instance( Scorecard.FLIP7 )
    # This steps down in the UI
    _nav_deeper_to( Page.GAME_SCORECARD_INSTANCE )

func _on_lost_cities_grid_button_pressed() -> void:
    _prep_scorecard_instance( Scorecard.LOST_CITIES )
    # This steps down in the UI
    _nav_deeper_to( Page.GAME_SCORECARD_INSTANCE )

func _on_yahtzee_grid_button_pressed() -> void:
    _prep_scorecard_instance( Scorecard.YAHTZEE )
    # This steps down in the UI
    _nav_deeper_to( Page.GAME_SCORECARD_INSTANCE )

func _on_in_instance_main_menu_button_pressed() -> void:
    # This logically steps up in the UI
    _nav_to_main_menu()

func _on_phase_in_finished( target_node: Control ) -> void:
    try_unlock_ui()

    if target_node.is_in_group( "ScorecardContainerInstance" ):
        for con: Control in get_tree().get_nodes_in_group( "ScorecardContainerInstance" ):
            con.visible = false

        target_node.visible = true

func _ui_is_locked() -> bool:
    return input_blocker.visible

func lock_ui() -> void:
    input_blocker.visible = true

func try_unlock_ui( attempts: int = 0 ) -> void:
    if TweenController.all_tweens_finished() and _ui_is_locked():
        input_blocker.visible = false
        _reset_input_blocker()
        if attempts > 0:
            print( "UI unlocked on attempt: ", attempts + 1, " (attempts = ", attempts, ")" )
    elif _ui_is_locked():
        await get_tree().create_timer( 0.3 ).timeout
        if attempts > 0:
            print( "Tweens not finished, UI still locked. Attempt: ", attempts )
        try_unlock_ui( attempts + 1 )

func _reset_input_blocker() -> void:
    for con in input_blocker.pressed.get_connections():
        input_blocker.pressed.disconnect( con.callable )
    input_blocker.pressed.connect( _reset_input_blocker )

func _scorecard_hide_everything() -> void:
    for con: Control in get_tree().get_nodes_in_group( "ScorecardContainerInstance" ):
        con.visible = false

    for con: Control in get_tree().get_nodes_in_group( "ScorecardLogos" ):
        con.visible = false

func _prep_scorecard_instance( scorecard: Scorecard ) -> void:
    _scorecard_hide_everything()
    var data = scorecard_data[scorecard]
    data.get_instance().visible = true
    data.get_logo().visible = true

    # Background Color
    var color_params := scorecard_switch_instance_background_properties.duplicate( true )
    color_params.target_node = background_color_rect
    color_params.color.start = background_color_rect.color
    color_params.color.end = data.background_color
    await TweenController.universal_tween( color_params ).finished
    try_unlock_ui()

func on_switch_scorecard_instance( target_scorecard: Scorecard ) -> void:
    lock_ui()

    instance_switch_ddl.manually_toggle_button_off()

    # find the current active instance and phase it out and phase in the new one
    var current_instance: Control
    for con: Control in get_tree().get_nodes_in_group( "ScorecardContainerInstance" ):
        if con.visible:
            current_instance = con
            break

    var current_logo: Control
    for sco in scorecard_data.values():
        if sco.get_logo().visible:
            current_logo = sco.get_logo()
            break

    var target_logo: Control = scorecard_data[target_scorecard].get_logo()

    var new_color = Color.BLACK
    new_color = scorecard_data[target_scorecard].background_color

    if current_instance and new_color and current_logo and target_logo:
        var tweens = []

        # Background Color
        var color_params := scorecard_switch_instance_background_properties.duplicate( true )
        color_params.target_node = background_color_rect
        color_params.color.start = background_color_rect.color
        color_params.color.end = new_color
        tweens.append( TweenController.universal_tween( color_params ) )

        # Top Scorecard Instance
        var in_params1 = scorecard_switch_instance_in_properties.duplicate( true )
        var out_params1 = scorecard_switch_instance_out_properties.duplicate( true )
        in_params1.target_node = scorecard_data[target_scorecard].get_instance()
        out_params1.target_node = current_instance
        tweens.append( TweenController.universal_tween( in_params1 ) )
        tweens.append( TweenController.universal_tween( out_params1 ) )

        # Logo
        var in_params2 = scorecard_switch_instance_in_properties.duplicate( true )
        var out_params2 = scorecard_switch_instance_out_properties.duplicate( true )
        in_params2.target_node = target_logo
        out_params2.target_node = current_logo
        tweens.append( TweenController.universal_tween( in_params2 ) )
        tweens.append( TweenController.universal_tween( out_params2 ) )
        await TweenController.wait_for_all( tweens )

    try_unlock_ui()

## This function does not make the input blocker visible because it is very likely it has already been made visible by using
## [method MainMenuManager.lock_ui]. If the UI has already been locked, then it will block any input and once this method is
## called, it will then set what clicking the input blocker will do at that point. If it is not already blocked, then do so
## by calling [method MainMenuManager.lock_ui]. If [param override] is [code]true[/code] will invoke [method MainMenuManager._reset_input_blocker]
## which disconnects any previous connections, reconnects itself, and then it will connect the supplied [param connection].
func set_input_blocker_connection( connection: Callable, override: bool = true ) -> void:
    if override:
        _reset_input_blocker()

    input_blocker.pressed.connect( connection )
