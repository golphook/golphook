module golphook

// this part is made by following cazz video about chams

import valve
import utils

struct Chams {
pub mut:
	current_material_name string
	current_material &valve.IMaterial = unsafe { nil }
}

pub fn (mut c Chams) on_draw_model(ecx voidptr, edx voidptr, result voidptr, info &valve.CDrawModelInfo, bones voidptr, flex_weights &f32, flex_deleyed_weight &f32, model_origin &utils.Vec3, flags int) bool {

	$if prod { C.VMProtectBeginMutation(c"chams.on_draw_model") }

	mut app_ctx := unsafe { app() }

	if !app_ctx.config.active_config.chams {
		return false
	}

	if isnil(info.renderable) {
		return false
	}

	mut ent := info.renderable.get_i_client_unknown().get_base_entity()

	if isnil(ent) || !ent.is_player() {
		return false
	}

	plr := &valve.Player(voidptr(ent))

	if isnil(plr) {
		return false
	}

	if plr.team() != app_ctx.ent_cacher.local_player.team() {

		if isnil(c.current_material) || c.current_material_name != get_material_str(app_ctx.config.active_config.chams_material) {
			c.current_material = app_ctx.interfaces.i_material_system.find_material(get_material_str(app_ctx.config.active_config.chams_material))
			if isnil(c.current_material) {
				// this material is probably not working
				return false
			}
			c.current_material_name = get_material_str(app_ctx.config.active_config.chams_material)
		}

		visible := app_ctx.config.active_config.chams_color_if_visible.rgbf()
		invisible := app_ctx.config.active_config.chams_color_if_not_visible.rgbf()

		app_ctx.interfaces.i_studio_renderer.set_alpha_modulation(app_ctx.config.active_config.chams_color_if_not_visible.rgbaf().a)

		if !app_ctx.config.active_config.chams_is_visible_only {
			c.current_material.set_material_flag(.ignorez, true)
			app_ctx.interfaces.i_studio_renderer.set_color_modulation(&invisible)
			app_ctx.interfaces.i_studio_renderer.force_material_override(c.current_material, .normal, -1)

			app_ctx.hooks.draw_model.original_save(ecx, edx, result ,info, bones, flex_weights, flex_deleyed_weight, model_origin, flags)
		}

		app_ctx.interfaces.i_studio_renderer.set_alpha_modulation(app_ctx.config.active_config.chams_color_if_visible.rgbaf().a)

		c.current_material.set_material_flag(.ignorez, false)
		app_ctx.interfaces.i_studio_renderer.set_color_modulation(&visible)
		app_ctx.interfaces.i_studio_renderer.force_material_override(c.	current_material, .normal, -1)

		app_ctx.hooks.draw_model.original_save(ecx, edx, result ,info, bones, flex_weights, flex_deleyed_weight, model_origin, flags)

		app_ctx.interfaces.i_studio_renderer.force_material_override(voidptr(0), .normal, -1)
		return true

	}
	
	$if prod { C.VMProtectEnd() }

	return false
}
