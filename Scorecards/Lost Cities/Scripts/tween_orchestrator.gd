extends Control

@export_category("Lost Cities Tween Properties")
@export_group("Invalid Button Selection", "lc_shake_")
@export var lc_shake_repetitions: int
@export var lc_shake_tween_parameters: TweenParams

@export_group("Colored Button To Number Selection Transition")
@export_subgroup("Transition to open number selector", "lc_col_to_num_sel_")
@export var lc_col_to_num_sel_num_selector_properties: TweenParams
## Colored Button [code]slide_end[/code], [code]slide_by_ratio[/code], and [code]scale_end[/code] are programatically overwritten
@export var lc_col_to_num_sel_color_button_properties: TweenParams
@export_subgroup("Transition to close number selector", "lc_num_sel_to_col_")
@export var lc_num_sel_to_col_num_selector_properties: TweenParams
## Colored Button [code]slide_start[/code], [code]slide_by_ratio[/code], and [code]scale_scale[/code] are programatically overwritten
@export var lc_num_sel_to_col_color_button_properties: TweenParams

@export_group("Arrow and Vase Animation Properties", "lc_")
@export var lc_arrow_animation_properties: TweenParams
@export var lc_vase_animation_properties: TweenParams

@export_group("Calculate Animation Properties", "lc_calc_")
@export var lc_calc_text_animation_duration: float
@export var lc_calc_minimum_delay_between_columns: float
@export var lc_calc_column_climb_delay: float
@export var lc_calc_final_score_shadow_color: Color
@export var lc_calc_final_score_shadow_final_size: int
@export var lc_calc_final_score_shadow_duration: float
@export var lc_calc_column_properties: TweenParams
@export var lc_calc_final_score_properties: TweenParams

@export_group("Clear Animation Properties", "lc_clear_")
@export var lc_clear_top_level_props_begin: TweenParams
@export var lc_clear_top_level_props_finish: TweenParams
@export var lc_clear_individual_clearable_props_1: TweenParams
@export var lc_clear_individual_clearable_props_2: TweenParams
@export var lc_clear_individual_clearable_props_3: TweenParams
@export var lc_clear_individual_clearable_props_4: TweenParams
@export var lc_clear_individual_clearable_props_5: TweenParams

@export_group("Confirmation Box Properties", "lc_confirmbox_")
@export var lc_confirmbox_confirmation_box: Control
@export var lc_confirmbox_open_properties: TweenParams
@export var lc_confirmbox_close_properties: TweenParams

@onready var main_manager = get_tree().current_scene
@onready var lost_cities = get_parent()

func animate_show_lc_num_selector( number_selector: Control, color_button: Control ) -> void:
    main_manager.lock_ui()
    var num_sel_container: PanelContainer = number_selector.get_node( "PanelContainer" ) as PanelContainer
    var num_sel_center: Vector2 = Vector2( num_sel_container.position + (num_sel_container.size / 2) )
    var color_center: Vector2 = Vector2( color_button.global_position + (color_button.size / 2) )
    var pos = num_sel_center - color_center
    var size_diff = num_sel_container.size / color_button.size

    lc_col_to_num_sel_color_button_properties.target_node = color_button
    lc_col_to_num_sel_color_button_properties.slide.end = pos
    lc_col_to_num_sel_color_button_properties.slide.by_ratio = false
    lc_col_to_num_sel_color_button_properties.scale.end = size_diff

    lc_col_to_num_sel_num_selector_properties.target_node = number_selector

    var tweens := []
    tweens.append( TweenController.universal_tween( lc_col_to_num_sel_color_button_properties ) )
    tweens.append( TweenController.universal_tween( lc_col_to_num_sel_num_selector_properties ) )
    await TweenController.wait_for_all( tweens )
    main_manager.try_unlock_ui()

func animate_hide_lc_num_selector( number_selector: Control, color_button: Control ) -> void:
    main_manager.lock_ui()
    var num_sel_container: PanelContainer = number_selector.get_node( "PanelContainer" ) as PanelContainer
    var num_sel_center: Vector2 = Vector2( num_sel_container.global_position + (num_sel_container.size / 2) )
    var color_center: Vector2 = Vector2( color_button.global_position + (color_button.size / 2) )
    var start_pos = num_sel_center - color_center
    var size_diff = num_sel_container.size / color_button.size

    lc_num_sel_to_col_color_button_properties.target_node = color_button
    lc_num_sel_to_col_color_button_properties.slide.start = start_pos
    lc_num_sel_to_col_color_button_properties.slide.by_ratio = false
    lc_num_sel_to_col_color_button_properties.scale.start = size_diff

    lc_num_sel_to_col_num_selector_properties.target_node = number_selector

    var tweens := []
    tweens.append( TweenController.universal_tween( lc_num_sel_to_col_num_selector_properties ) )
    tweens.append( TweenController.universal_tween( lc_num_sel_to_col_color_button_properties ) )
    await TweenController.wait_for_all( tweens )
    main_manager.try_unlock_ui()

func animate_shake_num_button( target_node: Control ) -> void:
    # lock_ui()
    var shake_params := lc_shake_tween_parameters.duplicate( true )
    shake_params.target_node = target_node
    shake_params.slide.duration = shake_params.slide.duration / lc_shake_repetitions
    await TweenController.universal_tween( shake_params, true, false ).finished

    for rep in (lc_shake_repetitions - 2):
        shake_params.slide.start = shake_params.slide.end
        shake_params.slide.end = - shake_params.slide.end
        await TweenController.universal_tween( shake_params, false, false ).finished

    shake_params.slide.start = target_node.offset_transform_position_ratio if shake_params.slide.by_ratio else target_node.offset_transform_position
    shake_params.slide.end = lc_shake_tween_parameters.slide.start
    await TweenController.universal_tween( shake_params, false, true ).finished

func _animate_calculate_button( target: Control ) -> Array:
    var tweens := []
    var params := lc_calc_column_properties.duplicate( true )
    params.target_node = target
    tweens.append( TweenController.universal_tween( params, true, false ) )
    tweens.append( TweenController.universal_tween( params.reset(), false, true ) )
    return tweens

func _animate_calculate_column( col: Array, count: int ) -> void:
    var zs := []
    var tweens := []
    for i in count:
        zs.append( col[i].z_index )
        col[i].z_index += 7
        tweens.append_array( _animate_calculate_button( col[i] ) )
        await get_tree().create_timer( lc_calc_column_climb_delay ).timeout

    await TweenController.wait_for_all( tweens )
    for j in count:
        col[j].z_index = zs[j]

func _animate_calculate_bridges( bridges: Array ) -> void:
    var zs := []
    var tweens := []
    for i in bridges.size():
        zs.append( bridges[i].z_index )
        bridges[i].z_index += 7
        tweens.append_array( _animate_calculate_button( bridges[i] ) )
        await get_tree().create_timer( lc_calc_column_climb_delay ).timeout

    await TweenController.wait_for_all( tweens )
    for j in bridges.size():
        bridges[j].z_index = zs[j]

func animate_calculate( data: Dictionary ) -> void:
    main_manager.lock_ui()

    await _animate_calculate_column( data["red_column"], data["red_highest_index"] + 1 )
    TweenController.tween_text( %LcRedScore, str( data["red_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_column( data["orange_column"], data["orange_highest_index"] + 1 )
    TweenController.tween_text( %LcOrangeScore, str( data["orange_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_column( data["yellow_column"], data["yellow_highest_index"] + 1 )
    TweenController.tween_text( %LcYellowScore, str( data["yellow_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_column( data["green_column"], data["green_highest_index"] + 1 )
    TweenController.tween_text( %LcGreenScore, str( data["green_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_column( data["blue_column"], data["blue_highest_index"] + 1 )
    TweenController.tween_text( %LcBlueScore, str( data["blue_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_column( data["purple_column"], data["purple_highest_index"] + 1 )
    TweenController.tween_text( %LcPurpleScore, str( data["purple_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_column( data["vase_column"], data["vase_highest_index"] + 1 )
    TweenController.tween_text( %LcVaseScore, str( data["vase_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_column( data["dice_column"], data["dice_highest_index"] + 1 )
    TweenController.tween_text( %LcDiceScore, str( data["dice_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( lc_calc_minimum_delay_between_columns ).timeout
    await _animate_calculate_bridges( data["bridges_column"] )
    TweenController.tween_text( %LcBridgeScore, str( data["bridges_points"] ), lc_calc_text_animation_duration )
    await get_tree().create_timer( 1.25 ).timeout

    var fscore = %LcFinalScore as Label
    lc_calc_final_score_properties.target_node = fscore
    var screen_center := position + size / 2
    var final_size := lc_calc_final_score_properties.target_node.global_position + (lc_calc_final_score_properties.target_node.size / 2)
    lc_calc_final_score_properties.slide.end = screen_center - final_size

    TweenController.tween_override_stylebox_shadow( fscore, lc_calc_final_score_shadow_color, lc_calc_final_score_shadow_final_size,
            lc_calc_final_score_shadow_duration )
    await TweenController.universal_tween( lc_calc_final_score_properties, true, false ).finished
    await TweenController.tween_text( fscore, str( data["total_points"] ), lc_calc_text_animation_duration * 3, "999" ).finished

    main_manager.set_input_blocker_connection(
            TweenController.tween_remove_override_stylebox_shadow.bind( fscore, lc_calc_final_score_shadow_final_size,
                    lc_calc_final_score_shadow_duration / 3 ) )
    main_manager.set_input_blocker_connection( _clean_up_post_calculate, false )

func _clean_up_post_calculate() -> void:
    await TweenController.universal_tween( lc_calc_final_score_properties.reset() ).finished
    main_manager.try_unlock_ui()

func animate_arrow_up( con: Control ) -> void:
    # lock_ui()
    var params := lc_arrow_animation_properties.duplicate( true )
    params.target_node = con

    await TweenController.universal_tween( params ).finished
    await TweenController.universal_tween( params.reset( false ) ).finished
# try_unlock_ui()

func animate_arrow_down( con: Control ) -> void:
    # lock_ui()
    var params := lc_arrow_animation_properties.duplicate( true )
    params.target_node = con
    params.slide.end *= -1

    await TweenController.universal_tween( params ).finished
    await TweenController.universal_tween( params.reset( false ) ).finished
# try_unlock_ui()

func animate_vase( vase: Control ) -> void:
    # lock_ui()
    var params := lc_vase_animation_properties.duplicate( true )
    params.target_node = vase

    await TweenController.universal_tween( params ).finished
    await TweenController.universal_tween( params.reset( false ) ).finished
# try_unlock_ui()

func open_lc_confirmbox() -> void:
    main_manager.lock_ui()
    var params := lc_confirmbox_open_properties.duplicate( true )
    params.target_node = lc_confirmbox_confirmation_box

    await TweenController.universal_tween( params ).finished
    main_manager.set_input_blocker_connection( close_lc_confirmbox )

func close_lc_confirmbox() -> void:
    main_manager.lock_ui()
    var params := lc_confirmbox_close_properties.duplicate( true )
    params.target_node = lc_confirmbox_confirmation_box

    await TweenController.universal_tween( params ).finished
    main_manager.try_unlock_ui()

func _perform_clear_animation_out() -> void:
    var all_clearables := get_tree().get_nodes_in_group( "LostCitiesClearable" )

    var tweens := []
    var tparams := lc_clear_top_level_props_begin.duplicate( true )
    tparams.target_node = main_manager.get_node( "TopInstanceContainer" )
    await TweenController.universal_tween( tparams, true, false ).finished

    for node in all_clearables:
        var cparams_1: TweenParams
        var cparams_2: TweenParams
        var cparams_3: TweenParams
        var cparams_4: TweenParams
        var cparams_5: TweenParams
        var tween_set: Array[TweenParams] = []

        cparams_1 = lc_clear_individual_clearable_props_1.duplicate( true )
        cparams_1.target_node = node

        tween_set.append( cparams_1 )

        if lc_clear_individual_clearable_props_2:
            cparams_2 = lc_clear_individual_clearable_props_2.duplicate( true )
            cparams_2.target_node = node
            tween_set.append( cparams_2 )

            if lc_clear_individual_clearable_props_3:
                cparams_3 = lc_clear_individual_clearable_props_3.duplicate( true )
                cparams_3.target_node = node
                tween_set.append( cparams_3 )

                if lc_clear_individual_clearable_props_4:
                    cparams_4 = lc_clear_individual_clearable_props_4.duplicate( true )
                    cparams_4.target_node = node
                    tween_set.append( cparams_4 )

                    if lc_clear_individual_clearable_props_5:
                        cparams_5 = lc_clear_individual_clearable_props_5.duplicate( true )
                        cparams_5.target_node = node
                        tween_set.append( cparams_5 )

        tween_set = TweenController.prepare_sequential_tweens( 0, true, tween_set )
        tweens.append_array( TweenController.execute_tween_set( tween_set, false ) )
    await TweenController.wait_for_all( tweens )

func _perform_clear_animation_in() -> void:
    var all_clearables := get_tree().get_nodes_in_group( "LostCitiesClearable" )

    var tweens := []
    var tween_sets_for_cleanup: Array[TweenParams] = []
    var tparams := lc_clear_top_level_props_finish.duplicate( true )
    tparams.target_node = main_manager.get_node( "TopInstanceContainer" )
    await TweenController.universal_tween( tparams ).finished

    for node in all_clearables:
        var cparams_1: TweenParams
        var cparams_2: TweenParams
        var cparams_3: TweenParams
        var cparams_4: TweenParams
        var cparams_5: TweenParams
        var tween_set: Array[TweenParams] = []

        cparams_1 = lc_clear_individual_clearable_props_1.duplicate( true )
        cparams_1.target_node = node

        tween_set.append( cparams_1.reset( false ) )

        if lc_clear_individual_clearable_props_2:
            cparams_2 = lc_clear_individual_clearable_props_2.duplicate( true )
            cparams_2.target_node = node
            tween_set.append( cparams_2 )

            if lc_clear_individual_clearable_props_3:
                cparams_3 = lc_clear_individual_clearable_props_3.duplicate( true )
                cparams_3.target_node = node
                tween_set.append( cparams_3 )

                if lc_clear_individual_clearable_props_4:
                    cparams_4 = lc_clear_individual_clearable_props_4.duplicate( true )
                    cparams_4.target_node = node
                    tween_set.append( cparams_4 )

                    if lc_clear_individual_clearable_props_5:
                        cparams_5 = lc_clear_individual_clearable_props_5.duplicate( true )
                        cparams_5.target_node = node
                        tween_set.append( cparams_5 )

        tween_sets_for_cleanup.append_array( tween_set )
        tween_set = TweenController.prepare_sequential_tweens( 0, true, tween_set )
        tweens.append_array( TweenController.execute_tween_set( tween_set ) )
    await TweenController.wait_for_all( tweens )

    for tween_params in tween_sets_for_cleanup:
        TweenController.cleanup_tween( tween_params )

func animate_lost_cities_clear() -> void:
    main_manager.lock_ui()
    await _perform_clear_animation_out()

    var all_clearables := get_tree().get_nodes_in_group( "LostCitiesClearable" )

    for con in all_clearables:
        # Bridges, vases and dice
        if con is ScribbleController:
            con.clear_scribbles()
        # Button which should have a label child
        elif con.get_node_or_null( "Label" ):
            con.get_node( "Label" ).text = ""
        # Score labels
        elif con is Label:
            con.text = ""
        else:
            push_error( "Unexpected control attempting to be cleared", con )

    await _perform_clear_animation_in()
    TweenController.print_all_tweens()
    main_manager.try_unlock_ui()
