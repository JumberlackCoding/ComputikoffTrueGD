class_name PhaseParams
extends Resource

@export_range(0, 5, 0.05, "or_greater", "prefer_slider", "suffix:seconds") var duration: float = 1.0 ## Default [code]1.0[/code]
@export_range(0, 5, 0.05, "or_greater", "prefer_slider", "suffix:seconds") var delay: float = 0.0 ## Default [code]0.0[/code]
@export_range(0, 1, 0.01) var start: float = 1.0 ## Default [code]1.0[/code]
@export_range(0, 1, 0.01) var end: float = 1.0 ## Default [code]1.0[/code]
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR ## Default [code]Tween.TRANS_LINEAR[/code]
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT ## Default [code]Tween.EASE_IN_OUT[/code]