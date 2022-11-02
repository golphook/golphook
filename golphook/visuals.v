module golphook

import valve
import utils

struct BoxData {
	screen_pos utils.Vec3
	height f32
	width f32
}

struct Visuals {
pub mut:
	bones_to_be_visible_visuals []usize = [usize(8), 42, 12, 79, 72, 71, 78, 42, 43, 11, 12, 77, 70]

	current_ent &valve.Player = unsafe { nil }
	current_ent_is_visible bool
	current_ent_box BoxData
}

pub fn (mut v Visuals) on_frame() {

	$if prod { C.VMProtectBeginMutation(c"visual.on_frame") }

	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter_player(fn (e &valve.Player, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team() && e.dormant() == false
	})

	for ent in ents {

		v.current_ent = unsafe { ent }

		is_visible, _ := i_can_see(ent, v.bones_to_be_visible_visuals)

		v.current_ent_is_visible = is_visible
		v.current_ent_box = v.calculate_box(0) or { continue }

		if app_ctx.config.active_config.box {
			v.box()
		}
	}

	$if prod { C.VMProtectEnd() }
}

pub fn (mut v Visuals) on_end_scene() {

	$if prod { C.VMProtectBeginMutation(c"visuals.on_end_scene") }

	mut app_ctx := unsafe { app() }

	if app_ctx.config.active_config.watermark {
		v.watermark()
	}

	$if prod { C.VMProtectEnd() }
}


pub fn (mut v Visuals) box() {

	$if prod { C.VMProtectBeginMutation(c"visuals.box") }

	mut app_ctx := unsafe { app() }

	mut screen_pos := v.current_ent_box.screen_pos
	screen_pos.x -=  v.current_ent_box.width / 2

	mut color := app_ctx.config.active_config.box_color_if_not_visible
	if v.current_ent_is_visible {
		color = app_ctx.config.active_config.box_color_if_visible
	}
	app_ctx.rnd_queue.push(new_rectangle(screen_pos, v.current_ent_box.height, v.current_ent_box.width, 1, 0, color))

	$if prod { C.VMProtectEnd() }
}

pub fn (mut v Visuals) watermark() {

	$if prod { C.VMProtectBeginMutation(c"visuals.watermark") }

	mut app_ctx := unsafe { app() }
	app_ctx.rnd_queue.push(new_text(utils.new_vec2(4, 4).vec_3(), "golphook v$app_ctx.v_mod.version", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.watermark_color))

	$if prod { C.VMProtectEnd() }
}

pub fn (mut v Visuals) calculate_box(with_z_offset f32) ?BoxData {

	$if prod { C.VMProtectBeginMutation(c"visuals.calculate_box") }

	mut app_ctx := unsafe { app() }

	pos := v.current_ent.bone(1) ?
	mut screen_pos := utils.new_vec3(0,0,0)

	if !app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos) {
		return error("failed to retreive screen pos")
	}

	mut head_pos := v.current_ent.bone(8) ?
	head_pos.z += 13 + with_z_offset
	head_screen_pos := utils.new_vec3(0,0,0)

	if !app_ctx.interfaces.i_debug_overlay.screen_pos(head_pos, head_screen_pos) {
		return error("failed to retreive screen pos")
	}

	screen_pos.y += 3
	mut box_height := screen_pos.y - head_screen_pos.y
	box_width := box_height / 1.7
	
	$if prod { C.VMProtectEnd() }

	return BoxData{screen_pos: screen_pos, height: box_height, width: box_width}
}
