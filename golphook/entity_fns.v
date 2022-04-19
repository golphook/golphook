module golphook

import valve
import utils

pub fn i_can_see(player &valve.Entity, bones []usize) bool {

	mut app_ctx := unsafe { app() }

	mut from := app_ctx.ent_cacher.local_player.eye_pos()

	mut can_see := false
	for bone in bones {
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
			can_see = true
			break
		}
	}
	return can_see
}

pub fn check_ent_visible_by_mask(ent &valve.Entity) bool {
	mut app_ctx := unsafe { app() }
	r := ent.spotted_by_mask() & (1 << ( app_ctx.ent_cacher.local_player_id - 1))
	if r > 0 {
		return true
	}
	return false
}
