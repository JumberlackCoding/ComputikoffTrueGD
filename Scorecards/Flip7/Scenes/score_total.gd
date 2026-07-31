extends LineEdit

@export var round_container: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if round_container:
        for con: LineEdit in round_container.get_children():
            con.text_changed.connect(_calculate_total)

func _calculate_total(_new_text: String) -> void:
    var total: int = 0
    for con: LineEdit in round_container.get_children():
        if con.text.is_valid_int():
            total += con.text.to_int()

    text = str(total)

func set_round_container(cont: Control) -> void:
    round_container = cont

    for con: LineEdit in round_container.get_children():
            con.text_changed.connect(_calculate_total)
