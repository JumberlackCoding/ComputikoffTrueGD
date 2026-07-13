extends Control

@export
var min_size: int = 200
@export
var max_size: int = 600

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #await get_tree().process_frame
    call_deferred("_update_size")

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        call_deferred("_update_size")

func _update_size():
    var width = size.x
    var sep = get_theme_constant("h_separation")

    var count = max(floor((width + sep) / (min_size + sep)), 1)
    var ideal_size = (width - (count - 1) * sep) / count
    var final_size = clamp(ideal_size, min_size, max_size)
    
    #print("Width: ", width, "\nSep: ", sep, "\nCount: ", count, "\nIdeal Size: ", ideal_size, "\nFinal Size: ", final_size)

    for child in get_children():
        if child is Control:
            child.custom_minimum_size = Vector2(final_size, final_size)
            child.custom_maximum_size = Vector2(final_size, final_size)
