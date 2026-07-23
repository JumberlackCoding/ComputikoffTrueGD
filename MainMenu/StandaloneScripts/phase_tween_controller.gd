extends Control

@export var phase_on_ready: bool = false
@export var phase_on_click: bool = true
@export var buttons_to_be_clicked: Array[BaseButton]
@export var phase_in: bool = true
@export var duration: float = 2.0
var target: Control
var tween: Tween
var start: int = 0
var end: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    target = get_parent()
    target.offset_transform_enabled = true

    # await for the next frame to guarantee the parent's positioning and everything has completed
    await get_tree().process_frame

    if phase_in:
        start = 0
        end = 1
    else:
        start = 1
        end = 0

    if phase_on_ready:
        target.ready.connect(_do_phase)

    if phase_on_click:
        if target is BaseButton:
            target.pressed.connect(_do_phase)
        elif buttons_to_be_clicked.size() > 0:
            for button in buttons_to_be_clicked:
                button.pressed.connect(_do_phase)

func _do_phase():
    if tween:
        tween.kill()

    tween = get_parent().create_tween()
    # tween.set_trans(Tween.TRANS_QUINT)
    # tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(target, "modulate:a", end, duration).from(start)
