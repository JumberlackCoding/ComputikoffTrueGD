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
@export_subgroup("In", "score_buts_in_")
@export var score_buts_in_dir: Vector2
@export var score_buts_in_dir_ratio: bool = true
@export var score_buts_in_duration: float
@export var score_buts_in_trans: Tween.TransitionType
@export var score_buts_in_ease: Tween.EaseType
@export_subgroup("Out", "score_buts_out_")
@export var score_buts_out_dir: Vector2
@export var score_buts_out_dir_ratio: bool = true
@export var score_buts_out_duration: float
@export var score_buts_out_trans: Tween.TransitionType
@export var score_buts_out_ease: Tween.EaseType

@export_group("Top Instance Container")
@export var top_instance_container: Control
@export_subgroup("In", "top_instance_in_")
@export var top_instance_in_dir: Vector2
@export var top_instance_in_dir_ratio: bool = true
@export var top_instance_in_duration: float
@export var top_instance_in_trans: Tween.TransitionType
@export var top_instance_in_ease: Tween.EaseType
@export_subgroup("Out", "top_instance_out")
@export var top_instance_out_dir: Vector2
@export var top_instance_out_dir_ratio: bool = true
@export var top_instance_out_duration: float
@export var top_instance_out_trans: Tween.TransitionType
@export var top_instance_out_ease: Tween.EaseType

@export_category("Shared UI Tween Properties")
@export_group("Transition Phase Properties", "switch_")
@export var scorecard_transition_properties: TweenParams
@export var switch_phase_duration: float
@export var switch_phase_trans: Tween.TransitionType
@export var switch_phase_ease: Tween.EaseType

@export_group("Transition Color Properties", "switch_")
@export var switch_color_duration: float
@export var switch_color_trans: Tween.TransitionType
@export var switch_color_ease: Tween.EaseType

@export_category("Lost Cities Tween Properties")
@export_group("Invalid Button Selection", "lc_shake_")
@export var lc_shake_repetitions: int
@export var lc_shake_repetition_duration: float
@export var lc_shake_intensity: float
@export var lc_shake_dir: Vector2
## When [code]true[/code] the dir is normalized and intensity is used for magnitude and it uses the [code]offset_transform_position_ratio[/code] property
@export var lc_shake_use_relative_pos: bool
@export var lc_shake_trans: Tween.TransitionType
@export var lc_shake_ease: Tween.EaseType

@export_group("Colored Button To Number Selection Transition")
@export_subgroup("Transition to open number selector", "lc_col_to_num_sel_")
@export var lc_col_to_num_sel_num_selector_properties: TweenParams
## Colored Button [code]slide_end[/code], [code]slide_by_ratio[/code], and [code]scale_end[/code] are programatically overwritten
@export var lc_col_to_num_sel_color_button_properties: TweenParams
@export_subgroup("Transition to close number selector", "lc_num_sel_to_col_")
@export var lc_num_sel_to_col_num_selector_properties: TweenParams
## Colored Button [code]slide_start[/code], [code]slide_by_ratio[/code], and [code]scale_scale[/code] are programatically overwritten
@export var lc_num_sel_to_col_color_button_properties: TweenParams

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Make event connections
    # Slide admin
    tween_controller.phase_in_finished.connect(_on_phase_in_finished)

    # Generic tween for when nothing but unlocking the UI is needed after tweening is done
    tween_controller.generic_tween_finished.connect(_on_generic_tween_finished)

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

func _get_page(page: Page) -> Control:
    return pages[page]

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
    _get_page(Page.MAIN).visible = true
    _get_page(Page.GAME_SELECT).visible = false
    _get_page(Page.SCORECARD_SELECT).visible = false
    background_color_rect.color = main_menu_background_color

func _nav_to_main_menu() -> void:
    _prep_main_menu()
    _animate_higher(current_page, Page.MAIN_MENU_INSTANCE)
    page_history.clear()
    page_history.append(Page.MAIN)
    current_page = Page.MAIN

func _animate_deeper(current: Page, next: Page) -> void:
    _lock_ui()
    if next == Page.GAME_SCORECARD_INSTANCE:
        current = Page.MAIN_MENU_INSTANCE
    var current_container = _get_page(current)
    var next_container = _get_page(next)
    cat_buts_transition_higher_out_props.target_node = current_container
    cat_buts_transition_deeper_in_props.target_node = next_container
    tween_controller.universal_tween(cat_buts_transition_higher_out_props)
    var tweens = tween_controller.universal_tween(cat_buts_transition_deeper_in_props)
    await tween_controller.wait_for_all(tweens)
    tween_controller.cleanup_tween(cat_buts_transition_higher_out_props)
    tween_controller.cleanup_tween(cat_buts_transition_deeper_in_props)
    _try_unlock_ui()

func _animate_higher(current: Page, previous_page: Page) -> void:
    _lock_ui()
    var current_container = _get_page(current)
    var previous_container = _get_page(previous_page)
    cat_buts_transition_higher_in_props.target_node = previous_container
    cat_buts_transition_deeper_out_props.target_node = current_container
    tween_controller.universal_tween(cat_buts_transition_higher_in_props)
    await tween_controller.wait_for_all(tween_controller.universal_tween(cat_buts_transition_deeper_out_props))
    tween_controller.cleanup_tween(cat_buts_transition_higher_in_props)
    tween_controller.cleanup_tween(cat_buts_transition_deeper_out_props)
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

func _on_generic_tween_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_phase_in_finished(target_node: Control) -> void:
    _try_unlock_ui()

    if target_node.is_in_group("ScorecardContainerInstance"):
        for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            con.visible = false

        target_node.visible = true

func _on_lost_cities_calculate_pressed() -> void:
    print(scorecard_data[Scorecard.LOST_CITIES].get_instance().calculate())

func _ui_is_locked() -> bool:
    return inputBlocker.visible

func _lock_ui() -> void:
    inputBlocker.visible = true

func _try_unlock_ui() -> void:
    for attempts in range(1):
        if tween_controller.all_tweens_finished() and _ui_is_locked():
            inputBlocker.visible = false
            if attempts > 1:
                print("_try_unlock_ui() succeeded")
            break
        elif _ui_is_locked():
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
        # Background Color
        tween_controller.tween_color_rect_color(background_color_rect, new_color, switch_color_duration, switch_color_trans, switch_color_ease)

        # Top Scorecard Instance
        tween_controller.phase_out(current_instance, switch_phase_duration, switch_phase_trans, switch_phase_ease)
        tween_controller.phase_in(scorecard_data[target_scorecard].get_instance(), switch_phase_duration, switch_phase_trans, switch_phase_ease)

        # Logo
        tween_controller.phase_out(current_logo, switch_phase_duration, switch_phase_trans, switch_phase_ease)
        tween_controller.phase_in(target_logo, switch_phase_duration, switch_phase_trans, switch_phase_ease)

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

    tween_controller.universal_tween(lc_col_to_num_sel_color_button_properties)
    var tweens = tween_controller.universal_tween(lc_col_to_num_sel_num_selector_properties)
    await tween_controller.wait_for_all(tweens)
    tween_controller.cleanup_tween(lc_col_to_num_sel_color_button_properties)
    tween_controller.cleanup_tween(lc_col_to_num_sel_num_selector_properties)
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
    tween_controller.universal_tween(lc_num_sel_to_col_num_selector_properties)
    var tweens = tween_controller.universal_tween(lc_num_sel_to_col_color_button_properties)
    await tween_controller.wait_for_all(tweens)
    tween_controller.cleanup_tween(lc_num_sel_to_col_num_selector_properties)
    tween_controller.cleanup_tween(lc_num_sel_to_col_color_button_properties)
    _try_unlock_ui()

func on_shake_num_button(target_node: Control) -> void:
    # _lock_ui()
    tween_controller.shake(target_node, lc_shake_dir, lc_shake_use_relative_pos, lc_shake_repetition_duration, lc_shake_repetitions, lc_shake_intensity, lc_shake_trans, lc_shake_ease)
