module golphook

import valve
import utils

pub fn i_can_see(player &valve.Player, bones []usize) (bool, valve.CGameTrace) {

	$if prod { C.VMProtectBeginMutation(c"entity_fns.i_can_see") }

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
	
	$if prod { C.VMProtectEnd() }

	return can_see, tr_
}


pub fn trace_from_to_pos(from_pos utils.Vec3, to_pos utils.Vec3) valve.CGameTrace {

	mut app_ctx := unsafe { app() }

	mut tr := valve.CGameTrace{}
	mut ray := valve.Ray{}
	mut filter := valve.CTraceFilter{}

	filter.p_skip = voidptr(app_ctx.ent_cacher.local_player)

	ray.init(from_pos, to_pos)
	app_ctx.interfaces.i_engine_trace.trace_ray(&ray, 0x46004009, &filter, &tr)

	$if prod { C.VMProtectEnd() }

	return tr
}
