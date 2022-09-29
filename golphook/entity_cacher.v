module golphook

import valve

struct EntityCacher {
pub mut:
	cache shared []&valve.Entity_t
	local_player &valve.Player = unsafe { nil }
}

pub fn (mut e EntityCacher) on_frame() {

	$if prod { C.VMProtectBeginMutation(c"ent_cacher.on_frame") }

	mut app_ctx := unsafe { app() }

	lock e.cache {
		e.cache.clear()
	}

	for ent_idx in 0..32 {
		if ent_idx == app_ctx.interfaces.cdll_int.get_local_player() {
			e.local_player = app_ctx.interfaces.i_entity_list.get_client_entity(ent_idx)
			continue
		}

		p_ent := app_ctx.interfaces.i_entity_list.get_client_entity(ent_idx)
		if int(p_ent) == 0 { continue }

		e_ent := &valve.Entity_t(p_ent)
		lock e.cache {
			e.cache << e_ent
		}
	}

	$if prod { C.VMProtectEnd() }
}

pub fn (mut e EntityCacher) filter_player(ent_filter fn(&valve.Player, &EntityCacher) bool) []&valve.Player {

	$if prod { C.VMProtectBeginMutation(c"ent_cacher.filter_player") }

	mut ret := []&valve.Player{}

	rlock e.cache {
		for ent in e.cache {
			p_ent := unsafe { &valve.Player(ent) }

			if ent_filter(p_ent, e) {
				ret << p_ent
			}
		}
	}

	$if prod { C.VMProtectEnd() }

	return ret
}
