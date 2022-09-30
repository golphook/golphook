module golphook

// no big improvement since the last c++ since its the same except for the visible check
// but ngl it does the job fr

import utils
import valve
import math
import offsets

struct Bone {
pub mut:
	pos utils.Vec3
	id int
}

struct TargetedEntity {
pub mut:
	ent &valve.Player = unsafe { nil }
	bones_on_screen []Bone
	closest_bone Bone = Bone{id: 999, pos: utils.new_vec3(0,0,999)}
}

struct Engine {
pub mut:
	do_a_shoot bool
	do_force_bone bool
	do_force_awal bool
	targeted_entities []TargetedEntity

	fov f32

	is_spraying bool
}

fn (mut e Engine) on_frame() {

	$if prod { C.VMProtectBeginMutation(c"engine.on_frame") }

	mut app_ctx := unsafe { app() }


	if !app_ctx.config.active_config.engine  {
		return
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
		e.collect_targeted_ents()

		if e.targeted_entities.len != 0 {
			mut closest_target := e.targeted_entities.first()

			for ent in e.targeted_entities {
				if ent.closest_bone.pos.z < closest_target.closest_bone.pos.z {
					closest_target = ent
				}
			}

			e.aim_at(closest_target)
			force_attack.set(6)
			e.is_spraying = true
		}
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut e Engine) handle_keys() {

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
fn (e &Engine) aim_at(ent TargetedEntity) {

	$if prod { C.VMProtectBeginMutation(c"engine.aim_at") }

	mut app_ctx := unsafe { app() }

	local_player_eye_pos := app_ctx.ent_cacher.local_player.eye_pos()
	mut target_bone_pos := ent.ent.bone(usize(ent.closest_bone.id)) or { return }

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

fn (e &Engine) is_in_fov(bone_pos_on_screen &utils.Vec3) (bool, f32) {

	$if prod { C.VMProtectBeginMutation(c"engine.is_in_fov") }

	mut app_ctx := unsafe { app() }

	a := math.abs(bone_pos_on_screen.x - ( app_ctx.wnd_width / 2 ))
	b := math.abs(bone_pos_on_screen.y - ( app_ctx.wnd_height / 2 ))

	c := math.sqrt((a*a) + (b*b))

	if c < e.fov {
		return true, f32(c)
	}

	$if prod { C.VMProtectEnd() }
	
	return false, f32(c)
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

pub fn (mut e Engine) adjust_fov_by_zoom() {

	$if prod { C.VMProtectBeginMutation(c"engine.adjust_fov_by_zoom") }

	mut app_ctx := unsafe { app() }

	weapon := ent_weapon(app_ctx.ent_cacher.local_player) or { return }
	e.fov *= (weapon.zoom_level() + 1)

	$if prod { C.VMProtectEnd() }
}

fn (mut e Engine) collect_targeted_ents() {

	$if prod { C.VMProtectBeginMutation(c"engine.collect_targeted_ents") }

	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter_player(fn (e &valve.Player, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team() && e.dormant() == false
	})

	for ent in ents {

		mut bone_pos := utils.new_vec3(0,0,0)
		mut bone_screen := utils.new_vec3(0,0,0)
		mut target := unsafe { TargetedEntity{ent: ent} }

		mut bones_list := app_ctx.config.active_config.engine_bones_list.clone()
		if e.do_force_bone {
			bones_list = bones_list.filter(it == app_ctx.config.active_config.engine_force_bone_id)
		}

		for b_id in bones_list {
			bone_pos = ent.bone(usize(b_id)) or { return }

			if app_ctx.interfaces.i_debug_overlay.screen_pos(bone_pos, bone_screen) {

				mut in_fov, z := e.is_in_fov(bone_screen)
				bone_screen.z = z

				if in_fov {

					// see entity_fns.v:37 for explaination
					awall_mult := if app_ctx.config.active_config.engine_vhv_mode {
						app_ctx.config.active_config.engine_vhv_aw_factor
					} else {
						0.0
					}

					if e.do_force_awal || i_can_see_with_offset(ent, usize(b_id), awall_mult) {
						target.bones_on_screen << Bone{id: b_id, pos: bone_screen}
						// pov i don't even understand this part anymore ^^
						if bone_screen.z < target.closest_bone.pos.z || b_id == app_ctx.config.active_config.engine_force_bone_id || b_id == app_ctx.config.active_config.engine_pref_bone_id {
							if target.closest_bone.id != app_ctx.config.active_config.engine_pref_bone_id {
								target.closest_bone = target.bones_on_screen.last()
							}
							if target.closest_bone.id != app_ctx.config.active_config.engine_force_bone_id && e.do_force_bone {
								target.closest_bone = target.bones_on_screen.last()
							}
						}
					}
				}

			}
		}

		if target.bones_on_screen.len != 0 {
			e.targeted_entities << target
		}

	}

	$if prod { C.VMProtectEnd() }

}
