extends Control

@onready var confirm_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer2/OkButton
@onready var cancel_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/CancelButton
@onready var main_manager: MarginContainer = get_node( "/root/Main" )
@onready var tween_orch: Control = get_parent().get_parent().get_node( "TweenOrchestrator" )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    cancel_button.pressed.connect( close_confirmation_box )
    cancel_button.pressed.connect( main_manager._reset_input_blocker )
    confirm_button.pressed.connect( close_confirmation_box )

    call_deferred( "_hide_after_start" )

func _hide_after_start() -> void:
    visible = false

func _reset_confirm_button() -> void:
    for con in confirm_button.pressed.get_connections():
        confirm_button.pressed.disconnect( con.callable )
    confirm_button.pressed.connect( _reset_confirm_button )

func set_confirmation_box_confirm_action( connection: Callable, override: bool = true ) -> void:
    if override:
        _reset_confirm_button()
        confirm_button.pressed.connect( main_manager._reset_input_blocker )
        confirm_button.pressed.connect( close_confirmation_box )

    confirm_button.pressed.connect( connection )

func close_confirmation_box() -> void:
    await tween_orch.close_lc_confirmbox()
