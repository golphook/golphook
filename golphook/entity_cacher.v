module golphook

import valve

struct EntityCacher {
pub mut:
	cache shared []&valve.Entity
	local_player &valve.Entity = 0
}

pub fn (mut e EntityCacher) on_frame() {
	mut app_ctx := unsafe { app() }

	lock e.cache {
		e.cache.clear()
	}

	for ent_idx in 0..32 {
		if ent_idx == app_ctx.interfaces.cdll_int.get_local_player() {
			p_ent := app_ctx.interfaces.i_entity_list.get_client_entity(ent_idx)
			e.local_player = p_ent
			continue
		}

		p_ent := app_ctx.interfaces.i_entity_list.get_client_entity(ent_idx)
		if int(p_ent) == 0 { continue }

		e_ent := &valve.Entity(p_ent)
		lock e.cache {
			e.cache << e_ent
		}
	}
}

pub fn (mut e EntityCacher) filter(ent_filter fn(&valve.Entity, &EntityCacher) bool) []&valve.Entity {
	mut ret := []&valve.Entity{}
	rlock e.cache {
		for ent in e.cache {
			if ent_filter(ent, e) {
				ret << ent
			}
		}
	}

	return ret
}
