module golphook

import valve
import utils

struct SkinEntry {
pub mut:
	definition_index valve.ItemDefinitionIndex = .weapon_invalid

	quality int
	paint_kit int
	wear f32
	seed int

	is_knife bool
}

struct Skins {
pub mut:
	current_selected_in_menu int
}

pub fn (mut s Skins) on_frame() {

	$if prod { C.VMProtectBeginMutation(c"skins.on_frame") }

	mut app_ctx := unsafe { app() }

	if app_ctx.config.active_config.skins_changer {
		s.skin_changer()
	}

	$if prod { C.VMProtectEnd() }
}

pub fn (mut s Skins) skin_changer() {

	$if prod { C.VMProtectBeginMutation(c"skins.skin_changer") }

	mut app_ctx := unsafe { app() }

	if !app_ctx.ent_cacher.local_player.is_alive() {
		return
	}

	mut knife_model_index := 0
	mut knife_def_idx := 0

	mut weapons := app_ctx.ent_cacher.local_player.weapons()
	for i in 0..8 {

		unsafe {
			if weapons[i] == 0 || weapons[i] == -1 { continue }
		}

		current_weapon := unsafe { &valve.Weapon_t(app_ctx.interfaces.i_entity_list.get_client_entity_handle(u32(weapons[i]))) }
		current_view_mod := current_weapon.to_viewmodel()
		current_item:= current_weapon.to_item()

		mut current_weapon_id := current_weapon.definition_index().get()
		mut cs_current_weapon_id := valve.ItemDefinitionIndex(current_weapon_id)

		if int(cs_current_weapon_id) == 0 || cs_current_weapon_id == .weapon_invalid { continue }

		mut skin_info := SkinEntry{}

		for sk in app_ctx.config.active_config.skins {
			if cs_current_weapon_id == sk.definition_index || ( sk.is_knife && ( cs_current_weapon_id == .weapon_knife || cs_current_weapon_id == .weapon_knife_t ) ) {
				skin_info = sk

				if sk.is_knife {
					knife_model_name := get_knife_data(int(sk.definition_index))
					knife_model_index = app_ctx.interfaces.i_model_info.get_model_index("models/weapons/$knife_model_name")
					knife_def_idx = int(sk.definition_index)
				}

			}
		}

		if cs_current_weapon_id == .weapon_knife || cs_current_weapon_id == .weapon_knife_t || current_weapon_id == knife_def_idx {
			current_weapon.definition_index().set(i16(knife_def_idx))
			current_view_mod.model_index().set(knife_model_index)
			current_view_mod.viewmodel_index().set(knife_model_index)
		}

		if skin_info.paint_kit != 0 {
			current_item.entity_quality().set(skin_info.quality)
			current_item.fallback_paint_kit().set(skin_info.paint_kit)
			current_item.fallback_wear().set(skin_info.wear)
			current_item.fallback_seed().set(skin_info.seed)
			current_item.item_id_high().set(-1)
		}

	}

	active_weapon := &valve.Weapon_t(app_ctx.interfaces.i_entity_list.get_client_entity_handle(app_ctx.ent_cacher.local_player.active_weapon()))
	if int(active_weapon) == 0 { return }
	if active_weapon.definition_index().get() != knife_def_idx { return }

	active_view_model := &valve.Viewmodel(app_ctx.interfaces.i_entity_list.get_client_entity_handle(app_ctx.ent_cacher.local_player.viewmodel()))
	if int(active_view_model) == 0 { return }

	active_view_model.model_index().set(knife_model_index)

	$if prod { C.VMProtectEnd() }
}
