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

enum Scorecard {FLIP7, LOST_CITIES, YAHTZEE}
@export var scorecard_data: Dictionary[Scorecard, Control] = {Scorecard.FLIP7: null, Scorecard.LOST_CITIES: null, Scorecard.YAHTZEE: null}

@export_group("Navigation")
# Navigation setup
enum Page {MAIN, GAME_SELECT, SCORECARD_SELECT, GAME_SCORECARD_INSTANCE, MAIN_MENU_INSTANCE}
@export var pages: Dictionary[Page, Control] = {Page.MAIN: null, Page.GAME_SCORECARD_INSTANCE: null}
var current_page: Page = Page.MAIN
var page_history: Array[Page] = []

@export_group("Main Menu Settings", "main_menu_")
@export var main_menu_background_color: Color = Color("c1e0fc")

# Setup all the node references
@onready var tween_controller: Control = TweenController.new()

@onready var games_grid_back_button: BaseButton
@onready var scorecards_flip7_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/Flip7Container/Flip7Button")
@onready var scorecards_lost_cities_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/LostCitiesContainer/LostCitiesButton")
@onready var scorecards_yahtzee_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/YahtzeeContainer/YahtzeeButton")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Make event connections
    scorecards_flip7_button.pressed.connect(_on_flip7_grid_button_pressed)
    scorecards_lost_cities_button.pressed.connect(_on_lost_cities_grid_button_pressed)
    scorecards_yahtzee_button.pressed.connect(_on_yahtzee_grid_button_pressed)

    # In instance buttons
    main_menu_button.pressed.connect(_on_in_instance_main_menu_button_pressed)

    call_deferred("_hide_top_instance")

func _hide_top_instance() -> void:
    top_instance_container.visible = false

func _nav_deeper_to(page: Page) -> void:
    page_history.append(current_page)
    _animate_deeper(current_page, page)
    current_page = page

func _nav_back() -> void:
    if (page_history.is_empty()):
        return

    var previous_page = page_history.pop_back()
    if current_page == Page.GAME_SCORECARD_INSTANCE:
        _prep_main_menu()
    _animate_higher(current_page, previous_page)
    current_page = previous_page

func _prep_main_menu() -> void:
    pages[Page.MAIN].visible = true

    var color_params := scorecard_switch_instance_background_properties.duplicate(true)
    color_params.target_node = background_color_rect
    color_params.color.start = background_color_rect.color
    color_params.color.end = main_menu_background_color
    await tween_controller.universal_tween(color_params).finished
    try_unlock_ui()

func _nav_to_main_menu() -> void:
    _prep_main_menu()
    _animate_higher(current_page, Page.MAIN)
    page_history.clear()
    page_history.append(Page.MAIN)
    current_page = Page.MAIN

# This function handles only the transition between main containers. An instance's specific controls will
# be tweened in the prepare function
func _animate_deeper(current: Page, next: Page) -> void:
    lock_ui()

    var current_container = pages[current]
    var next_container = pages[next]
    cat_buts_transition_higher_out_props.target_node = current_container
    cat_buts_transition_deeper_in_props.target_node = next_container
    tween_controller.universal_tween(cat_buts_transition_higher_out_props)

    var tweens := []
    tweens.append(tween_controller.universal_tween(cat_buts_transition_deeper_in_props))
    await tween_controller.wait_for_all(tweens)
    try_unlock_ui()

func _animate_higher(current: Page, previous_page: Page) -> void:
    lock_ui()
    var current_container = pages[current]
    var previous_container = pages[previous_page]
    cat_buts_transition_higher_in_props.target_node = previous_container
    cat_buts_transition_deeper_out_props.target_node = current_container
    var tweens := []
    tweens.append(tween_controller.universal_tween(cat_buts_transition_higher_in_props))
    tweens.append(tween_controller.universal_tween(cat_buts_transition_deeper_out_props))
    await tween_controller.wait_for_all(tweens)
    try_unlock_ui()

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
    try_unlock_ui()

    if target_node.is_in_group("ScorecardContainerInstance"):
        for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            con.visible = false

        target_node.visible = true

func _animate_button(params: TweenParams) -> Array:
    var tweens := []
    tweens.append(tween_controller.universal_tween(params, true, false))
    tweens.append(tween_controller.universal_tween(params.reset(), false, true))
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

func animate_lost_cities_calculate(points: Dictionary) -> void:
    lock_ui()

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
    var final_size := lc_calc_final_score_properties.target_node.global_position + (lc_calc_final_score_properties.target_node.size / 2)
    lc_calc_final_score_properties.slide.end = screen_center - final_size

    tween_controller.tween_override_stylebox_shadow(fscore, lc_calc_final_score_shadow_color, lc_calc_final_score_shadow_final_size, lc_calc_final_score_shadow_duration)
    await tween_controller.wait_for_all(tween_controller.universal_tween(lc_calc_final_score_properties, true, false))
    await tween_controller.tween_text(fscore, str(points["total"]), lc_calc_text_animation_duration * 3, "999").finished

    set_input_blocker_connection(tween_controller.tween_remove_override_stylebox_shadow.bind(fscore, lc_calc_final_score_shadow_final_size, lc_calc_final_score_shadow_duration / 3))
    set_input_blocker_connection(_clean_up_post_calculate, false)

func _clean_up_post_calculate() -> void:
    await tween_controller.wait_for_all(tween_controller.universal_tween(lc_calc_final_score_properties.reset()))

func _set_delay_and_stuff(old_params: Variant, new_params: Variant, universal_delay: float, longest_duration: float) -> Variant:
    if (new_params.delay + universal_delay) < longest_duration:
        new_params.delay = longest_duration
    elif old_params and (new_params.delay + universal_delay) < old_params.duration:
        new_params.delay = old_params.duration + universal_delay
    else:
        new_params.delay += universal_delay

    if old_params:
        new_params.start = old_params.end

    return new_params

## [param universal_delay] adds a flat wait time to all existing delays
## [br]If [param set_delay_to_longest_prev_tween] is [code]true[/code], it will check every subtween of the [param old_params] and find the one with the longest duration.
## Then it will go through each subtween of the [param new_params] and set the delay to that longest duration [b]if the [param new_params] subtween's delay is not already
## longer than the longest duration[/b].
## [br]If [param set_delay_to_longest_prev_tween] is [code]false[/code], it will compare each subtween's delay of [param new_params] against
## the corresponding subtween's duration of [param old_params] and if that subtween of [param old_params] exists and has a longer duration than the delay of
## [param new_params], it will set the delay of that subtween of [param new_params] to the duration of [param old_params][br]
## Essentially, [param set_delay_to_longest_prev_tween] sets the delays of [param new_params] to mimic [code]await[/code] [method TweenController.wait_for_all] without
## actually using [code]await[/code] during the execution of the tweens in [method MainMenuManager._execute_tween_set]
func _prepare_sequential_tweens(old_params: TweenParams, new_params: TweenParams, universal_delay: float = 0, set_delay_to_longest_prev_tween: bool = false) -> TweenParams:
    var longest_duration: float = -1
    if set_delay_to_longest_prev_tween:
        if old_params.slide:
            if old_params.slide.duration > longest_duration:
                longest_duration = old_params.slide.duration
        if old_params.rotate:
            if old_params.rotate.duration > longest_duration:
                longest_duration = old_params.rotate.duration
        if old_params.scale:
            if old_params.scale.duration > longest_duration:
                longest_duration = old_params.scale.duration
        if old_params.phase:
            if old_params.phase.duration > longest_duration:
                longest_duration = old_params.phase.duration
        if old_params.color:
            if old_params.color.duration > longest_duration:
                longest_duration = old_params.color.duration
        longest_duration += universal_delay

    if new_params.slide:
        new_params.slide = _set_delay_and_stuff(old_params.slide, new_params.slide, universal_delay, longest_duration)
    if new_params.rotate:
        new_params.rotate = _set_delay_and_stuff(old_params.rotate, new_params.rotate, universal_delay, longest_duration)
    if new_params.scale:
        new_params.scale = _set_delay_and_stuff(old_params.scale, new_params.scale, universal_delay, longest_duration)
    if new_params.phase:
        new_params.phase = _set_delay_and_stuff(old_params.phase, new_params.phase, universal_delay, longest_duration)
    if new_params.color:
        new_params.color = _set_delay_and_stuff(old_params.color, new_params.color, universal_delay, longest_duration)

    return new_params

func _execute_tween_set(tween_set: Array[TweenParams]) -> Array[Tween]:
    if tween_set.size() < 1:
        push_error("Expected at least one tween in the tween_set", tween_set)

    var tweens := []

    if tween_set.size() > 1:
        # Initial tween that executes the prepare for tweens
        tweens.append(tween_controller.universal_tween(tween_set[0], true, false))
        # await tween_controller.wait_for_all(tween_controller.universal_tween(tween_set[0], true, false))

        # All the middle tweens that skip prepare and skip cleanup
        for i in (tween_set.size() - 2):
            # print("I: ", i)
            tweens.append(tween_controller.universal_tween(tween_set[i + 1], false, false))

        # Final tween that skips prepare but executes cleanup
        # tween_set[-1].debug()
        tweens.append(tween_controller.universal_tween(tween_set[-1], false, true))
    else:
        tweens.append(tween_controller.universal_tween(tween_set[0], true, false))

    return tweens

func _perform_clear_animation_out() -> void:
    var all_clearables := get_tree().get_nodes_in_group("LostCitiesClearable")

    var tweens := []
    var tparams := lc_clear_top_level_props_begin.duplicate(true)
    tparams.target_node = top_instance_container
    await tween_controller.wait_for_all(tween_controller.universal_tween(tparams, true, false))

    for node in all_clearables:
        var cparams_1: TweenParams
        var cparams_2: TweenParams
        var cparams_3: TweenParams
        var cparams_4: TweenParams
        var cparams_5: TweenParams
        var tween_set: Array[TweenParams] = []

        cparams_1 = lc_clear_individual_clearable_props_1.duplicate(true)
        cparams_1.target_node = node

        tween_set.append(cparams_1)

        if lc_clear_individual_clearable_props_2:
            cparams_2 = lc_clear_individual_clearable_props_2.duplicate(true)
            cparams_2.target_node = node
            cparams_2 = _prepare_sequential_tweens(cparams_1, cparams_2, 0, true)
            tween_set.append(cparams_2)

            if lc_clear_individual_clearable_props_3:
                cparams_3 = lc_clear_individual_clearable_props_3.duplicate(true)
                cparams_3.target_node = node
                cparams_3 = _prepare_sequential_tweens(cparams_2, cparams_3, 0, true)
                tween_set.append(cparams_3)

                if lc_clear_individual_clearable_props_4:
                    cparams_4 = lc_clear_individual_clearable_props_4.duplicate(true)
                    cparams_4.target_node = node
                    cparams_4 = _prepare_sequential_tweens(cparams_3, cparams_4, 0, true)
                    tween_set.append(cparams_4)

                    if lc_clear_individual_clearable_props_5:
                        cparams_5 = lc_clear_individual_clearable_props_5.duplicate(true)
                        cparams_5.target_node = node
                        cparams_5 = _prepare_sequential_tweens(cparams_4, cparams_5, 0, true)
                        tween_set.append(cparams_5)

        tweens.append_array(_execute_tween_set(tween_set))
    await tween_controller.wait_for_all(tweens)
    await get_tree().create_timer(0.5).timeout

func _perform_clear_animation_in() -> void:
    var all_clearables := get_tree().get_nodes_in_group("LostCitiesClearable")

    var tweens := []
    var all_tween_sets: Array[TweenParams] = []
    var tparams := lc_clear_top_level_props_finish.duplicate(true)
    tparams.target_node = top_instance_container
    await tween_controller.wait_for_all(tween_controller.universal_tween(tparams))

    for node in all_clearables:
        var cparams_1: TweenParams
        var cparams_2: TweenParams
        var cparams_3: TweenParams
        var cparams_4: TweenParams
        var cparams_5: TweenParams
        var tween_set: Array[TweenParams] = []

        cparams_1 = lc_clear_individual_clearable_props_1.duplicate(true)
        cparams_1.target_node = node

        tween_set.append(cparams_1.reset(false))

        if lc_clear_individual_clearable_props_2:
            cparams_2 = lc_clear_individual_clearable_props_2.duplicate(true)
            cparams_2.target_node = node
            cparams_2 = _prepare_sequential_tweens(cparams_1, cparams_2, 0, true)
            tween_set.append(cparams_2.reset(false))

            if lc_clear_individual_clearable_props_3:
                cparams_3 = lc_clear_individual_clearable_props_3.duplicate(true)
                cparams_3.target_node = node
                cparams_3 = _prepare_sequential_tweens(cparams_2, cparams_3, 0, true)
                tween_set.append(cparams_3.reset(false))

                if lc_clear_individual_clearable_props_4:
                    cparams_4 = lc_clear_individual_clearable_props_4.duplicate(true)
                    cparams_4.target_node = node
                    cparams_4 = _prepare_sequential_tweens(cparams_3, cparams_4, 0, true)
                    tween_set.append(cparams_4.reset(false))

                    if lc_clear_individual_clearable_props_5:
                        cparams_5 = lc_clear_individual_clearable_props_5.duplicate(true)
                        cparams_5.target_node = node
                        cparams_5 = _prepare_sequential_tweens(cparams_4, cparams_5, 0, true)
                        tween_set.append(cparams_5.reset(false))

        all_tween_sets.append_array(tween_set)
        tweens.append_array(_execute_tween_set(tween_set))
    await tween_controller.wait_for_all(tweens)

    for tween_params in all_tween_sets:
        tween_controller.cleanup_tween(tween_params)

    await get_tree().create_timer(0.5).timeout

func _reset_offset_properties(nodes: Array) -> void:
    for node: Control in nodes:
        node.offset_transform_position = Vector2.ZERO
        node.offset_transform_position_ratio = Vector2.ZERO
        node.offset_transform_scale = Vector2.ONE
        node.offset_transform_rotation = 0.0
        node.offset_transform_pivot = Vector2.ZERO
        node.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
        node.offset_transform_enabled = false
        node.modulate.a = 1.0
        # node.self_modulate = Color.WHITE

func animate_lost_cities_clear() -> void:
    lock_ui()
    await _perform_clear_animation_out()

    var all_clearables := get_tree().get_nodes_in_group("LostCitiesClearable")

    for con in all_clearables:
        # Bridges, vases and dice
        if con is ScribbleController:
            con.clear_scribbles()
        # Button which should have a label child
        elif con.get_node_or_null("Label"):
            con.get_node("Label").text = ""
        # Score labels
        elif con is Label:
            con.text = ""
        else:
            push_error("Unexpected control attempting to be cleared", con)

    await _perform_clear_animation_in()
    _reset_offset_properties(all_clearables)
    tween_controller.print_all_tweens()
    try_unlock_ui()

func _ui_is_locked() -> bool:
    return input_blocker.visible

func lock_ui() -> void:
    input_blocker.visible = true

func try_unlock_ui(attempts: int = 0) -> void:
    if tween_controller.all_tweens_finished() and _ui_is_locked():
        input_blocker.visible = false
        if attempts > 0:
            print("UI unlocked on attempt: ", attempts + 1, " (attempts = ", attempts, ")")
    elif _ui_is_locked():
        await get_tree().create_timer(0.3).timeout
        if attempts > 0:
            print("Tweens not finished, UI still locked. Attempt: ", attempts)
        try_unlock_ui(attempts + 1)

func _reset_input_blocker() -> void:
    input_blocker.visible = false

    for con in input_blocker.pressed.get_connections():
        input_blocker.pressed.disconnect(con.callable)

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

    # Background Color
    var color_params := scorecard_switch_instance_background_properties.duplicate(true)
    color_params.target_node = background_color_rect
    color_params.color.start = background_color_rect.color
    color_params.color.end = data.background_color
    await tween_controller.universal_tween(color_params).finished
    try_unlock_ui()

func on_switch_scorecard_instance(target_scorecard: Scorecard) -> void:
    lock_ui()

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

        try_unlock_ui()

func on_show_lc_num_selector(number_selector: Control, color_button: Control) -> void:
    lock_ui()
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
    try_unlock_ui()

func on_hide_lc_num_selector(number_selector: Control, color_button: Control) -> void:
    lock_ui()
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
    try_unlock_ui()

func on_shake_num_button(target_node: Control) -> void:
    # lock_ui()
    var shake_params := lc_shake_tween_parameters.duplicate(true)
    shake_params.target_node = target_node
    shake_params.slide.duration = shake_params.slide.duration / lc_shake_repetitions
    await tween_controller.universal_tween(shake_params, true, false).finished
    var shake_final_end: Vector2 = shake_params.slide.start

    for rep in (lc_shake_repetitions - 2):
        shake_params.slide.start = shake_params.slide.end
        shake_params.slide.end = - shake_params.slide.end
        await tween_controller.universal_tween(shake_params, false, false).finished

    shake_params.slide.start = target_node.offset_transform_position_ratio if shake_params.slide.by_ratio else target_node.offset_transform_position
    shake_params.slide.end = shake_final_end
    await tween_controller.universal_tween(shake_params, false, true).finished

func set_input_blocker_connection(connection: Callable, override: bool = true) -> void:
    if override:
        for con in input_blocker.pressed.get_connections():
            input_blocker.pressed.disconnect(con.callable)
        input_blocker.pressed.connect(_reset_input_blocker)

    input_blocker.pressed.connect(connection)

func animate_arrow_up(con: Control) -> void:
    # lock_ui()
    var params := lc_arrow_animation_properties.duplicate(true)
    params.target_node = con

    await tween_controller.universal_tween(params).finished
    await tween_controller.universal_tween(params.reset(false)).finished
    # try_unlock_ui()

func animate_arrow_down(con: Control) -> void:
    # lock_ui()
    var params := lc_arrow_animation_properties.duplicate(true)
    params.target_node = con
    params.slide.end *= -1

    await tween_controller.universal_tween(params).finished
    await tween_controller.universal_tween(params.reset(false)).finished
    # try_unlock_ui()

func animate_vase(vase: Control) -> void:
    # lock_ui()
    var params := lc_vase_animation_properties.duplicate(true)
    params.target_node = vase

    await tween_controller.universal_tween(params).finished
    await tween_controller.universal_tween(params.reset(false)).finished
    # try_unlock_ui()

# func open_lc_confirmbox() -> void:
#     var params := lc_confirmbox_open_properties.duplicate(true)
#     params.target_node = lc_confirmbox_confirmation_box

#     await tween_controller.universal_tween(params).finished

# func close_lc_confirmbox() -> void:
#     var params := lc_confirmbox_close_properties.duplicate(true)
#     params.target_node = lc_confirmbox_confirmation_box

#     await tween_controller.universal_tween(params).finished
