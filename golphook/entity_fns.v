module golphook

import valve
import utils
import math
import offsets

pub fn i_can_see(player &valve.Entity, bones []usize) (bool, valve.CGameTrace) {

	mut app_ctx := unsafe { app() }

	mut from := app_ctx.ent_cacher.local_player.eye_pos()

	mut can_see := false
	mut tr_ := valve.CGameTrace{}
	for bone in bones {
		mut end := player.bone(bone) or {
			return false, valve.CGameTrace{}
		}
		mut tr := valve.CGameTrace{}
		mut ray := valve.Ray{}
		mut filter := valve.CTraceFilter{}

		filter.p_skip = voidptr(app_ctx.ent_cacher.local_player)

		ray.init(from, end)
		app_ctx.interfaces.i_engine_trace.trace_ray(&ray, 0x46004009, &filter, &tr)
		tr_ = tr
		if tr.is_invisible() {
			can_see = true
			break
		}
	}
	return can_see, tr_
}

pub fn check_ent_visible_by_mask(ent &valve.Entity) bool {
	mut app_ctx := unsafe { app() }
	r := ent.spotted_by_mask() & (1 << ( app_ctx.ent_cacher.local_player_id - 1))
	if r > 0 {
		return true
	}
	return false
}

pub fn my_speed_angles() utils.Vec3 {
	mut app_ctx := unsafe { app() }
	v_vel := app_ctx.ent_cacher.local_player.velocity()
	a_angles := utils.new_angle(0,0,0)
	app_ctx.interfaces.cdll_int.get_view_angle(&a_angles)

	mut v_final := utils.new_vec3(0,0,0)
	view_angle_rad := a_angles.yaw * utils.radian

	v_final.x = ( math.cosf(view_angle_rad) * v_vel.x ) - ( math.sinf(view_angle_rad) * ( -v_vel.y ) )
	v_final.y = ( math.sinf(view_angle_rad) * v_vel.x ) + ( math.cosf(view_angle_rad) * ( -v_vel.y ) )
	return v_final
}

pub fn stopp()  {
	mut app_ctx := unsafe { app() }

	// zz := C.GetAsyncKeyState(0x5A) > 1
	// qq := C.GetAsyncKeyState(0x51) > 1
	// ss := C.GetAsyncKeyState(0x53) > 1
	// dd := C.GetAsyncKeyState(0x44) > 1

	mut force_forward := utils.get_val_offset<int>(app_ctx.h_client, offsets.db.signatures.force_forward)
	mut force_backward := utils.get_val_offset<int>(app_ctx.h_client, offsets.db.signatures.force_backward)
	mut force_left := utils.get_val_offset<int>(app_ctx.h_client, offsets.db.signatures.force_left)
	mut force_right := utils.get_val_offset<int>(app_ctx.h_client, offsets.db.signatures.force_right)

	v_vel := app_ctx.ent_cacher.local_player.velocity()
	vel := math.sqrtf(v_vel.x * v_vel.x + v_vel.y * v_vel.y)
	v_avel := my_speed_angles()

	if vel >=30&& ( app_ctx.ent_cacher.local_player.flags() == 257 ) {

		if v_avel.x >= 30 {
			unsafe { *force_backward = 6 }
		}
		if v_avel.x <= -30 {
			unsafe { *force_forward = 6 }
		}
		if v_avel.y >= 30 {
			unsafe { *force_left = 6 }
		}
		if v_avel.y <= -30 {
			unsafe { *force_right = 6 }
		}

	}
}

pub fn ent_weapon(forEnt &valve.Entity) ?&valve.Weapon {
	mut app_ctx := unsafe { app() }
	prob_weapon := app_ctx.interfaces.i_entity_list.get_client_entity_handle(forEnt.active_weapon())
	if int(prob_weapon) != 0 {
		weapon := &valve.Weapon(prob_weapon)
		return weapon
	}
	return error("")
}
