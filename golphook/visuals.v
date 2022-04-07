module golphook

import valve
import utils
import offsets

pub fn visuals_on_frame() {
	mut app_ctx := unsafe { app() }
	ents := app_ctx.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team() && e.dormant() == false
	})

	for ent in ents {
		is_visible := check_ent_visible_by_mask(ent)
		if app_ctx.config.active_config.glow {
			visuals_glow(ent, is_visible)
		}
		if app_ctx.config.active_config.names {
			visuals_name(ent, is_visible)
		}
		if app_ctx.config.active_config.box {
			visuals_box(ent, is_visible)
		}
		if app_ctx.config.active_config.snapline {
			visuals_snapline(ent, is_visible)
		}
	}

	if app_ctx.config.active_config.watermark {
		visuals_watermark()
	}
	if app_ctx.config.active_config.indicator {
		indicators()
	}
	if app_ctx.config.active_config.fov_circle {
		fov_circle()
	}
}


pub fn visuals_watermark() {
	mut app_ctx := unsafe { app() }
	app_ctx.rnd_queue.push(new_text(utils.new_vec2(4, 4).vec_3(), "golphook v$app_ctx.v_mod.version", 12, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.watermark_color))
}

pub fn visuals_box(ent &valve.Entity, visible bool) {
	mut app_ctx := unsafe { app() }
	mut screen_pos ,box_height, box_width := calculate_box(ent, 0) or { return }
	screen_pos.x -=  box_width/2

	mut color := app_ctx.config.active_config.box_color_if_not_visible
	if visible {
		color = app_ctx.config.active_config.box_color_if_visible
	}
	app_ctx.rnd_queue.push(new_rectangle(screen_pos, box_height, box_width, 1, 0, color))
}

pub fn visuals_snapline(ent &valve.Entity, visible bool) {
	mut app_ctx := unsafe { app() }
	mut screen_pos ,_ ,_ := calculate_box(ent, 0) or { return }

	mut color := app_ctx.config.active_config.snapline_color_if_not_visible
	if visible {
		color = app_ctx.config.active_config.snapline_color_if_visible
	}
	app_ctx.rnd_queue.push(new_line(utils.new_vec2(app_ctx.wnd_width /2, app_ctx.wnd_height).vec_3(), screen_pos, 1, color))

}

pub fn visuals_name(ent &valve.Entity, visible bool) {
	mut app_ctx := unsafe { app() }
	mut screen_pos ,box_height, box_width := calculate_box(ent, (utils.distance_from(app_ctx.ent_cacher.local_player.origin(), ent.origin()) / 57)) or { return }

	mut p_info := valve.PlayerInfo{}
	rs := app_ctx.interfaces.cdll_int.get_player_info(app_ctx.ent_cacher.get_id(ent), &p_info)
	if !rs {
		return
	}
	mut text := p_info.player_name()

	mut color := app_ctx.config.active_config.names_color_if_not_visible
	if visible {
		color = app_ctx.config.active_config.names_color_if_visible
	}

	mut font := 12
	mut text_size := f32( (font * text.len)) * 0.57
	mut off := text_size / 2

	if text_size > box_width {
		font = int(((box_width/0.57) / text.len) + 1)
		if font <= 9 {
			font = 9
		}
		text_size = f32( (font * text.len)) * 0.57
		off = text_size / 2
	}

	app_ctx.rnd_queue.push(new_text(utils.new_vec2((screen_pos.y - box_height), screen_pos.x - off).vec_3(), text, u16(font), C.DT_LEFT | C.DT_NOCLIP, color))
}

pub fn calculate_box(withEnt &valve.Entity, andZOffset f32) ?(utils.Vec3, f32, f32) {
	mut app_ctx := unsafe { app() }
	pos := withEnt.bone(1) ?
	mut screen_pos := utils.new_vec3(0,0,0)
	mut res := app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
	if res != 0 { return error("failed to retreive screen pos") }

	mut head_pos := withEnt.bone(8) ?
	head_pos.z += 13 + andZOffset
	head_screen_pos := utils.new_vec3(0,0,0)
	res = app_ctx.interfaces.i_debug_overlay.screen_pos(head_pos, head_screen_pos)
	if res != 0 { return error("failed to retreive screen pos") }

	screen_pos.y += 3
	mut box_height := screen_pos.y - head_screen_pos.y
	box_width := box_height / 1.7

	return screen_pos, box_height, box_width
}

pub fn check_ent_visible_by_mask(ent &valve.Entity) bool {
	mut app_ctx := unsafe { app() }
	r := ent.spotted_by_mask() & (1 << ( app_ctx.ent_cacher.local_player_id - 1))
	if r > 0 {
		return true
	}
	return false
}

pub fn fov_circle() {
	mut app_ctx := unsafe { app() }
	app_ctx.rnd_queue.push(new_circle(utils.new_vec2(app_ctx.wnd_width / 2, app_ctx.wnd_height / 2).vec_3(), 1, f32(app_ctx.engine.fov), app_ctx.config.active_config.fov_circle_color))
}

pub fn indicators() {
	mut app_ctx := unsafe { app() }

	mut indicators_cnt := 0

	app_ctx.rnd_queue.push(new_text(utils.new_vec2(((app_ctx.wnd_height / 2) + 20), (app_ctx.wnd_width / 2)).vec_3(), "Fov: ${f32(app_ctx.engine.fov / 10)}", 12, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.indicator_color_if_on))

	if app_ctx.engine.do_a_shoot {
		indicators_cnt++
		app_ctx.rnd_queue.push(new_text(utils.new_vec2(((app_ctx.wnd_height / 2) + 20) + (indicators_cnt*10), (app_ctx.wnd_width / 2)).vec_3(), "Automatic fire", 12, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.indicator_color_if_on))
	}

	if app_ctx.engine.do_force_bone {
		indicators_cnt++
		app_ctx.rnd_queue.push(new_text(utils.new_vec2(((app_ctx.wnd_height / 2) + 20) + (indicators_cnt*10), (app_ctx.wnd_width / 2)).vec_3(), "Force body", 12, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.indicator_color_if_on))
	}

}

pub fn visuals_glow(ent &valve.Entity, visible bool) {
	mut app_ctx := unsafe { app() }
	glow_object_manager := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.glow_object_manager))
	glow_index := ent.glow_index()

	mut color := app_ctx.config.active_config.glow_color_if_not_visible
	if visible {
		color = app_ctx.config.active_config.glow_color_if_visible
	}

	mut glow_colorf := &utils.ColorRgbaF(glow_object_manager + usize(glow_index * 0x38) + 0x8)
	unsafe { *glow_colorf = color.rgbaf()}
	mut render_when_ocluded := &bool(glow_object_manager + usize(glow_index * 0x38) + 0x27)
	unsafe { *render_when_ocluded = true }
	mut render_when_unocluded := &bool(glow_object_manager + usize(glow_index * 0x38) + 0x28)
	unsafe { *render_when_unocluded = true }
}
