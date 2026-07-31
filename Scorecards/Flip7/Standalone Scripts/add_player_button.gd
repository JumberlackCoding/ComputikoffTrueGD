extends Button

@export var names_vbox: VBoxContainer
@export var totals_vbox: VBoxContainer
@export var rounds_vbox: VBoxContainer

@export var player_name_prefab: PackedScene
@export var player_total_prefab: PackedScene
@export var player_rounds_prefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pressed.connect(_on_button_press)

func _on_button_press() -> void:
    var name_field := player_name_prefab.instantiate()
    var total_field := player_total_prefab.instantiate()
    var rounds_container := player_rounds_prefab.instantiate()

    names_vbox.add_child(name_field)
    totals_vbox.add_child(total_field)
    rounds_vbox.add_child(rounds_container)

    total_field.set_round_container(rounds_container)

    move_to_front()