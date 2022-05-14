module golphook

import valve
import utils
import offsets

struct BoxData {
	screen_pos utils.Vec3
	height f32
	width f32
}

struct Visuals {
pub mut:
	bones_to_be_visible_visuals []usize = [usize(8), 42, 12, 79, 72, 71, 78, 42, 43, 11, 12, 77, 70]

	current_ent &valve.Player = 0
	current_ent_is_visible bool
	current_ent_box BoxData
}

pub fn (mut v Visuals) on_frame() {
	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter_player(fn (e &valve.Player, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team() && e.dormant() == false
	})

	for ent in ents {

		v.current_ent = unsafe { ent }

		is_visible, _ := i_can_see(ent, v.bones_to_be_visible_visuals)

		v.current_ent_is_visible = is_visible
		v.current_ent_box = v.calculate_box(0) or { continue }

		//v.bones_id()
		//v.show_hitbox()

		if app_ctx.config.active_config.glow {
			v.glow()
		}
		if app_ctx.config.active_config.names {
			v.name()
		}
		if app_ctx.config.active_config.box {
			v.box()
		}
		if app_ctx.config.active_config.snapline {
			v.snapline()
		}
		if app_ctx.config.active_config.weapon_name {
			v.weapon()
		}

		if app_ctx.config.active_config.radar {
			v.radar()
		}
	}

	if app_ctx.config.active_config.indicator {
		v.indicators()
	}
	if app_ctx.config.active_config.fov_circle {
		v.fov_circle()
	}
}

pub fn (mut v Visuals) on_end_scene() {
	mut app_ctx := unsafe { app() }
	if app_ctx.config.active_config.watermark {
		v.watermark()
	}
}

pub fn (mut v Visuals) glow() {
	mut app_ctx := unsafe { app() }

	glow_object_manager := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.glow_object_manager))
	glow_index := v.current_ent.glow_index()

	mut color := app_ctx.config.active_config.glow_color_if_not_visible
	if v.current_ent_is_visible {
		color = app_ctx.config.active_config.glow_color_if_visible
	}

	mut glow_colorf := &utils.ColorRgbaF(glow_object_manager + usize(glow_index * 0x38) + 0x8)
	unsafe { *glow_colorf = color.rgbaf()}
	mut render_when_ocluded := &bool(glow_object_manager + usize(glow_index * 0x38) + 0x27)
	unsafe { *render_when_ocluded = false }
	mut render_when_unocluded := &bool(glow_object_manager + usize(glow_index * 0x38) + 0x28)
	unsafe { *render_when_unocluded = true }
}

pub fn (mut v Visuals) name() {
	mut app_ctx := unsafe { app() }

	mut box_data := v.calculate_box(v.adjust_text_spacing_by_zoom()) or { return }

	mut p_info := valve.PlayerInfo{}

	if !app_ctx.interfaces.cdll_int.get_player_info(v.current_ent.index(), &p_info) {
		return
	}

	mut text := p_info.player_name()
	if app_ctx.config.active_config.hp {
		text = "$text (${f32(v.current_ent.health())})"
	}

	mut color := app_ctx.config.active_config.names_color_if_not_visible
	if v.current_ent_is_visible {
		color = app_ctx.config.active_config.names_color_if_visible
	}

	font, off := calculate_text(12, text.len, box_data.width)

	app_ctx.rnd_queue.push(new_text(utils.new_vec2((box_data.screen_pos.y - box_data.height), box_data.screen_pos.x - off).vec_3(), text, u16(font), false, false, C.DT_LEFT | C.DT_NOCLIP, color))
}

pub fn (mut v Visuals) box() {
	mut app_ctx := unsafe { app() }

	mut screen_pos := v.current_ent_box.screen_pos
	screen_pos.x -=  v.current_ent_box.width / 2

	mut color := app_ctx.config.active_config.box_color_if_not_visible
	if v.current_ent_is_visible {
		color = app_ctx.config.active_config.box_color_if_visible
	}
	app_ctx.rnd_queue.push(new_rectangle(screen_pos, v.current_ent_box.height, v.current_ent_box.width, 1, 0, color))
}

pub fn (mut v Visuals) snapline() {
	mut app_ctx := unsafe { app() }

	mut color := app_ctx.config.active_config.snapline_color_if_not_visible
	if v.current_ent_is_visible {
		color = app_ctx.config.active_config.snapline_color_if_visible
	}
	app_ctx.rnd_queue.push(new_line(utils.new_vec2(app_ctx.wnd_width /2, app_ctx.wnd_height).vec_3(), v.current_ent_box.screen_pos, 1, color))
}

pub fn (mut v Visuals) weapon() {
	mut app_ctx := unsafe { app() }

	mut box_data := v.calculate_box(v.adjust_text_spacing_by_zoom()) or { return }

	weapon := ent_weapon(v.current_ent) or { return }
	weapon_data := app_ctx.interfaces.i_weapon_system.weapon_data(weapon.definition_index().get())

	mut text := weapon_data.name()

	if app_ctx.config.active_config.weapon_clip {
		if weapon.clip1() != -1 {
			text = "$text (${f32(weapon.clip1())})"
		}
	}

	mut color := app_ctx.config.active_config.weapon_name_color_if_not_visible
	if v.current_ent_is_visible {
		color = app_ctx.config.active_config.weapon_name_color_if_visible
	}

	font, off := calculate_text(12, text.len, box_data.width)

	app_ctx.rnd_queue.push(new_text(utils.new_vec2((box_data.screen_pos.y + 2), box_data.screen_pos.x - off).vec_3(), text, u16(font), false, false, C.DT_LEFT | C.DT_NOCLIP, color))
}

pub fn (mut v Visuals) indicators() {
	mut app_ctx := unsafe { app() }

	if !app_ctx.ent_cacher.local_player.is_alive() {
		return
	}

	mut indicators_cnt := 0
	app_ctx.rnd_queue.push(new_text(utils.new_vec2(((app_ctx.wnd_height / 2) + 20), (app_ctx.wnd_width / 2)).vec_3(), "Fov: ${app_ctx.engine.fov}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.indicator_color_if_off))

	if app_ctx.engine.do_a_shoot {
		indicators_cnt++
		app_ctx.rnd_queue.push(new_text(utils.new_vec2(((app_ctx.wnd_height / 2) + 20) + (indicators_cnt*10), (app_ctx.wnd_width / 2)).vec_3(), "Automatic fire", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.indicator_color_if_on))
	}

	if app_ctx.engine.do_force_awal {
		indicators_cnt++
		app_ctx.rnd_queue.push(new_text(utils.new_vec2(((app_ctx.wnd_height / 2) + 20) + (indicators_cnt*10), (app_ctx.wnd_width / 2)).vec_3(), "No wall check", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.indicator_color_if_on))
	}

	if app_ctx.engine.do_force_bone {
		indicators_cnt++

		bone_str := match app_ctx.config.active_config.engine_force_bone_id {
			8 { "head" }
			5 { "body" }
			0 { "pelvis" }
			else { "bone" }
		}

		app_ctx.rnd_queue.push(new_text(utils.new_vec2(((app_ctx.wnd_height / 2) + 20) + (indicators_cnt*10), (app_ctx.wnd_width / 2)).vec_3(), "Force $bone_str", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.indicator_color_if_on))
	}
}

pub fn (mut v Visuals) fov_circle() {
	mut app_ctx := unsafe { app() }

	if !app_ctx.ent_cacher.local_player.is_alive() {
		return
	}

	app_ctx.rnd_queue.push(new_circle(utils.new_vec2(app_ctx.wnd_width / 2, app_ctx.wnd_height / 2).vec_3(), 1, f32(app_ctx.engine.fov), app_ctx.config.active_config.fov_circle_color))
}

pub fn (mut v Visuals) radar() {
	v.current_ent.spotted().set(true)
}

pub fn (mut v Visuals) watermark() {
	mut app_ctx := unsafe { app() }
	app_ctx.rnd_queue.push(new_text(utils.new_vec2(4, 4).vec_3(), "golphook v$app_ctx.v_mod.version", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.watermark_color))

}

// fn touch(a utils.Vec2, r1 f32, b utils.Vec2, r2 f32) (f32, f32) {
//
// 	d_sq := (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
// 	rad_sum_sq := (r1 + r2) * (r1 + r2)
//
// 	return d_sq, rad_sum_sq
//
// }
//
// pub fn (mut v Visuals) show_hitbox() {
// 	bones := [usize(0), 8, 9, 6, 5]
//  	mut app_ctx := unsafe { app() }
//  	for b in bones {
//  		mut pos := v.current_ent.bone(b) or { return }
// 		mut box_data := v.calculate_box((utils.distance_from(app_ctx.ent_cacher.local_player.origin(), v.current_ent.origin()) / 57)) or { return }
//  		mut screen_pos := utils.new_vec3(0,0,0)
//  		if app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos) {
//
// 			mut diviser := f32(10)
//
// 			match b {
// 				0 { diviser = 8 }
// 				8 { diviser = 12 }
// 				9 { diviser = 11 }
// 				6 { diviser = 8 }
// 				5 { diviser = 8 }
// 				else { diviser = 10 }
// 			}
//
// 			//app_ctx.rnd_queue.push(new_circle(utils.new_vec2(screen_pos.x, screen_pos.y).vec_3(), 1, f32(box_data.width / diviser), app_ctx.config.active_config.fov_circle_color))
// 			a, c := touch(utils.new_vec2(app_ctx.wnd_width / 2, app_ctx.wnd_height / 2), f32(app_ctx.engine.fov), utils.new_vec2(screen_pos.x, screen_pos.y), f32(box_data.width / diviser))
// 			//C.printf(c"%d - %f %f\n", b, a, c)
// 			ff := if a < c {
// 				true
// 			} else {
// 				false
// 			}
// 			//s, _, k := i_can_see_(v.current_ent, [usize(0), 8, 9, 6, 5], 5)
// 			//app_ctx.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "${s}", u16(10), false, false, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
// 		}
//  	}
// }
//
// pub fn (mut v Visuals) bones_id() {
//  	// bones := [usize(0), 8, 9, 6, 5, 87, 82, 78, 73, 41, 12]
// 	bones := [usize(8), 42, 12, 79, 72, 71, 78, 42, 43, 11, 12, 77, 70]
//  	mut app_ctx := unsafe { app() }
//  	for b in bones {
//  		mut pos := v.current_ent.bone(b) or { return }
// 		mut box_data := v.calculate_box((utils.distance_from(app_ctx.ent_cacher.local_player.origin(), v.current_ent.origin()) / 57)) or { return }
//  		mut screen_pos := utils.new_vec3(0,0,0)
//  		if app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos) {
// 			app_ctx.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "${f32(b)}", u16(10), false, false, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
//
// 			// mut diviser := f32(10)
// 			//
// 			// match b {
// 			// 	0 { diviser = 7 }
// 			// 	8 { diviser = 11 }
// 			// 	9 { diviser = 10 }
// 			// 	6 { diviser = 7 }
// 			// 	5 { diviser = 7 }
// 			// 	else { diviser = 10 }
// 			// }
// 			//
// 			// app_ctx.rnd_queue.push(new_circle(utils.new_vec2(screen_pos.x, screen_pos.y).vec_3(), 1, f32(box_width / diviser), app_ctx.config.active_config.fov_circle_color))
//
// 		}
//  	}
// }

pub fn (mut v Visuals) calculate_box(with_z_offset f32) ?BoxData {
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

	return BoxData{screen_pos: screen_pos, height: box_height, width: box_width}
}

pub fn (mut v Visuals) adjust_text_spacing_by_zoom() f32 {
 	mut app_ctx := unsafe { app() }

	dist := utils.distance_from(app_ctx.ent_cacher.local_player.origin(), v.current_ent.origin())

	if !app_ctx.ent_cacher.local_player.is_scoped() {
		return dist / 67
	}
	mut r := 1
	weapon := ent_weapon(app_ctx.ent_cacher.local_player) or { return dist / r}
 	r += 67 * (weapon.zoom_level() + 1)

	return dist / r
}

pub fn calculate_text(with_font int, with_text_len int, and_max_width f32) (u16, f32) {
	mut font := with_font
	mut text_size := f32( (font * with_text_len)) * 0.57
	mut off := text_size / 2

	if text_size > and_max_width {
		font = int(((and_max_width/0.57) / with_text_len) + 1)
		if font <= 9 {
			font = 9
		}
		text_size = f32( (font * with_text_len)) * 0.57
		off = text_size / 2
	}
	return u16(font), off
}
