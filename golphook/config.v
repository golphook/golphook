module golphook
import utils

import json
import encoding.base64

fn get_knife_data(knife_id int) (int, string) {
	match knife_id {
		0 { return 507, "v_knife_karam.mdl" }
		1 { return 508, "v_knife_m9_bay.mdl" }
		2 { return 515, "v_knife_butterfly.mdl" }
		else { return 507, "v_knife_karam.mdl" }
	}
}

struct Config {
pub:
	name string = "default"
pub mut:
	// others
	knife_changer bool = true
	knife_type int = 2

	bop bool = true

	spectator bool = true
	spectator_count_color utils.Color = utils.color_rbga(108, 92, 231, 255)
	spectators_color utils.Color = utils.color_rbga(255,255,255,255)
	// visuals
	glow bool = true
	glow_color_if_visible utils.Color = utils.color_rbga(236, 240, 241, 130)
	glow_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241, 130)

	box bool = true
	box_color_if_visible utils.Color = utils.color_rbga(1,1,1,255)
	box_color_if_not_visible utils.Color  = utils.color_rbga(236, 240, 241,255)

	names bool = true
	hp bool = true
	names_color_if_visible utils.Color = utils.color_rbga(1,1,1,255)
	names_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241,255)

	snapline bool = true
	snapline_color_if_visible utils.Color = utils.color_rbga(1,1,1,255)
	snapline_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241,255)

	radar bool = true

	watermark bool = true
	watermark_color utils.Color = utils.color_rbga(236, 240, 241,255)

	indicator bool = true
	indicator_color_if_on utils.Color = utils.color_rbga(108, 92, 231, 255)
	indicator_color_if_off utils.Color  = utils.color_rbga(1,1,1,255)

	fov_circle bool = true
	fov_circle_color utils.Color = utils.color_rbga(155, 89, 182 ,255)

	// engine

	engine bool = true
	fov f32 = 15
	engine_bones_list []int = [0, 8, 9, 6, 5]
	engine_force_bone_id u32 = 5
	engine_pref_bone_id u32 = 8
	engine_automatic_fire_key u32 = 0x5
	engine_force_bone_key u32 = 0x43
}

struct ConfigManager {
pub mut:
	configs []Config = [Config{}]
	active_config &Config = 0
}

pub fn (mut c ConfigManager) bootstrap() {
	c.active_config = &c.configs[0]
}

pub fn (mut c ConfigManager) export() string {
	json := json.encode(c.active_config)
	return base64.encode_str(json)
}

pub fn (mut c ConfigManager) load(withConfig string) {
	clear_json := base64.decode_str(withConfig)
	cfg := json.decode(Config, clear_json) or {
		utils.client_error("Failed to load config")
		return
	}
	c.configs << cfg
}


pub fn (mut c ConfigManager) change_to(configWithName string) {
	mut app_ctx := unsafe { app() }

	for mut config in c.configs {
		if config.name == configWithName {
			app_ctx.is_ok = false
			c.active_config = unsafe { config }
			app_ctx.is_ok = true
		}
	}
}
