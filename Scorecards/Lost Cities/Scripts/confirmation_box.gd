extends Control

@onready var confirm_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer2/OkButton
@onready var cancel_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/CancelButton
@onready var main_manager: MarginContainer = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    cancel_button.pressed.connect(close_confirmation_box)
    cancel_button.pressed.connect(main_manager._reset_input_blocker)
    confirm_button.pressed.connect(close_confirmation_box)

    call_deferred("_hide_after_start")

func _hide_after_start() -> void:
    visible = false

func _reset_confirm_button() -> void:
    for con in confirm_button.pressed.get_connections():
        confirm_button.pressed.disconnect(con.callable)

    close_confirmation_box()

func set_confirmation_box_confirm_action(connection: Callable, override: bool = true) -> void:
    if override:
        for con in confirm_button.pressed.get_connections():
            confirm_button.pressed.disconnect(con.callable)
        confirm_button.pressed.connect(_reset_confirm_button)
        confirm_button.pressed.connect(main_manager._reset_input_blocker)

    confirm_button.pressed.connect(connection)

func show_confirmation_box() -> void:
    main_manager.lock_ui()
    await main_manager.open_lc_confirmbox()
    main_manager.set_input_blocker_connection(self.close_confirmation_box)

func close_confirmation_box() -> void:
    await main_manager.close_lc_confirmbox()
