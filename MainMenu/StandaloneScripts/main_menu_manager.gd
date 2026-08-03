extends MarginContainer

@export var tween_controller: Control

@export_category("Phase and Color Tweening Properties")
@export_group("Transition Phase Properties")
@export var switch_phase_duration: float
@export var switch_phase_trans: Tween.TransitionType
@export var switch_phase_ease: Tween.EaseType

@export_group("Transition Color Properties")
@export var switch_color_duration: float
@export var switch_color_trans: Tween.TransitionType
@export var switch_color_ease: Tween.EaseType

@export_group("Phase and Scale Properties")
@export var lc_num_sel_phase_duration: float
@export var lc_num_sel_scale_duration: float
@export var lc_num_sel_scale_pivot_ratio: Vector2
@export var lc_num_sel_trans: Tween.TransitionType
@export var lc_num_sel_ease: Tween.EaseType
@export_subgroup("In")
@export var lc_num_sel_in_scale_start: Vector2
@export var lc_num_sel_in_scale_end: Vector2
@export_subgroup("Out")
@export var lc_num_sel_out_scale_start: Vector2
@export var lc_num_sel_out_scale_end: Vector2

@export_category("Slide Tweening Properties")
@export_group("Main Menu Category Buttons")
@export var main_category_container: Control
@export_subgroup("In")
@export var cat_buts_in_dir: Vector2
@export var cat_buts_in_dir_ratio: bool = true
@export var cat_buts_in_duration: float
@export var cat_buts_in_trans: Tween.TransitionType
@export var cat_buts_in_ease: Tween.EaseType
@export_subgroup("Out")
@export var cat_buts_out_dir: Vector2
@export var cat_buts_out_dir_ratio: bool = true
@export var cat_buts_out_duration: float
@export var cat_buts_out_trans: Tween.TransitionType
@export var cat_buts_out_ease: Tween.EaseType

@export_group("Main Menu Scorecards List Container")
@export var main_scorecard_list_container: Control
@export_subgroup("In")
@export var score_buts_in_dir: Vector2
@export var score_buts_in_dir_ratio: bool = true
@export var score_buts_in_duration: float
@export var score_buts_in_trans: Tween.TransitionType
@export var score_buts_in_ease: Tween.EaseType
@export_subgroup("Out")
@export var score_buts_out_dir: Vector2
@export var score_buts_out_dir_ratio: bool = true
@export var score_buts_out_duration: float
@export var score_buts_out_trans: Tween.TransitionType
@export var score_buts_out_ease: Tween.EaseType

@export_group("Top Instance Container")
@export var top_instance_container: Control
@export_subgroup("In")
@export var top_instance_in_dir: Vector2
@export var top_instance_in_dir_ratio: bool = true
@export var top_instance_in_duration: float
@export var top_instance_in_trans: Tween.TransitionType
@export var top_instance_in_ease: Tween.EaseType
@export_subgroup("Out")
@export var top_instance_out_dir: Vector2
@export var top_instance_out_dir_ratio: bool = true
@export var top_instance_out_duration: float
@export var top_instance_out_trans: Tween.TransitionType
@export var top_instance_out_ease: Tween.EaseType

@export_category("Shake Tweening Properties")
@export_group("Lost Cities Invalid Button")
@export var lc_shake_repetitions: int
@export var lc_shake_repetition_duration: float
@export var lc_shake_intensity: float
@export var lc_shake_dir: Vector2
@export var lc_shake_use_relative_pos: bool
@export var lc_shake_trans: Tween.TransitionType
@export var lc_shake_ease: Tween.EaseType

@export_category("Other Properties")
@export_group("Shared Nodes")
@export var main_menu_container: Control
@export var background_color_rect: ColorRect
@export var logo_container: MarginContainer
@export var main_menu_button: BaseButton
@export var inputBlocker: Control
@export var instance_switch_ddl: Control
@export var flip_7_container: Control
@export var lost_cities_container: Control
@export var yahtzee_container: Control

# Setup all the node references
@onready var flip_7_data = $ScorecardData/Flip7
@onready var lost_cities_data = $ScorecardData/LostCities
@onready var yahtzee_data = $ScorecardData/Yahtzee
@onready var games_button: BaseButton = main_category_container.get_node("HBoxContainer/MarginContainer/GamesButton")
#TODO when implementing games
@onready var games_grid_back_button: BaseButton
@onready var scorecards_button: BaseButton = main_category_container.get_node("HBoxContainer/MarginContainer2/ScorecardsButton")
@onready var scorecards_grid_back_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/BackButton")
@onready var scorecards_flip7_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/Flip7Container/Flip7Button")
@onready var scorecards_lost_cities_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/LostCitiesContainer/LostCitiesButton")
@onready var scorecards_yahtzee_button: BaseButton = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/YahtzeeContainer/YahtzeeButton")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Make event connections
    # Slide admin
    tween_controller.slide_in_finished.connect(_on_slide_in_finished)
    tween_controller.slide_out_finished.connect(_on_slide_out_finished)
    tween_controller.phase_in_finished.connect(_on_phase_in_finished)
    tween_controller.phase_out_finished.connect(_on_phase_out_finished)
    tween_controller.phase_and_scale_in_finished.connect(_on_phase_and_scale_in_finished)
    tween_controller.phase_and_scale_out_finished.connect(_on_phase_and_scale_out_finished)
    tween_controller.tween_color_finished.connect(_on_color_tween_finished)
    tween_controller.shake_finished.connect(_on_shake_finished)

    # Main menu category buttons
    games_button.pressed.connect(_on_category_button_pressed)
    scorecards_button.pressed.connect(_on_category_button_pressed)

    # Main menu scorecard grid buttons
    scorecards_grid_back_button.pressed.connect(_on_scorecard_grid_back_button_pressed)
    scorecards_flip7_button.pressed.connect(_on_flip7_grid_button_pressed)
    scorecards_lost_cities_button.pressed.connect(_on_lost_cities_grid_button_pressed)
    scorecards_yahtzee_button.pressed.connect(_on_yahtzee_grid_button_pressed)

    # In instance buttons
    main_menu_button.pressed.connect(_on_in_instance_main_menu_button_pressed)

func _on_category_button_pressed() -> void:
    _lock_ui()
    # This steps down in the UI so it utilizes the INs
    tween_controller.slide_in(main_scorecard_list_container, score_buts_in_dir, score_buts_in_dir_ratio, score_buts_in_duration, score_buts_in_trans, score_buts_in_ease)
    tween_controller.slide_out(main_category_container, score_buts_in_dir, score_buts_in_dir_ratio, score_buts_in_duration, score_buts_in_trans, score_buts_in_ease)

func _on_scorecard_grid_back_button_pressed() -> void:
    _lock_ui()
    # This steps up in the UI so it utilizes the OUTs
    tween_controller.slide_in(main_category_container, score_buts_out_dir, cat_buts_out_dir_ratio, cat_buts_out_duration, cat_buts_out_trans, cat_buts_out_ease)
    tween_controller.slide_out(main_scorecard_list_container, score_buts_out_dir, cat_buts_out_dir_ratio, cat_buts_out_duration, cat_buts_out_trans, cat_buts_out_ease)

func _on_flip7_grid_button_pressed() -> void:
    _lock_ui()
    flip_7_container.visible = true
    lost_cities_container.visible = false
    yahtzee_container.visible = false
    # This steps down in the UI so it utilizes the INs
    tween_controller.slide_in(top_instance_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)
    tween_controller.slide_out(main_menu_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)

func _on_lost_cities_grid_button_pressed() -> void:
    _lock_ui()
    flip_7_container.visible = false
    lost_cities_container.visible = true
    yahtzee_container.visible = false
    # This steps down in the UI so it utilizes the INs
    tween_controller.slide_in(top_instance_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)
    tween_controller.slide_out(main_menu_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)

func _on_yahtzee_grid_button_pressed() -> void:
    _lock_ui()
    flip_7_container.visible = false
    lost_cities_container.visible = false
    yahtzee_container.visible = true
    # This steps down in the UI so it utilizes the INs
    tween_controller.slide_in(top_instance_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)
    tween_controller.slide_out(main_menu_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)

func _on_in_instance_main_menu_button_pressed() -> void:
    _lock_ui()
    main_category_container.visible = true
    main_scorecard_list_container.visible = false
    # This steps up in the UI so it utilizes the OUTs
    tween_controller.slide_in(main_menu_container, top_instance_out_dir, top_instance_out_dir_ratio, top_instance_out_duration, top_instance_out_trans, top_instance_out_ease)
    tween_controller.slide_out(top_instance_container, top_instance_out_dir, top_instance_out_dir_ratio, top_instance_out_duration, top_instance_out_trans, top_instance_out_ease)

func _on_slide_in_finished(target_node: Control) -> void:
    _try_unlock_ui()

    if target_node.is_in_group("ScorecardContainerInstance"):
        for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            con.visible = false

        target_node.visible = true

func _on_slide_out_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_phase_in_finished(target_node: Control) -> void:
    _try_unlock_ui()

    if target_node.is_in_group("ScorecardContainerInstance"):
        for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
            con.visible = false

        target_node.visible = true

func _on_phase_out_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_color_tween_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_phase_and_scale_in_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_phase_and_scale_out_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_shake_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _ui_is_locked() -> bool:
    return inputBlocker.visible

func _lock_ui() -> void:
    inputBlocker.visible = true

func _try_unlock_ui() -> void:
    for attempts in range(3):
        if tween_controller.all_tweens_finished() and _ui_is_locked():
            inputBlocker.visible = false
            break
        elif _ui_is_locked():
            await get_tree().process_frame

func on_switch_instance(target_instance: Control) -> void:
    _lock_ui()

    instance_switch_ddl.manually_toggle_button_off()

    # find the current active instance and phase it out and phase in the new one
    var current_instance: Control
    for con: Control in get_tree().get_nodes_in_group("ScorecardContainerInstance"):
        if con.visible:
            current_instance = con
            break

    var current_logo: Control
    for tex: Node in logo_container.get_children():
        if tex.visible:
            current_logo = tex
            break

    var target_logo: Control = logo_container.get_node(target_instance.name + "Logo")

    var new_color = Color.BLACK
    if target_instance.name == "Flip7":
        new_color = flip_7_data.background_color
    elif target_instance.name == "LostCities":
        new_color = lost_cities_data.background_color
    elif target_instance.name == "Yahtzee":
        new_color = yahtzee_data.background_color

    if current_instance and new_color and current_logo and target_logo:
        tween_controller.tween_color_rect_color(background_color_rect, new_color, switch_color_duration, switch_color_trans, switch_color_ease)
        tween_controller.phase_out(current_instance, switch_phase_duration, switch_phase_trans, switch_phase_ease)
        tween_controller.phase_in(target_instance, switch_phase_duration, switch_phase_trans, switch_phase_ease)
        tween_controller.phase_out(current_logo, switch_phase_duration, switch_phase_trans, switch_phase_ease)
        tween_controller.phase_in(target_logo, switch_phase_duration, switch_phase_trans, switch_phase_ease)

func on_show_lc_num_selector(target_node: Control) -> void:
    _lock_ui()
    tween_controller.phase_and_scale_in(target_node, lc_num_sel_phase_duration, lc_num_sel_scale_duration, lc_num_sel_in_scale_start,
                                        lc_num_sel_in_scale_end, lc_num_sel_scale_pivot_ratio, lc_num_sel_trans, lc_num_sel_ease)

func on_hide_lc_num_selector(target_node: Control) -> void:
    _lock_ui()
    tween_controller.phase_and_scale_out(target_node, lc_num_sel_phase_duration, lc_num_sel_scale_duration, lc_num_sel_out_scale_start,
                                        lc_num_sel_out_scale_end, lc_num_sel_scale_pivot_ratio, lc_num_sel_trans, lc_num_sel_ease)

func on_shake_num_button(target_node: Control) -> void:
    # _lock_ui()
    tween_controller.shake(target_node, lc_shake_dir, lc_shake_use_relative_pos, lc_shake_repetition_duration, lc_shake_repetitions, lc_shake_intensity, lc_shake_trans, lc_shake_ease)
