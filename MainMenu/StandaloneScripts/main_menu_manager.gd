extends MarginContainer

@export_category("Phase Tweening Properties")
@export var phase_controller: Control
@export_group("Scorecard Transition Properties")
@export var score_trans_duration: float
@export var score_trans_trans: Tween.TransitionType
@export var score_trans_ease: Tween.EaseType
@export var flip_7_container: Control
@export var lost_cities_container: Control
@export var yahtzee_container: Control
var flip_7_data: Control
var lost_cities_data: Control
var yahtzee_data: Control

@export_category("Slide Tweening Properties")
@export var slide_controller: Control
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

@export_category("Other Properties")
@export_group("Shared Nodes")
@export var main_menu_container: Control
@export var background_color_rect: ColorRect
@export var logo: TextureRect
@export var main_menu_button: BaseButton
@export var inputBlocker: Control

var games_button: BaseButton
var games_grid_back_button: BaseButton
var scorecards_button: BaseButton
var scorecards_grid_back_button: BaseButton
var scorecards_flip7_button: BaseButton
var scorecards_lost_cities_button: BaseButton
var scorecards_yahtzee_button: BaseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Setup all the node references
    flip_7_data = $ScorecardData/Flip7
    lost_cities_data = $ScorecardData/LostCities
    yahtzee_data = $ScorecardData/Yahtzee

    games_button = main_category_container.get_node("HBoxContainer/MarginContainer/GamesButton")
    scorecards_button = main_category_container.get_node("HBoxContainer/MarginContainer2/ScorecardsButton")
    scorecards_grid_back_button = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/BackButton")
    scorecards_flip7_button = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/Flip7Container/Flip7Button")
    scorecards_lost_cities_button = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/LostCitiesContainer/LostCitiesButton")
    scorecards_yahtzee_button = main_scorecard_list_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/HFlowContainer/YahtzeeContainer/YahtzeeButton")

    # Make event connections
    # Slide admin
    slide_controller.slide_in_finished.connect(_on_slide_in_finished)
    slide_controller.slide_out_finished.connect(_on_slide_out_finished)

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
    slide_controller.slide_in(main_scorecard_list_container, score_buts_in_dir, score_buts_in_dir_ratio, score_buts_in_duration, score_buts_in_trans, score_buts_in_ease)
    slide_controller.slide_out(main_category_container, score_buts_in_dir, score_buts_in_dir_ratio, score_buts_in_duration, score_buts_in_trans, score_buts_in_ease)

func _on_scorecard_grid_back_button_pressed() -> void:
    _lock_ui()
    # This steps up in the UI so it utilizes the OUTs
    slide_controller.slide_in(main_category_container, score_buts_out_dir, cat_buts_out_dir_ratio, cat_buts_out_duration, cat_buts_out_trans, cat_buts_out_ease)
    slide_controller.slide_out(main_scorecard_list_container, score_buts_out_dir, cat_buts_out_dir_ratio, cat_buts_out_duration, cat_buts_out_trans, cat_buts_out_ease)

func _on_flip7_grid_button_pressed() -> void:
    _lock_ui()
    flip_7_container.visible = true
    lost_cities_container.visible = false
    yahtzee_container.visible = false
    # This steps down in the UI so it utilizes the INs
    slide_controller.slide_in(top_instance_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)
    slide_controller.slide_out(main_menu_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)

func _on_lost_cities_grid_button_pressed() -> void:
    _lock_ui()
    flip_7_container.visible = false
    lost_cities_container.visible = true
    yahtzee_container.visible = false
    # This steps down in the UI so it utilizes the INs
    slide_controller.slide_in(top_instance_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)
    slide_controller.slide_out(main_menu_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)

func _on_yahtzee_grid_button_pressed() -> void:
    _lock_ui()
    flip_7_container.visible = false
    lost_cities_container.visible = false
    yahtzee_container.visible = true
    # This steps down in the UI so it utilizes the INs
    slide_controller.slide_in(top_instance_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)
    slide_controller.slide_out(main_menu_container, top_instance_in_dir, top_instance_in_dir_ratio, top_instance_in_duration, top_instance_in_trans, top_instance_in_ease)

func _on_in_instance_main_menu_button_pressed() -> void:
    _lock_ui()
    main_category_container.visible = true
    main_scorecard_list_container.visible = false
    # This steps up in the UI so it utilizes the OUTs
    slide_controller.slide_in(main_menu_container, top_instance_out_dir, top_instance_out_dir_ratio, top_instance_out_duration, top_instance_out_trans, top_instance_out_ease)
    slide_controller.slide_out(top_instance_container, top_instance_out_dir, top_instance_out_dir_ratio, top_instance_out_duration, top_instance_out_trans, top_instance_out_ease)


func _on_slide_in_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_slide_out_finished(target_node: Control) -> void:
    target_node.offset_transform_position = Vector2.ZERO
    target_node.offset_transform_position_ratio = Vector2.ZERO
    target_node.offset_transform_enabled = false
    _try_unlock_ui()

func _lock_ui() -> void:
    inputBlocker.visible = true

func _try_unlock_ui() -> void:
    await get_tree().process_frame
    if slide_controller.all_tweens_finished():
        inputBlocker.visible = false
