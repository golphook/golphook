module golphook
import utils

import json
import rand
import os

fn get_knife_data(knife_id int) (int, string) {
	match knife_id {
		0 { return 507, "v_knife_karam.mdl" }
		1 { return 508, "v_knife_m9_bay.mdl" }
		2 { return 515, "v_knife_butterfly.mdl" }
		3 { return 505, "v_knife_flip.mdl" }
		4 { return 506, "v_knife_gut.mdl" }
		5 { return 500, "v_knife_bayonet.mdl" }
		6 { return 509, "v_knife_tactical.mdl" }
		else { return 507, "v_knife_karam.mdl" }
	}
}

struct Config {
pub mut:
	name string = "golp"
	// others
	knife_changer bool = true
	knife_type int = 2

	bop bool = true

	spectator bool = true
	spectator_count_color utils.Color = utils.color_rbga(108, 92, 231, 255)
	spectators_color utils.Color = utils.color_rbga(255,255,255,255)

	killsound bool = true
	killsound_type int = 1// default = woof (0)

	viewmodel_override bool = true
	viewmodel_override_x f32 = 7
	viewmodel_override_y f32 = 7
	viewmodel_override_z f32 = -7
	viewmodel_override_fov f32 = 80

	no_flash bool

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

	weapon_name bool
	weapon_clip bool
	weapon_name_color_if_visible utils.Color = utils.color_rbga(1,1,1,255)
	weapon_name_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241,255)

	snapline bool
	snapline_color_if_visible utils.Color = utils.color_rbga(1,1,1,255)
	snapline_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241,255)

	radar bool = true

	watermark bool = true
	watermark_color utils.Color = utils.color_rbga(236, 240, 241,255)

	indicator bool = true
	indicator_color_if_on utils.Color = utils.color_rbga(108, 92, 231, 255)
	indicator_color_if_off utils.Color  = utils.color_rbga(236, 240, 241,255)

	fov_circle bool = true
	fov_circle_color utils.Color = utils.color_rbga(155, 89, 182 ,255)

	// engine

	engine bool = true
	fov f32 = 20
	engine_adjust_fov_scope bool = true

	engine_bones_list []int = [0, 8, 9, 6, 5]
	engine_force_bone_id int // default = 0
	engine_pref_bone_id int = 8

	engine_automatic_fire_key int = 0x5
	engine_force_bone_key int = 0x43
	engine_force_awall_key int = 0x06

	engine_automatic_fire_key_toggle bool
	engine_force_awall_key_toggle bool = true
	engine_force_bone_key_toggle bool = true



}

struct ConfigManager {
pub mut:
	configs []Config = [Config{}]
	active_config &Config = 0
	active_config_idx int
	selected_config_in_menu int
}

pub fn (mut c ConfigManager) bootstrap() {

	home := os.home_dir()
	golphook_folder := "$home\\golphook"
	if !os.exists(golphook_folder) {
		os.mkdir(golphook_folder) or { utils.error_critical("Failed to create ressource configs", "folder") }
	}

	configs_file := "$home\\golphook\\.configs"
	if !os.exists(configs_file) {
		os.write_file(configs_file, "text string") or { utils.error_critical("Failed to create ressource configs", "file") }
	}

	configs_file_content := os.read_file(configs_file) or {
		utils.error_critical("Failed to acces ressource configs", "file")
		return
	}

	mut configs := json.decode([]Config, configs_file_content) or {
		unsafe { utils.msg_c(utils.color_rbga(255, 255 ,255, 255), "failed to read configs default one will be set") }
		c.active_config = &c.configs[0]
		return
	}

	c.configs.clear()

	c.configs = configs
	c.configs[0] = Config{}
	c.active_config = &c.configs[0]

}

pub fn (mut c ConfigManager) export(configWithIndex int) string {
	json := json.encode(c.configs[configWithIndex])
	return json
}

pub fn (mut c ConfigManager) import_fc(withConfig string) {

	mut cfg := json.decode(Config, withConfig) or {
		unsafe { utils.msg_c(utils.color_rbga(255, 255 ,255, 255), "failed to decode config") }
		return
	}

	cfg.name = f32(c.configs.len + 1).str()
	c.configs << cfg
}

pub fn (mut c ConfigManager) delete(configWithIndex int) {
	if configWithIndex == 0 {
		unsafe { utils.msg_c(utils.color_rbga(255, 255 ,255, 255), "cannot delete default config") }
		return
	}
	if configWithIndex == c.active_config_idx {
		c.change_to(0)
	}
	c.configs.delete(configWithIndex)
	c.save()
}

pub fn (mut c ConfigManager) save() {
	json := json.encode_pretty(c.configs)
	home := os.home_dir()
	configs_file := "$home\\golphook\\.configs"
	os.write_file(configs_file, json) or { utils.error_critical("Failed to access ressource configs", "file") }
}

pub fn (mut c ConfigManager) rename(configWithIndex int, andNewName string) {
	if configWithIndex == 0 {
		unsafe { utils.msg_c(utils.color_rbga(255, 255 ,255, 255), "cannot rename default config") }
		return
	}

	c.configs[configWithIndex].name = andNewName
	c.save()
}

pub fn (mut c ConfigManager) new_blank(withName string) {
	mut new_cfg := Config{}
	new_cfg.name = f32(c.configs.len + 1).str()
	if withName.len != 0 {
		new_cfg.name = withName
	}
	c.configs << new_cfg
}

pub fn (mut c ConfigManager) change_to(configWithIndex int) {
	mut app_ctx := unsafe { app() }

	if configWithIndex == c.active_config_idx {
		return
	}

	app_ctx.is_ok = false
	c.active_config = &c.configs[configWithIndex]
	c.active_config_idx = configWithIndex
	app_ctx.is_ok = true
}
