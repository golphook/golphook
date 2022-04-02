module golphook

import valve
import utils

pub fn visuals_on_frame() {
	mut app_ctx := unsafe { app() }
	ents := app_ctx.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team() && e.dormant()
	})
	for ent in ents {
		id := app_ctx.ent_cacher.get_id(ent)
		visuals_name(ent)
		visuals_box(ent)
		visuals_snapline(ent)
		//visuals_bones_id(ent)
	}
	visuals_watermark()
}


pub fn visuals_watermark() {
	mut app_ctx := unsafe { app() }
	app_ctx.rnd_queue.push(new_text(utils.new_vec2(4, 4).vec_3(), "golphook v$app_ctx.v_mod.version", 12, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
}

pub fn visuals_namess() {
	mut app_ctx := unsafe { app() }
	ents := app_ctx.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team()
	})
	for ent in ents {
		pos := ent.bone(7) or { return }
		screen_pos := utils.new_vec3(0,0,0)
		res := app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
		if res == 0 {
			app_ctx.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "ent: ${f32(ent.health())}", 12, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
		}
	}
}

struct BoneLink {
	from_bone usize
	to_bone usize
}

pub fn visuals_bones_id(ent &valve.Entity) {
	bones := [usize(0), 8, 9, 6, 5]
	mut app_ctx := unsafe { app() }
	for b in bones {
		mut pos := ent.bone(b) or { return }
		mut screen_pos := utils.new_vec3(0,0,0)
		mut res := app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
		if res == 0 {
			app_ctx.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "${f32(b)}", 10, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))

		}
	}
}

pub fn visuals_bones() {

	bones := [
		BoneLink{from_bone: 0, to_bone: 75},
		BoneLink{from_bone: 0, to_bone: 68},

		BoneLink{from_bone: 75, to_bone: 76},
		BoneLink{from_bone: 68, to_bone: 69},

		BoneLink{from_bone: 0, to_bone: 6},

		BoneLink{from_bone: 6, to_bone: 40},
		BoneLink{from_bone: 6, to_bone: 12},

		BoneLink{from_bone: 40, to_bone: 41},
		BoneLink{from_bone: 12, to_bone: 13},

		BoneLink{from_bone: 41, to_bone: 55},
		BoneLink{from_bone: 13, to_bone: 14},
	]!

	mut app_ctx := unsafe { app() }
	ents := app_ctx.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team()
	})
	for ent in ents {
		for b in bones {
			mut pos := ent.bone(b.from_bone) or { return }
			mut pos2 := ent.bone(b.to_bone) or { return }
			mut screen_pos2 := utils.new_vec3(0,0,0)
			mut screen_pos := utils.new_vec3(0,0,0)
			res := app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
			res2 := app_ctx.interfaces.i_debug_overlay.screen_pos(pos2, screen_pos2)
			if res == 0 && res2 == 0  {
				app_ctx.rnd_queue.push(new_line(screen_pos, screen_pos2, 1, utils.color_rbga(255,255,255,255)))
			}
		}
	}
	// for ent in ents {
	// 	for b in 0..85 {
	// 		mut pos := ent.bone(b)
	// 		mut screen_pos := utils.new_vec3(0,0,0)
	// 		mut res := app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
	// 		if res == 0 {
	// 			app_ctx.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "${f32(b)}", 10, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	//
	// 		}
	// 	}
	// }
}

pub fn visuals_distance() {

	mut app_ctx := unsafe { app() }
	ents := app_ctx.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team()
	})

	for ent in ents {
		pos := ent.origin()
		screen_pos := utils.new_vec3(0,0,0)
		res := app_ctx.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
		if res == 0 {
			dist := utils.distance_from(app_ctx.ent_cacher.local_player.origin(), pos)
			C.printf(c"%f \n", dist)
			//font := u16(dist / 10)
			font := u16(12)
			app_ctx.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "dis: ${f32(int(dist))}", font, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
		}
	}
}


pub fn visuals_box(ent &valve.Entity) {
	mut app_ctx := unsafe { app() }
	mut screen_pos ,box_height, box_width := calculate_box(ent, 0) or { return }
	screen_pos.x -=  box_width/2
	app_ctx.rnd_queue.push(new_rectangle(screen_pos, box_height, box_width, 1, 0, utils.color_rbga(255,255,255,255)))
}

pub fn visuals_snapline(ent &valve.Entity) {
	mut app_ctx := unsafe { app() }
	mut screen_pos ,_ ,_ := calculate_box(ent, 0) or { return }
	app_ctx.rnd_queue.push(new_line(utils.new_vec2(app_ctx.wnd_width /2, app_ctx.wnd_height).vec_3(), screen_pos, 1, utils.color_rbga(255,255,255,255)))
}

pub fn visuals_name(ent &valve.Entity) {
	mut app_ctx := unsafe { app() }
	mut screen_pos ,box_height, box_width := calculate_box(ent, (utils.distance_from(app_ctx.ent_cacher.local_player.origin(), ent.origin()) / 57)) or { return }

	mut p_info := valve.PlayerInfo{}
	rs := app_ctx.interfaces.cdll_int.get_player_info(app_ctx.ent_cacher.get_id(ent), &p_info)
	if !rs {
		return
	}

	text := p_info.player_name()

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

	app_ctx.rnd_queue.push(new_text(utils.new_vec2((screen_pos.y - box_height), screen_pos.x - off).vec_3(), text, u16(font), C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	//	app_ctx.rnd_queue.push(new_text(utils.new_vec2((screen_pos.y - box_height), screen_pos.x + (box_width + 30)).vec_3(), "font: ${f32(int(font))}", 9, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
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
