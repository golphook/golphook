module golphook

import utils
import offsets
import valve

pub fn others_on_frame() {
	mut app_ctx := unsafe { app() }

	if app_ctx.config.active_config.bop {
		bop()
	}

	if app_ctx.config.active_config.knife_changer {
		kalambite()
	}

	if app_ctx.config.active_config.spectator {
		specs()
	}

}


pub fn bop() {
	mut app_ctx := unsafe { app() }

	if C.GetAsyncKeyState(C.VK_SPACE) > 1 && (app_ctx.ent_cacher.local_player.flags() & (1 << 0) == 1) {
		mut force_jump := utils.get_val_offset<u32>(app_ctx.h_client, offsets.db.signatures.force_jump)
		unsafe { *force_jump = 6 }
	}
}

pub fn kalambite() {

	mut app_ctx := unsafe { app() }
	mut local_player := app_ctx.ent_cacher.local_player

	if !local_player.is_alive() {
		return
	}

	for i in 0..8 {

		mut current_weapon := local_player.weapons(i, 0x4) & 0xFFF
		current_weapon = *(&u32(usize(app_ctx.h_client) + usize(offsets.db.signatures.entity_list) + usize(current_weapon - 1) * 0x10))
		if current_weapon == 0 { continue }
		mut current_weapon_id := *(&i16(current_weapon + offsets.db.netvars.m_item_definition_index))
		if current_weapon_id == 0 { continue }
		cs_current_weapon_id := valve.ItemDefinitionIndex(current_weapon_id)

		if cs_current_weapon_id == .weapon_knife || cs_current_weapon_id == .weapon_knife_t || int(cs_current_weapon_id) == 507 {
			karambit_model_index := u32(app_ctx.interfaces.i_model_info.get_model_index("models/weapons/v_knife_karam.mdl"))

			mut item_def_inde := (&i16(current_weapon + offsets.db.netvars.m_item_definition_index))
			unsafe { *item_def_inde = 507 }

			mut model_index := (&u32(current_weapon + offsets.db.netvars.m_model_index))
			unsafe { *model_index = karambit_model_index }

			mut view_model_index := (&u32(current_weapon + offsets.db.netvars.m_view_model_index))
			unsafe { *view_model_index = karambit_model_index }

			mut ent_quality := (&int(current_weapon + offsets.db.netvars.m_entity_quality))
			unsafe { *ent_quality = 7 }

			mut item_id_hight := (&int(current_weapon + offsets.db.netvars.m_item_id_high))
			unsafe { *item_id_hight = -1 }

			mut fallback_p_kit := (&u32(current_weapon + offsets.db.netvars.m_fallback_paint_kit))
			unsafe { *fallback_p_kit = 0 }

			mut fallback_wear := (&f32(current_weapon + offsets.db.netvars.m_fallback_wear))
			unsafe { *fallback_wear = f32(0.0670)}

			mut active_weapon := local_player.active_weapon() & 0xFFF
			active_weapon = *(&u32(usize(app_ctx.h_client) + usize(offsets.db.signatures.entity_list) + usize(active_weapon - 1) * 0x10))

			if active_weapon == 0 { continue }

			mut active_weapon_id := *(&i16(active_weapon + offsets.db.netvars.m_item_definition_index))
			if active_weapon_id != 507 { continue }

			mut active_view_model := local_player.viewmodel() & 0xFFF
			active_view_model = *(&u32(usize(app_ctx.h_client) + usize(offsets.db.signatures.entity_list) + usize(active_view_model - 1) * 0x10))
			if active_view_model == 0 { continue }

			mut set := &u32(active_view_model + offsets.db.netvars.m_model_index)
			unsafe { *set = karambit_model_index }


		}

	}

}

pub fn specs() {
	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return (!e.is_alive() && e.team() == ctx.local_player.team()) || e.team() == .specs
	})

	mut specs_cout := 0
	for ent in ents {

		mut p_info := valve.PlayerInfo{}


		h_observer_target := ent.observer_target()
		observer_target := &valve.Entity(app_ctx.interfaces.i_entity_list.get_client_entity_handle(h_observer_target))
		if u32(observer_target) != 0 {

			if voidptr(observer_target) == voidptr(app_ctx.ent_cacher.local_player) {
				mut rs := app_ctx.interfaces.cdll_int.get_player_info(app_ctx.ent_cacher.get_id(ent), &p_info)
				if !rs {
					return
				}
				specs_cout++
				app_ctx.rnd_queue.push(new_text(utils.new_vec2(20 + specs_cout*10, 4).vec_3(), p_info.player_name(), 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.spectators_color))
			}

		}
	}
	if specs_cout != 0 {
		app_ctx.rnd_queue.push(new_text(utils.new_vec2(20, 4).vec_3(), "Spectators (${f32(specs_cout)})", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.spectator_count_color))
	}
}
