module golphook

import valve
import utils
import math
import offsets

pub fn i_can_see(player &valve.Player, bones []usize) (bool, valve.CGameTrace) {

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

// this addittion changed everyting how the aimbot shoot, what it does is adding
// an offset on all side of the player eye pos this result to mark the player visible faster
// and add a 'legit awall' a value btw 0-2 juste make shoot faster but 3-7 add a little
// awall and with this dumb trick 4 times in 10 i can kill a bad/medium spinner
// no joke this shit changed everyting
pub fn i_can_see_with_offset(player &valve.Player, bone	usize, offset f32) bool {

	mut app_ctx := unsafe { app() }

	for o in 0..3 {
		mut from := app_ctx.ent_cacher.local_player.eye_pos()
		match o {
			0 {
				from.x += offset
			}
			1 {
				from.x -= offset
			}
			2 {
				from.y += offset
			}
			3 {
				from.y -= offset
			}
			else {}
		}

		mut end := player.bone(bone) or {
			return false
		}
		mut tr := valve.CGameTrace{}
		mut ray := valve.Ray{}
		mut filter := valve.CTraceFilter{}

		filter.p_skip = voidptr(app_ctx.ent_cacher.local_player)

		ray.init(from, end)
		app_ctx.interfaces.i_engine_trace.trace_ray(&ray, 0x46004009, &filter, &tr)
		if tr.is_invisible() {
			return true
		}
	}
	return false
}

pub fn ent_weapon(for_ent &valve.Player) ?&valve.Weapon_t {

	mut app_ctx := unsafe { app() }

	prob_weapon := app_ctx.interfaces.i_entity_list.get_client_entity_handle(for_ent.active_weapon())
	if isnil(prob_weapon) {
		weapon := &valve.Weapon_t(prob_weapon)
		return weapon
	}
	return error("")
}
