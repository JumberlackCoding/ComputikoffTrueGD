extends Button

@export_group("Scribble parameters")
@export var scribbleable: bool = false
@export var scribble_count: int = 6 # How many scribble passes
@export var scribble_vertical: bool = true # Direction of scribble
@export var scribble_horizontal: bool = true # Direction of scribble
@export var scribble_messiness: float = 12.0 # Random jitter amount
@export var scribble_edge_margin: float = 5.0 # Keep scribble away from edges
@export var points_per_scribble: int = 12 # More points = more chaotic

@export_group("Circle parameters")
@export var circleable: bool = false
## If not overridden, the size is derived from the texture from the theme override's StyleBoxTexture
@export var override_circle_size: bool = false
@export var circle_width: float = 80.0
@export var circle_height: float = 80.0
@export var non_overridden_circle_width_padding: float = 11.0
@export var non_overridden_circle_height_padding: float = 8.0
@export var points_in_circle: int = 16
@export var circle_messiness: float = 2.0

@export_group("X parameters")
@export var x_able: bool = false
@export var x_count: int = 5
@export var x_messiness: float = 2
@export var x_edge_margin: float = 0
@export var points_per_x: int = 3

@export_group("Shared parameters")
@export var stroke_width: float = 3.0
@export var stroke_color: Color = Color.BLACK

var stage: int = 0 # 0 = none, 1 = scribble, 2 = circle, 3 = X
var drawn_paths: Array = []

func _ready() -> void:
    pressed.connect(_cycle_stage)
    call_deferred("_set_width")


func _process(_delta: float) -> void:
    queue_redraw()

func _set_width() -> void:
    var sb := get_theme_stylebox("normal", "Button") as StyleBoxTexture

    if sb:
        var tex := sb.texture
        var w: float = tex.get_width()
        var h: float = tex.get_height()
        var min_w: float = w / h * size.y
        custom_minimum_size.x = min_w

        # print("W: ", w, " H: ", h, " MaxW: ", min_w)

func _cycle_stage():
    stage = (stage + 1) % 4

    match stage:
        0:
            # Clear
            drawn_paths.clear()
        1:
            # Scribble
            if scribbleable:
                _generate_scribble()
            else:
                _cycle_stage()
        2:
            # Circle
            if circleable:
                _generate_circle()
            else:
                _cycle_stage()
        3:
            # X
            if x_able:
                _generate_x()
            else:
                _cycle_stage()

func get_checked() -> bool:
    return true if stage == 2 else false

func _generate_scribble() -> void:
    drawn_paths.clear()

    var rect := Rect2(Vector2.ZERO, size) # Control nodes draw from (0,0)

    # Shrink rect by margin
    if scribble_edge_margin >= rect.size.x / 2:
        scribble_edge_margin = rect.size.x / 2

    rect.position += Vector2(scribble_edge_margin, scribble_edge_margin)
    rect.size -= Vector2(scribble_edge_margin * 2, scribble_edge_margin * 2)

    for i in scribble_count:
        if scribble_horizontal and scribble_vertical:
            if randi() % 2 == 0:
                drawn_paths.append(_draw_horizontal_scribble(rect))
            else:
                drawn_paths.append(_draw_vertical_scribble(rect))
        elif scribble_horizontal:
                drawn_paths.append(_draw_horizontal_scribble(rect))
        elif scribble_vertical:
                drawn_paths.append(_draw_vertical_scribble(rect))

func _generate_circle() -> void:
    drawn_paths.clear()

    var center := size / 2.0
    var rx: float = -1
    var ry: float = -1

    if not override_circle_size:
        rx = size.x / 2.0 + non_overridden_circle_width_padding
        ry = size.y / 2.0 + non_overridden_circle_height_padding
        # var sb := get_theme_stylebox("normal", "Button") as StyleBoxTexture

        # if sb:
        #     var tex := sb.texture
        #     rx = tex.get_width() / 2.0 + non_overridden_circle_width_padding
        #     ry = tex.get_height() / 2.0 + non_overridden_circle_height_padding

    if rx < 0 or ry < 0 or override_circle_size:
        rx = circle_width / 2.0
        ry = circle_height / 2.0

    var points := []

    for i in points_in_circle:
        var angle := (TAU * float(i)) / points_in_circle

        var x := center.x + cos(angle) * rx
        var y := center.y + sin(angle) * ry

        # Add jitter
        x += randf_range(-circle_messiness, circle_messiness)
        y += randf_range(-circle_messiness, circle_messiness)

        points.append(Vector2(x, y))

    # Close the loop
    points.append(points[0])

    drawn_paths.append(points)

func _draw():
    for path in drawn_paths:
        draw_polyline(path, stroke_color, stroke_width)

func _draw_horizontal_scribble(rect: Rect2) -> Array:
    var y := randf_range(rect.position.y, rect.position.y + rect.size.y)
    var points := []

    # Multi‑point chaotic scribble left ↔ right
    for i in points_per_scribble:
        var t := float(i) / (points_per_scribble - 1)
        var x: float = lerp(rect.position.x, rect.position.x + rect.size.x, t)
        x += randf_range(-scribble_messiness, scribble_messiness)
        var jitter_y := y + randf_range(-scribble_messiness, scribble_messiness)
        points.append(Vector2(x, jitter_y))

    return points

func _draw_vertical_scribble(rect: Rect2) -> Array:
    var x := randf_range(rect.position.x, rect.position.x + rect.size.x)
    var points := []

    # Multi‑point chaotic scribble top ↕ bottom
    for i in points_per_scribble:
        var t := float(i) / (points_per_scribble - 1)
        var y: float = lerp(rect.position.y, rect.position.y + rect.size.y, t)
        y += randf_range(-scribble_messiness, scribble_messiness)
        var jitter_x := x + randf_range(-scribble_messiness, scribble_messiness)
        points.append(Vector2(jitter_x, y))

    return points

func _generate_x() -> void:
    drawn_paths.clear()

    var rect := Rect2(Vector2.ZERO, size) # Control nodes draw from (0,0)

    # Shrink rect by margin
    if x_edge_margin >= rect.size.x / 2:
        x_edge_margin = rect.size.x / 2

    rect.position += Vector2(x_edge_margin, x_edge_margin)
    rect.size -= Vector2(x_edge_margin * 2, x_edge_margin * 2)

    for i in x_count:
        var points := []
        for j in points_per_x:
            var t := float(j) / (points_per_x - 1)
            var x: float = lerp(rect.position.x, rect.position.x + rect.size.x, t)
            var y: float = lerp(rect.position.y, rect.position.y + rect.size.y, t)
            x += randf_range(-x_messiness, x_messiness)
            y += randf_range(-x_messiness, x_messiness)
            points.append(Vector2(x, y))

        drawn_paths.append(points)

        points = []
        for j in points_per_x:
            var t := float(j) / (points_per_x - 1)
            var x: float = lerp(rect.position.x, rect.position.x + rect.size.x, t)
            var y: float = lerp(rect.position.y + rect.size.y, rect.position.y, t)
            x += randf_range(-x_messiness, x_messiness)
            y += randf_range(-x_messiness, x_messiness)
            points.append(Vector2(x, y))

        drawn_paths.append(points)