module golphook

import utils
import offsets
import valve

pub fn others_on_frame() {
	mut app_ctx := unsafe { app() }

	if app_ctx.config.active_config.bop {
		unsafe { bop() }
	}

	// if app_ctx.config.active_config.knife_changer {
	// 	kalambite()
	// }

	if app_ctx.config.active_config.spectator {
		specs()
	}

	if app_ctx.config.active_config.no_flash {
		no_flash()
	}
}

[unsafe]
pub fn bop() {
	mut app_ctx := unsafe { app() }

	if !app_ctx.ent_cacher.local_player.is_moving() {
		return
	}

	if C.GetAsyncKeyState(C.VK_SPACE) > 1 && (app_ctx.ent_cacher.local_player.flags() & (1 << 0) == 1) {
		mut force_jump := utils.get_val_offset<u32>(app_ctx.h_client, offsets.db.signatures.force_jump)
		unsafe { *force_jump = 6 }
	}
}

// pub fn kalambite() {
//
// 	mut app_ctx := unsafe { app() }
// 	mut local_player := app_ctx.ent_cacher.local_player
//
// 	if !local_player.is_alive() {
// 		return
// 	}
//
// 	knife_id, knife_model_name := get_knife_data(app_ctx.config.active_config.knife_type)
//
// 	mut knife_model_index := 0
//
// 	mut weapons := local_player.weapons()
// 	for i in 0..8 {
//
// 		unsafe {
// 			if weapons[i] == 0 || weapons[i] == -1 { continue }
// 		}
//
// 		current_weapon := unsafe { &valve.Weapon_t(app_ctx.interfaces.i_entity_list.get_client_entity_handle(u32(weapons[i]))) }
// 		current_view_mod := current_weapon.to_viewmodel()
// 		current_item:= current_weapon.to_item()
//
// 		mut current_weapon_id := current_weapon.definition_index().get()
// 		mut cs_current_weapon_id := valve.ItemDefinitionIndex(current_weapon_id)
//
// 		if int(cs_current_weapon_id) == 0 || cs_current_weapon_id == .weapon_invalid { continue }
//
// 		if cs_current_weapon_id == .weapon_knife || cs_current_weapon_id == .weapon_knife_t || int(cs_current_weapon_id) == knife_id {
// 			knife_model_index = app_ctx.interfaces.i_model_info.get_model_index("models/weapons/$knife_model_name")
//
// 			current_weapon.definition_index().set(i16(knife_id))
//
// 			current_view_mod.model_index().set(knife_model_index)
//
// 			current_view_mod.viewmodel_index().set(knife_model_index)
//
// 			current_item.entity_quality().set(7)
//
// 			current_item.item_id_high().set(-1)
//
// 			current_item.fallback_paint_kit().set(0)
//
// 			current_item.fallback_wear().set(0.0670)
// 		}
//
// 		if cs_current_weapon_id == .weapon_ak47 {
//
// 			current_item.item_id_high().set(-1)
//
// 			current_item.entity_quality().set(4)
// 			current_item.fallback_paint_kit().set(44)
// 			current_item.fallback_wear().set(0.0670)
// 			current_item.fallback_seed().set(123)
//
// 		}
//
// 	}
//
// 	active_weapon := &valve.Weapon_t(app_ctx.interfaces.i_entity_list.get_client_entity_handle(local_player.active_weapon()))
// 	if int(active_weapon) == 0 { return }
// 	if active_weapon.definition_index().get() != knife_id { return }
//
// 	active_view_model := &valve.Viewmodel(app_ctx.interfaces.i_entity_list.get_client_entity_handle(local_player.viewmodel()))
// 	if int(active_view_model) == 0 { return }
//
// 	active_view_model.model_index().set(knife_model_index)
//
// }

pub fn specs() {
	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter_player(fn (e &valve.Player, ctx &EntityCacher) bool {
		return (!e.is_alive() && e.team() == ctx.local_player.team()) || e.team() == .specs
	})

	mut specs_cout := 0
	for ent in ents {

		mut p_info := valve.PlayerInfo{}


		observer_target := ent.observer_target()
		//observer_target := &valve.Entity_t(app_ctx.interfaces.i_entity_list.get_client_entity_handle(h_observer_target))
		if u32(observer_target) != 0 {

			if voidptr(observer_target) == voidptr(app_ctx.ent_cacher.local_player) {
				if !app_ctx.interfaces.cdll_int.get_player_info(ent.index(), &p_info) {
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

pub fn no_flash() {
	mut app_ctx := unsafe { app() }

	if !app_ctx.ent_cacher.local_player.is_alive() {
		return
	}

	mut flash_dur := app_ctx.ent_cacher.local_player.flash_duration()
	if flash_dur.get() > 0.0 {
		flash_dur.set(0.0)
	}
}
