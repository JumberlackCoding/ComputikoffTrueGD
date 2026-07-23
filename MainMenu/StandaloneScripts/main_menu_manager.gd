extends MarginContainer

@export_category("Phase Tweening Properties")
@export_group("Phasing")
@export var phase_controller: Control

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
var games_button: BaseButton
var scorecards_button: BaseButton

@export_group("Main Menu Scorecards Button")
@export var main_scorecard_container: Control
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

@export_category("Other Properties")
@export var inputBlocker: Control

var games_grid_back_button: BaseButton
var scorecards_grid_back_button: BaseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    games_button = main_category_container.get_node("HBoxContainer/MarginContainer/GamesButton")
    scorecards_button = main_category_container.get_node("HBoxContainer/MarginContainer2/ScorecardsButton")
    scorecards_grid_back_button = main_scorecard_container.get_node("ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/BackButton")

    slide_controller.slide_in_finished.connect(_on_slide_in_finished)
    slide_controller.slide_out_finished.connect(_on_slide_out_finished)
    games_button.pressed.connect(_on_category_button_pressed)
    scorecards_button.pressed.connect(_on_category_button_pressed)
    scorecards_grid_back_button.pressed.connect(_on_scorecard_back_button_pressed)

func _on_category_button_pressed() -> void:
    _lock_ui()
    slide_controller.slide_out(main_category_container, cat_buts_out_dir, cat_buts_out_dir_ratio, cat_buts_out_duration, cat_buts_out_trans, cat_buts_out_ease)
    slide_controller.slide_in(main_scorecard_container, score_buts_in_dir, score_buts_in_dir_ratio, score_buts_in_duration, score_buts_in_trans, score_buts_in_ease)

func _on_scorecard_back_button_pressed() -> void:
    _lock_ui()
    slide_controller.slide_in(main_category_container, cat_buts_in_dir, cat_buts_in_dir_ratio, cat_buts_in_duration, cat_buts_in_trans, cat_buts_in_ease)
    slide_controller.slide_out(main_scorecard_container, score_buts_out_dir, score_buts_out_dir_ratio, score_buts_out_duration, score_buts_out_trans, score_buts_out_ease)

func _on_slide_in_finished(_target_node: Control) -> void:
    _try_unlock_ui()

func _on_slide_out_finished(target_node: Control) -> void:
    _try_unlock_ui()

    if target_node == main_category_container:
        main_category_container.visible = false

func _lock_ui() -> void:
    inputBlocker.visible = true

func _try_unlock_ui() -> void:
    await get_tree().process_frame
    if slide_controller.all_tweens_finished():
        inputBlocker.visible = false
