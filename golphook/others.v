module golphook

import utils
import offsets
import valve

pub fn others_on_frame() {
	
	$if prod { C.VMProtectBeginMutation(c"others.on_frame") }

	mut app_ctx := unsafe { app() }

	if app_ctx.config.active_config.bop {
		unsafe { bop() }
	}

	if app_ctx.config.active_config.spectator {
		specs()
	}

	if app_ctx.config.active_config.no_flash {
		no_flash()
	}

	$if prod { C.VMProtectEnd() }
}

[unsafe]
pub fn bop() {

	$if prod { C.VMProtectBeginMutation(c"others.bop") }

	mut app_ctx := unsafe { app() }

	if !app_ctx.ent_cacher.local_player.is_moving() {
		return
	}

	if C.GetAsyncKeyState(C.VK_SPACE) > 1 && (app_ctx.ent_cacher.local_player.flags() & (1 << 0) == 1) {
		mut force_jump := utils.get_val_offset<u32>(app_ctx.h_client, offsets.db.signatures.force_jump)
		unsafe { *force_jump = 6 }
	}

	$if prod { C.VMProtectEnd() }
}

pub fn specs() {

	$if prod { C.VMProtectBeginMutation(c"others.specs") }

	mut app_ctx := unsafe { app() }

	ents := app_ctx.ent_cacher.filter_player(fn (e &valve.Player, ctx &EntityCacher) bool {
		return (!e.is_alive() && e.team() == ctx.local_player.team()) || e.team() == .specs
	})

	mut specs_cout := 0
	for ent in ents {

		mut p_info := valve.PlayerInfo{}

		h_observer_target := ent.observer_target()
		observer_target := &valve.Entity_t(app_ctx.interfaces.i_entity_list.get_client_entity_handle(h_observer_target))
		if u32(observer_target) != 0 {

			if voidptr(observer_target) == voidptr(app_ctx.ent_cacher.local_player) {
				if !app_ctx.interfaces.cdll_int.get_player_info(ent.index(), &p_info) {
					return
				}
				specs_cout++

				observer_mode := match ent.observer_mode() {
					.mode_in_eye { " (pov)" }
					.mode_chase { " (3rd)" }
					.mode_poi { " (fly)" }
					else { "" }
				}

				app_ctx.rnd_queue.push(new_text(utils.new_vec2(20 + specs_cout*10, 4).vec_3(),"${p_info.player_name()}${observer_mode}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.spectators_color))
			}

		}
	}
	if specs_cout != 0 {
		app_ctx.rnd_queue.push(new_text(utils.new_vec2(20, 4).vec_3(), "Spectators (${f32(specs_cout)})", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, app_ctx.config.active_config.spectator_count_color))
	}

	$if prod { C.VMProtectEnd() }
}

pub fn no_flash() {
	
	$if prod { C.VMProtectBeginMutation(c"others.no_flash") }

	mut app_ctx := unsafe { app() }

	if !app_ctx.ent_cacher.local_player.is_alive() {
		return
	}

	mut flash_dur := app_ctx.ent_cacher.local_player.flash_duration()
	if flash_dur.get() > 0.0 {
		flash_dur.set(0.0)
	}

	$if prod { C.VMProtectEnd() }
}
