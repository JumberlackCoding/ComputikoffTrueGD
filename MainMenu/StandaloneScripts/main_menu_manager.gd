extends MarginContainer

@export var tween_controller: Control

@export_category("Main Menu Tween Properties")
@export_group("Main Menu Category Buttons", "cat_buts_")
@export var cat_buts_main_category_container: Control
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
@export var scorecard_switch_instance_in_properties: TweenParams ## Properties for tweening new scorecard instance in[br]Likely just phasing
@export var scorecard_switch_instance_out_properties: TweenParams ## Properties for tweening new scorecard instance out[br]Likely just phasing
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

@export_group("Calculate Animation Properties", "lc_calc_")
@export var lc_calc_text_animation_duration: float
@export var lc_calc_minimum_delay_between_columns: float
@export var lc_calc_column_climb_delay: float
@export var lc_calc_final_score_shadow_color: Color
@export var lc_calc_final_score_shadow_final_size: int
@export var lc_calc_final_score_shadow_duration: float
@export var lc_calc_column_properties: TweenParams
@export var lc_calc_final_score_properties: TweenParams

@export_category("Other Properties")
@export_group("Shared Nodes")
@export var main_menu_container: Control
@export var background_color_rect: ColorRect
@export var main_menu_button: BaseButton
@export var inputBlocker: Control
@export var instance_switch_ddl: Control

enum Scorecard {FLIP7, LOST_CITIES, YAHTZEE}
@export var scorecard_data: Dictionary[Scorecard, Control] = {Scorecard.FLIP7: null, Scorecard.LOST_CITIES: null, Scorecard.YAHTZEE: null}

@export_group("Navigation")
# Navigation setup
enum Page {MAIN, GAME_SELECT, SCORECARD_SELECT, GAME_SCORECARD_INSTANCE, MAIN_MENU_INSTANCE}
@export var pages: Dictionary[Page, Control] = {Page.MAIN: null, Page.GAME_SELECT: null, Page.SCORECARD_SELECT: null, Page.GAME_SCORECARD_INSTANCE: null, Page.MAIN_MENU_INSTANCE: null}
var current_page: Page = Page.MAIN
var page_history: Array[Page] = []

@export_group("Main Menu Settings", "main_menu_")
@export var main_menu_background_color: Color = Color("c1e0fc")

# Setup all the node references
@onready var games_button: BaseButton = cat_buts_main_category_container.get_node("HBoxContainer/MarginContainer/GamesButton")
#TODO when implementing games
@onready var games_grid_back_button: BaseButton
@onready var scorecards_button: BaseButton = cat_buts_main_category_container.get_node("HBoxContainer/MarginContainer2/ScorecardsButton")
@onready var scorecards_grid_back_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/BackButton")
@onready var scorecards_flip7_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/Flip7Container/Flip7Button")
@onready var scorecards_lost_cities_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/LostCitiesContainer/LostCitiesButton")
@onready var scorecards_yahtzee_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/YahtzeeContainer/YahtzeeButton")

# Lost Cities node references
@onready var lost_cities_calculate_button: BaseButton = %LostCitiesCalculateButton
@onready var lost_cities_clear_button: BaseButton = %LostCitiesClearButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Make event connections
    # Main menu category buttons
    games_button.pressed.connect(_on_scorecard_button_pressed)
    scorecards_button.pressed.connect(_on_scorecard_button_pressed)

    # Main menu scorecard grid buttons
    scorecards_grid_back_button.pressed.connect(_on_scorecard_grid_back_button_pressed)
    scorecards_flip7_button.pressed.connect(_on_flip7_grid_button_pressed)
    scorecards_lost_cities_button.pressed.connect(_on_lost_cities_grid_button_pressed)
    scorecards_yahtzee_button.pressed.connect(_on_yahtzee_grid_button_pressed)

    # In instance buttons
    main_menu_button.pressed.connect(_on_in_instance_main_menu_button_pressed)

    # Lost Cities
    lost_cities_calculate_button.pressed.connect(_on_lost_cities_calculate_pressed)
    lost_cities_clear_button.pressed.connect(_on_lost_cities_clear_pressed)

func _nav_deeper_to(page: Page) -> void:
    page_history.append(current_page)
    _animate_deeper(current_page, page)
    current_page = page

func _nav_back() -> void:
    if (page_history.is_empty()):
        return

    var previous_page = page_history.pop_back()
    if current_page == Page.GAME_SCORECARD_INSTANCE:
        previous_page = Page.MAIN_MENU_INSTANCE
        _prep_main_menu()
    _animate_higher(current_page, previous_page)
    current_page = previous_page

func _prep_main_menu() -> void:
    pages[Page.MAIN].visible = true
    pages[Page.GAME_SELECT].visible = false
    pages[Page.SCORECARD_SELECT].visible = false
    background_color_rect.color = main_menu_background_color

func _nav_to_main_menu() -> void:
    _prep_main_menu()
    _animate_higher(current_page, Page.MAIN_MENU_INSTANCE)
    page_history.clear()
    page_history.append(Page.MAIN)
    current_page = Page.MAIN

# This function handles only the transition between main containers. An instance's specific controls will
# be tweened in the prepare function
func _animate_deeper(current: Page, next: Page) -> void:
    _lock_ui()

    if next == Page.GAME_SCORECARD_INSTANCE:
        current = Page.MAIN_MENU_INSTANCE

    var current_container = pages[current]
    var next_container = pages[next]
    cat_buts_transition_higher_out_props.target_node = current_container
    cat_buts_transition_deeper_in_props.target_node = next_container
    tween_controller.universal_tween(cat_buts_transition_higher_out_props)

    var tweens := []
    tweens.append(tween_controller.universal_tween(cat_buts_transition_deeper_in_props))
    await tween_controller.wait_for_all(tweens)
    _try_unlock_ui()

func _animate_higher(current: Page, previous_page: Page) -> void:
    _lock_ui()
    var current_container = pages[current]
    var previous_container = pages[previous_page]
    cat_buts_transition_higher_in_props.target_node = previous_container
    cat_buts_transition_deeper_out_props.target_node = current_container
    var tweens := []
    tweens.append(tween_controller.universal_tween(cat_buts_transition_higher_in_props))
    tweens.append(tween_controller.universal_tween(cat_buts_transition_deeper_out_props))
    await tween_controller.wait_for_all(tweens)
    _try_unlock_ui()

func _on_scorecard_button_pressed() -> void:
    # This logically steps down in the UI
    _nav_deeper_to(Page.SCORECARD_SELECT)

func _on_scorecard_grid_back_button_pressed() -> void:
    # This logically steps up in the UI
    _nav_back()

func _on_flip7_grid_button_pressed() -> void:
    _prep_scorecard_instance(Scorecard.FLIP7)
    # This steps down in the UI
    _nav_deeper_to(Page.GAME_SCORECARD_INSTANCE)

func _on_lost_cities_grid_button_pressed() -> void:
    _prep_scorecard_instance(Scorecard.LOST_CITIES)
    # This steps down in the UI
    _nav_deeper_to(Page.GAME_SCORECARD_INSTANCE)

func _on_yahtzee_grid_button_pressed() -> void:
    _prep_scorecard_instance(Scorecard.YAHTZEE)
    # This steps down in the UI
    _nav_deeper_to(Page.GAME_SCORECARD_INSTANCE)

func _on_in_instance_main_menu_button_pressed() -> void:
    # This logically steps up in the UI
    _nav_to_main_menu()

func _on_phase_in_finished(target_node: Control) -> void:
    _try_unlock_ui()

    if target_node.is_in_group("ScorecardContainerInstance"):
        for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            con.visible = false

        target_node.visible = true

func _animate_button(params: TweenParams) -> Array:
    var tweens := []
    tweens.append(tween_controller.universal_tween(params, true, false))
    tweens.append(tween_controller.universal_tween(_generate_tweenparams_reset(params), false, true))
    return tweens

func _animate_column(col: Array, count: int) -> void:
    var zs := []
    var tweens := []
    for i in count:
        var params := lc_calc_column_properties.duplicate(true)
        params.target_node = col[i]
        zs.append(params.target_node.z_index)
        params.target_node.z_index += 7
        tweens.append_array(_animate_button(params))
        await get_tree().create_timer(lc_calc_column_climb_delay).timeout

    await tween_controller.wait_for_all(tweens)
    for j in count:
        col[j].z_index = zs[j]

func _animate_bridges(bridges: Array) -> void:
    var zs := []
    var tweens := []
    for i in bridges.size():
        var params := lc_calc_column_properties.duplicate(true)
        params.target_node = bridges[i]
        zs.append(params.target_node.z_index)
        params.target_node.z_index += 7
        tweens.append_array(_animate_button(params))
        await get_tree().create_timer(lc_calc_column_climb_delay).timeout

    await tween_controller.wait_for_all(tweens)
    for j in bridges.size():
        bridges[j].z_index = zs[j]

func _on_lost_cities_calculate_pressed() -> void:
    _lock_ui()
    var points: Dictionary = scorecard_data[Scorecard.LOST_CITIES].get_instance().calculate()

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

    await _animate_column(red_column, points["red_count"] + 1)
    tween_controller.tween_text(%LcRedScore, str(points["red"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_column(orange_column, points["orange_count"] + 1)
    tween_controller.tween_text(%LcOrangeScore, str(points["orange"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_column(yellow_column, points["yellow_count"] + 1)
    tween_controller.tween_text(%LcYellowScore, str(points["yellow"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_column(green_column, points["green_count"] + 1)
    tween_controller.tween_text(%LcGreenScore, str(points["green"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_column(blue_column, points["blue_count"] + 1)
    tween_controller.tween_text(%LcBlueScore, str(points["blue"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_column(purple_column, points["purple_count"] + 1)
    tween_controller.tween_text(%LcPurpleScore, str(points["purple"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_column(vase_column, points["vase_count"] + 1)
    tween_controller.tween_text(%LcVaseScore, str(points["vase"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_column(dice_column, points["dice_count"] + 1)
    tween_controller.tween_text(%LcDiceScore, str(points["dice"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(lc_calc_minimum_delay_between_columns).timeout
    await _animate_bridges(bridges)
    tween_controller.tween_text(%LcBridgeScore, str(points["bridges"]), lc_calc_text_animation_duration)
    await get_tree().create_timer(1.25).timeout

    var fscore = %LcFinalScore as Label
    lc_calc_final_score_properties.target_node = fscore
    var screen_center := position + size / 2
    var final_size := lc_calc_final_score_properties.target_node.global_position + (lc_calc_final_score_properties.target_node.size / 2) # * lc_calc_final_score_properties.scale.end)
    lc_calc_final_score_properties.slide.end = screen_center - final_size

    tween_controller.tween_override_stylebox_shadow(fscore, lc_calc_final_score_shadow_color, lc_calc_final_score_shadow_final_size, lc_calc_final_score_shadow_duration)
    await tween_controller.wait_for_all(tween_controller.universal_tween(lc_calc_final_score_properties, true, false))
    tween_controller.tween_text(fscore, str(points["total"]), lc_calc_text_animation_duration * 3, "999")

    _try_unlock_ui()
    # print(points)

func _on_lost_cities_clear_pressed() -> void:
    print("clear")
    pass

func _ui_is_locked() -> bool:
    return inputBlocker.visible

func _lock_ui() -> void:
    inputBlocker.visible = true

func _try_unlock_ui() -> void:
    var max_attempts = 2
    for attempt in max_attempts:
        if tween_controller.all_tweens_finished() and _ui_is_locked():
            inputBlocker.visible = false
            if attempt > 1:
                print("_try_unlock_ui() succeeded")
            break
        elif _ui_is_locked():
            if attempt < max_attempts:
                await get_tree().create_timer(0.1).timeout
                print("_try_unlock_ui() failed")
            # await get_tree().process_frame

func _scorecard_hide_everything() -> void:
    for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
        con.visible = false

    for con: Control in get_tree().get_nodes_in_group("ScorecardLogos"):
        con.visible = false

func _prep_scorecard_instance(scorecard: Scorecard) -> void:
    _scorecard_hide_everything()
    var data = scorecard_data[scorecard]
    data.get_instance().visible = true
    data.get_logo().visible = true
    background_color_rect.color = data.background_color

func _generate_tweenparams_reset(params: TweenParams) -> TweenParams:
    var new_params = TweenParams.new()

    new_params.target_node = params.target_node
    new_params.pivot = params.pivot
    new_params.pivot_ratio = params.pivot_ratio
    new_params.move_z_index_to_frontish = params.move_z_index_to_frontish
    new_params.ignore_safety_check = params.ignore_safety_check
    new_params.visual_only = params.visual_only

    if params.slide:
        new_params.slide = SlideParams.new()
        new_params.slide.duration = params.slide.duration
        new_params.slide.delay = params.slide.duration # offset it so it executes right after the previous one without needing to await
        new_params.slide.start = params.slide.end
        new_params.slide.by_ratio = params.slide.by_ratio
        new_params.slide.transition_type = params.slide.transition_type
        new_params.slide.ease_type = params.slide.ease_type
    if params.rotate:
        new_params.rotate = RotateParams.new()
        new_params.rotate.duration = params.rotate.duration
        new_params.rotate.delay = params.rotate.duration # offset it so it executes right after the previous one without needing to await
        new_params.rotate.start = params.rotate.end
        new_params.rotate.transition_type = params.rotate.transition_type
        new_params.rotate.ease_type = params.rotate.ease_type
    if params.scale:
        new_params.scale = ScaleParams.new()
        new_params.scale.duration = params.scale.duration
        new_params.scale.delay = params.scale.duration # offset it so it executes right after the previous one without needing to await
        new_params.scale.start = params.scale.end
        new_params.scale.transition_type = params.scale.transition_type
        new_params.scale.ease_type = params.scale.ease_type
    if params.phase:
        new_params.phase = PhaseParams.new()
        new_params.phase.duration = params.phase.duration
        new_params.phase.delay = params.phase.duration # offset it so it executes right after the previous one without needing to await
        new_params.phase.start = params.phase.end
        new_params.phase.transition_type = params.phase.transition_type
        new_params.phase.ease_type = params.phase.ease_type
    if params.color:
        new_params.color = ColorParams.new()
        new_params.color.duration = params.color.duration
        new_params.color.delay = params.color.duration # offset it so it executes right after the previous one without needing to await
        new_params.color.start = params.color.end
        new_params.color.transition_type = params.color.transition_type
        new_params.color.ease_type = params.color.ease_type

    return new_params

func on_switch_scorecard_instance(target_scorecard: Scorecard) -> void:
    _lock_ui()

    instance_switch_ddl.manually_toggle_button_off()

    # find the current active instance and phase it out and phase in the new one
    var current_instance: Control
    for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
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
        var color_params := scorecard_switch_instance_background_properties.duplicate(true)
        color_params.target_node = background_color_rect
        color_params.color.start = background_color_rect.color
        color_params.color.end = new_color
        tweens.append(tween_controller.universal_tween(color_params))

        # Top Scorecard Instance
        var in_params1 = scorecard_switch_instance_in_properties.duplicate(true)
        var out_params1 = scorecard_switch_instance_out_properties.duplicate(true)
        in_params1.target_node = scorecard_data[target_scorecard].get_instance()
        out_params1.target_node = current_instance
        tweens.append(tween_controller.universal_tween(in_params1))
        tweens.append(tween_controller.universal_tween(out_params1))

        # Logo
        var in_params2 = scorecard_switch_instance_in_properties.duplicate(true)
        var out_params2 = scorecard_switch_instance_out_properties.duplicate(true)
        in_params2.target_node = target_logo
        out_params2.target_node = current_logo
        tweens.append(tween_controller.universal_tween(in_params2))
        tweens.append(tween_controller.universal_tween(out_params2))
        await tween_controller.wait_for_all(tweens)

        _try_unlock_ui()

func on_show_lc_num_selector(number_selector: Control, color_button: Control) -> void:
    _lock_ui()
    var num_sel_container: PanelContainer = number_selector.get_node("PanelContainer") as PanelContainer
    var num_sel_center: Vector2 = Vector2(num_sel_container.position + (num_sel_container.size / 2))
    var color_center: Vector2 = Vector2(color_button.global_position + (color_button.size / 2))
    # var pos = color_center - num_sel_center
    var pos = num_sel_center - color_center
    var size_diff = num_sel_container.size / color_button.size

    lc_col_to_num_sel_color_button_properties.target_node = color_button
    lc_col_to_num_sel_color_button_properties.slide.end = pos
    lc_col_to_num_sel_color_button_properties.slide.by_ratio = false
    lc_col_to_num_sel_color_button_properties.scale.end = size_diff

    lc_col_to_num_sel_num_selector_properties.target_node = number_selector

    var tweens := []
    tweens.append(tween_controller.universal_tween(lc_col_to_num_sel_color_button_properties))
    tweens.append(tween_controller.universal_tween(lc_col_to_num_sel_num_selector_properties))
    await tween_controller.wait_for_all(tweens)
    _try_unlock_ui()

func on_hide_lc_num_selector(number_selector: Control, color_button: Control) -> void:
    _lock_ui()
    var num_sel_container: PanelContainer = number_selector.get_node("PanelContainer") as PanelContainer
    var num_sel_center: Vector2 = Vector2(num_sel_container.global_position + (num_sel_container.size / 2))
    var color_center: Vector2 = Vector2(color_button.global_position + (color_button.size / 2))
    var start_pos = num_sel_center - color_center
    var size_diff = num_sel_container.size / color_button.size

    lc_num_sel_to_col_color_button_properties.target_node = color_button
    lc_num_sel_to_col_color_button_properties.slide.start = start_pos
    lc_num_sel_to_col_color_button_properties.slide.by_ratio = false
    lc_num_sel_to_col_color_button_properties.scale.start = size_diff

    lc_num_sel_to_col_num_selector_properties.target_node = number_selector

    var tweens := []
    tweens.append(tween_controller.universal_tween(lc_num_sel_to_col_num_selector_properties))
    tweens.append(tween_controller.universal_tween(lc_num_sel_to_col_color_button_properties))
    await tween_controller.wait_for_all(tweens)
    _try_unlock_ui()

func on_shake_num_button(target_node: Control) -> void:
    # _lock_ui()
    var shake_params := lc_shake_tween_parameters.duplicate(true)
    shake_params.target_node = target_node
    shake_params.slide.duration = shake_params.slide.duration / lc_shake_repetitions
    # Must store z_index so we can set it back to its original value since we lose it by doing multiple tweens between cleaning up
    var z = target_node.z_index
    await tween_controller.wait_for_all(tween_controller.universal_tween(shake_params))
    var shake_final_end: Vector2 = shake_params.slide.start

    for rep in (lc_shake_repetitions - 2):
        shake_params.slide.start = shake_params.slide.end
        shake_params.slide.end = - shake_params.slide.end
        await tween_controller.wait_for_all(tween_controller.universal_tween(shake_params))

    shake_params.slide.start = target_node.offset_transform_position_ratio if shake_params.slide.by_ratio else target_node.offset_transform_position
    shake_params.slide.end = shake_final_end
    await tween_controller.wait_for_all(tween_controller.universal_tween(shake_params))
    target_node.z_index = z
