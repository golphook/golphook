module golphook

import utils
import valve
import math
import offsets

struct Bone_t {
pub mut:
	ent &valve.Player = unsafe { nil }

	id int

	pos           utils.Vec3
	pos_on_screen utils.Vec3

	is_in_fov  bool
	is_visible bool

	distance_to_crosshair f64
}

pub fn (mut b Bone_t) fill_pos() ?u8 {
	$if prod { C.VMProtectBeginMutation(c"engine.bone.fill_pos") }

	mut app_ctx := unsafe { app() }

	mut bone_pos := b.ent.bone(usize(b.id)) or { return none }

	if !app_ctx.interfaces.i_debug_overlay.screen_pos(bone_pos, &b.pos_on_screen) {
		return none
	}

	b.pos = bone_pos
	
	$if prod { C.VMProtectEnd() }

	return 0
}

pub fn (mut b Bone_t) is_in_fov() bool {
	$if prod { C.VMProtectBeginMutation(c"engine.bone.is_in_fov") }

	mut app_ctx := unsafe { app() }

	if b.pos_on_screen.x > app_ctx.wnd_width ||  b.pos_on_screen.x < 0 || b.pos_on_screen.y > app_ctx.wnd_height || b.pos_on_screen.y < 0 {
		return false
	}

	m := math.abs(b.pos_on_screen.x - (app_ctx.wnd_width / 2))
	d := math.abs(b.pos_on_screen.y - (app_ctx.wnd_height / 2))

	r := math.sqrt((m * m) + (d * d))

	b.distance_to_crosshair = r
	if r < app_ctx.engine.fov {
		b.is_in_fov = true
		return true
	}

	b.is_in_fov = false

	$if prod { C.VMProtectEnd() }
	return false
}

pub fn (mut b Bone_t) get_best_visible_pos() ?u8 {
	$if prod { C.VMProtectBeginMutation(c"engine.bone.get_best_visible_pos") }

	mut app_ctx := unsafe { app() }

	weap_cfg_id := app_ctx.engine.current_weapon

	mut laf := f32(0)
	mut egs := f32(0)

	if app_ctx.config.active_config.engine_cfgs_by_weap[weap_cfg_id].engine_vhv_mode {
		laf = app_ctx.config.active_config.engine_cfgs_by_weap[weap_cfg_id].engine_vhv_aw_factor
		egs = app_ctx.config.active_config.engine_cfgs_by_weap[weap_cfg_id].engine_vhv_egs_factor
	}

	match b.id {
		8 {
			egs *= 0.60 // reduce scale for head
		}
		else {}
	}

	for o in 0 .. 4 {
		mut to_bone := b.pos
		mut from_local_eye := app_ctx.ent_cacher.local_player.eye_pos()
		match o {
			0 {
				to_bone.x += egs
				from_local_eye.x += laf
			}
			1 {
				to_bone.x -= egs
				from_local_eye.x -= laf
			}
			2 {
				to_bone.y += egs
				from_local_eye.y += laf
			}
			3 {
				to_bone.y -= egs
				from_local_eye.y -= laf
			}
			else {}
		}

		tr := trace_from_to_pos(from_local_eye, to_bone)

		if tr.hit_entity == voidptr(b.ent) {
			if !app_ctx.interfaces.i_debug_overlay.screen_pos(to_bone, &b.pos_on_screen) {
				return none
			}
			b.is_visible = true
			b.pos = to_bone
			return 0
		}
	}
	b.is_visible = false
	
	if app_ctx.engine.do_force_awal {
		b.is_visible = true
	}

	$if prod { C.VMProtectEnd() }

	return 0
}

struct Target {
pub mut:
	ent   &valve.Player = unsafe { nil }
	bones []Bone_t
	best_bone Bone_t
}

pub fn (mut t Target) get_bones(with_bones_ids []int) {
	$if prod { C.VMProtectBeginMutation(c"engine.target.get_bones") }

	mut bone := Bone_t{}

	for b in with_bones_ids {
		bone = Bone_t{
			ent: t.ent
			id: b
		}

		bone.fill_pos() or { continue }
		
		bone.get_best_visible_pos() or { continue }
		bone.is_in_fov()
		if bone.is_in_fov() {
			t.bones << bone
		}
	}
	$if prod { C.VMProtectEnd() }
}

pub fn (mut t Target) get_best_bone() {
	$if prod { C.VMProtectBeginMutation(c"engine.target.get_best_bones") }

	mut app_ctx := unsafe { app() }

	weap_cfg_id := app_ctx.engine.current_weapon
	pref_bone := app_ctx.config.active_config.engine_cfgs_by_weap[weap_cfg_id].engine_pref_bone_id
	force_bone := app_ctx.config.active_config.engine_cfgs_by_weap[weap_cfg_id].engine_force_bone_id 

	t.best_bone = Bone_t{id:123, distance_to_crosshair: 6670}

	for b in t.bones {
		if !b.is_visible {
			continue
		}
		if b.distance_to_crosshair < t.best_bone.distance_to_crosshair || b.id == pref_bone || b.id == force_bone {
		
			if t.best_bone.id == pref_bone || (t.best_bone.id == force_bone && app_ctx.engine.do_force_bone) { return }

			if t.best_bone.id != pref_bone {
				t.best_bone = b
			}

			if t.best_bone.id != force_bone && app_ctx.engine.do_force_bone {
				t.best_bone = b
			}

		}

	}

	$if prod { C.VMProtectEnd() }
}

// get closest or get prefered if in fov

struct EngineBeta {
pub mut:
	do_a_shoot    bool
	do_force_bone bool
	do_force_awal bool

	targeted_entities []Target

	fov f32

	is_spraying bool

	selected_weap_in_menu int
	current_weapon int
}

pub fn (mut e EngineBeta) on_frame() {
	$if prod { C.VMProtectBeginMutation(c"engine.on_frame") }

	mut app_ctx := unsafe { app() }

	if !app_ctx.config.active_config.engine  {
		return
	}

	my_weapon := ent_weapon(app_ctx.ent_cacher.local_player) or { return }

	e.current_weapon = match valve.ItemDefinitionIndex(my_weapon.definition_index().get()) {
		.weapon_deagle { 1 }
		.weapon_awp { 2 }
		.weapon_ssg08 { 3 }
		else { 0 }
	}

	mut force_attack := utils.Value<int>{ ptr: utils.get_val_offset<int>(app_ctx.h_client, offsets.db.signatures.force_attack) }

	if force_attack.get() == 4 {
		e.is_spraying = false
	}

	if force_attack.get() == 5 {
		e.is_spraying = true
	}

	e.fov = app_ctx.config.active_config.fov

	e.handle_keys()

	if app_ctx.config.active_config.engine_adjust_fov_scope {
		if app_ctx.ent_cacher.local_player.is_scoped() {
			e.adjust_fov_by_zoom()
		}
	}	

	if e.do_a_shoot {
	
		if e.is_spraying {
			return
		}

		if !can_shoot() {
			return
		}

		e.targeted_entities.clear()
		e.collect_targets()

		if e.targeted_entities.len == 0 { return }

		mut best_target := e.targeted_entities.first()

		for t in e.targeted_entities {

			if t.best_bone.distance_to_crosshair < best_target.best_bone.distance_to_crosshair {
				best_target = t
			}
		}

		e.aim_at(best_target)
		force_attack.set(6)
		e.is_spraying = true

		/*
		mut tt := best_target.best_bone.pos_on_screen
		tt.x += 2
		app_ctx.rnd_queue.push(new_line(best_target.best_bone.pos_on_screen, tt, 1, utils.color_rbga<u8>(255, 255, 255, 255)))*/

	}

	$if prod { C.VMProtectEnd() }	
}

pub fn (mut e EngineBeta) collect_targets() {
	$if prod { C.VMProtectBeginMutation(c"engine.collect_target") }

	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter_player(fn (e &valve.Player, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team() && e.dormant() == false
	})

	mut bones_list := app_ctx.config.active_config.engine_cfgs_by_weap[e.current_weapon].engine_bones_list.clone()
	if e.do_force_bone {
		bones_list = bones_list.filter(it == app_ctx.config.active_config.engine_cfgs_by_weap[e.current_weapon].engine_force_bone_id)
	}

	for ent in ents {
		mut target := Target{
			ent: unsafe { ent }
		}

		target.get_bones(bones_list)
		target.get_best_bone()

		if target.bones.len != 0 && target.best_bone.id != 123 {
			e.targeted_entities << target
		}
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut e EngineBeta) handle_keys() {

	$if prod { C.VMProtectBeginMutation(c"engine.handle_keys") }

	mut app_ctx := unsafe { app() }


	if !app_ctx.config.active_config.engine_automatic_fire_key_toggle {
		e.do_a_shoot = false
	}

	if !app_ctx.config.active_config.engine_force_bone_key_toggle {
		e.do_force_bone = false
	}

	if !app_ctx.config.active_config.engine_force_awall_key_toggle {
		e.do_force_awal = false
	}


	if utils.get_key(app_ctx.config.active_config.engine_force_awall_key, app_ctx.config.active_config.engine_force_awall_key_toggle) {
		e.do_force_awal = !e.do_force_awal
	}

	if utils.get_key(app_ctx.config.active_config.engine_force_bone_key, app_ctx.config.active_config.engine_force_bone_key_toggle) {
		e.do_force_bone = !e.do_force_bone
	}

	if utils.get_key(app_ctx.config.active_config.engine_automatic_fire_key, app_ctx.config.active_config.engine_automatic_fire_key_toggle) {
		e.do_a_shoot = !e.do_a_shoot
	}

	$if prod { C.VMProtectEnd() }
}

// most beautiful copy pasta from gh
fn (e &EngineBeta) aim_at(ent Target) {

	$if prod { C.VMProtectBeginMutation(c"engine.aim_at") }

	mut app_ctx := unsafe { app() }

	local_player_eye_pos := app_ctx.ent_cacher.local_player.eye_pos()
	mut target_bone_pos := ent.best_bone.pos 

	mut angle_out := utils.new_angle(0,0,0)

	delta_vec := utils.new_vec3(target_bone_pos.x - local_player_eye_pos.x , target_bone_pos.y - local_player_eye_pos.y, target_bone_pos.z - local_player_eye_pos.z)
	delta_vec_lenght := math.sqrt(delta_vec.x * delta_vec.x + delta_vec.y * delta_vec.y + delta_vec.z * delta_vec.z)

	pitch := -math.asin(delta_vec.z / delta_vec_lenght) * (180 / math.pi)
	yaw := math.atan2(delta_vec.y, delta_vec.x) * (180 / math.pi)

	if pitch >= -89 && pitch <= 89 && yaw >= -180 && yaw <= 180 {
		angle_out.pitch = f32(pitch)
		angle_out.yaw = f32(yaw)
	}

	app_ctx.interfaces.cdll_int.set_view_angle(&angle_out)

	$if prod { C.VMProtectEnd() }
}

pub fn can_shoot() bool {

	$if prod { C.VMProtectBeginMutation(c"engine.can_shoot") }

	mut app_ctx := unsafe { app() }

	weapon := ent_weapon(app_ctx.ent_cacher.local_player) or { return false }

	if weapon.in_reload() || weapon.clip1() <= 0 {
		return false
	}
	
	if app_ctx.ent_cacher.local_player.next_attack() > app_ctx.interfaces.c_global_vars.curtime {
		return false
	}

	$if prod { C.VMProtectEnd() }

	return weapon.next_primary_attack() <= app_ctx.interfaces.c_global_vars.curtime

}

pub fn (mut e EngineBeta) adjust_fov_by_zoom() {

	$if prod { C.VMProtectBeginMutation(c"engine.adjust_fov_by_zoom") }

	mut app_ctx := unsafe { app() }

	weapon := ent_weapon(app_ctx.ent_cacher.local_player) or { return }
	e.fov *= (weapon.zoom_level() + 1)

	$if prod { C.VMProtectEnd() }
}
