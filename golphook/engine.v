module golphook

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
	ent &valve.Entity = 0
	bones_on_screen []Bone
	closest_bone Bone = Bone{id: 999, pos: utils.new_vec3(0,0,999)}
}

struct Engine {
pub mut:
	do_a_shoot bool
	do_force_bone bool
	targeted_entities []TargetedEntity

	bones []int = [0, 8, 9, 6, 5]
	pref_bone int = 8
	force_bone int = 5
	fov int = 20
}

fn (mut e Engine) on_frame() {
	mut app_ctx := unsafe { app() }
	e.do_a_shoot = false

	if (C.GetAsyncKeyState(0x43) & 1) == 1 {
		e.do_force_bone = !e.do_force_bone
		utils.pront("$e.do_force_bone")
	}

	if C.GetAsyncKeyState(0x5) > 1 {
		e.do_a_shoot = true
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
			mut force_attack := utils.get_val_offset<int>(app_ctx.h_client, offsets.db.signatures.force_attack)
			unsafe { *force_attack = 6 }
		}
	}
}

fn (e &Engine) aim_at(ent TargetedEntity) {
	mut app_ctx := unsafe { app() }
	local_player_eye_pos := app_ctx.ent_cacher.local_player.eye_pos()
	target_bone_pos := ent.ent.bone(usize(ent.closest_bone.id)) or { return }

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
}

fn (e &Engine) is_in_fov(bone_pos_on_screen &utils.Vec3) (bool, f32) {
	mut app_ctx := unsafe { app() }
	a := math.abs(bone_pos_on_screen.x - ( app_ctx.wnd_width / 2 ))
	b := math.abs(bone_pos_on_screen.y - ( app_ctx.wnd_height / 2 ))

	c := math.sqrt((a*a) + (b*b))

	if c < e.fov {
		return true, f32(c)
	}
	return false, f32(c)
}


fn (mut e Engine) collect_targeted_ents() {
	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team()
	})

	for ent in ents {

		mut bone_pos := utils.new_vec3(0,0,0)
		mut bone_screen := utils.new_vec3(0,0,0)
		mut target := unsafe { TargetedEntity{ent: ent} }

		for b_id in e.bones {
			bone_pos = ent.bone(usize(b_id)) or { return }

			if app_ctx.interfaces.i_debug_overlay.screen_pos(bone_pos, bone_screen) == 0 {

				mut in_fov, z := e.is_in_fov(bone_screen)
				bone_screen.z = z

				if in_fov {
					target.bones_on_screen << Bone{id: b_id, pos: bone_screen}

					if bone_screen.z < target.closest_bone.pos.z || b_id == e.force_bone || b_id == e.pref_bone {
						if target.closest_bone.id != e.pref_bone {
							target.closest_bone = target.bones_on_screen.last(	)
						}
						if target.closest_bone.id != e.force_bone && e.do_force_bone {
							target.closest_bone = target.bones_on_screen.last(	)
						}
					}

				}

			}
		}

		if target.bones_on_screen.len != 0 {
			e.targeted_entities << target
		}

	}

}