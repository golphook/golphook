module golphook

// export config is horrible but base64 module don't work in dlls
import utils
import json
import rand
import os

fn get_knife_data(knife_id int) string {
	return match knife_id {
		503 { 'v_knife_css.mdl' }
		507 { 'v_knife_karam.mdl' }
		508 { 'v_knife_m9_bay.mdl' }
		515 { 'v_knife_butterfly.mdl' }
		505 { 'v_knife_flip.mdl' }
		506 { 'v_knife_gut.mdl' }
		500 { 'v_knife_bayonet.mdl' }
		509 { 'v_knife_tactical.mdl' }
		520 { 'v_knife_gypsy_jackknife.mdl' }
		else { 'v_knife_karam.mdl' }
	}
}

fn get_material_str(for_material_id int) string {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.get_material_str')
	}

	match int(for_material_id) {
		0 { return 'debug/debugambientcube' }
		1 { return 'models/inventory_items/trophy_majors/gold' }
		2 { return 'models/player/ct_fbi/ct_fbi_glass' }
		3 { return 'models/gibs/glass/glass' }
		4 { return 'models/inventory_items/trophy_majors/crystal_clear' }
		5 { return 'models/inventory_items/trophy_majors/crystal_blue' }
		6 { return 'models/inventory_items/trophy_majors/velvet' }
		else { return 'debug/debugambientcube' }
	}

	$if prod {
		C.VMProtectEnd()
	}
}

fn get_material_id(for_material_name string) int {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.get_material_id')
	}

	match for_material_name {
		'debug/debugambientcube' { return 0 }
		'models/inventory_items/trophy_majors/gold' { return 1 }
		'models/player/ct_fbi/ct_fbi_glass' { return 2 }
		'models/gibs/glass/glass' { return 3 }
		'models/inventory_items/trophy_majors/crystal_clear' { return 4 }
		'models/inventory_items/trophy_majors/crystal_blue' { return 5 }
		'models/inventory_items/trophy_majors/velvet' { return 6 }
		else { return 0 }
	}

	$if prod {
		C.VMProtectEnd()
	}
}

struct Config {
pub mut:
	name string = 'golp'
	// others
	knife_changer bool = true

	bop bool = true

	spectator             bool        = true
	spectator_count_color utils.Color = utils.color_rbga(108, 92, 231, 255)
	spectators_color      utils.Color = utils.color_rbga(255, 255, 255, 255)

	killsound      bool = true
	killsound_type int  = 1 // default = woof (0)

	viewmodel_override     bool = true
	viewmodel_override_x   f32  = 7
	viewmodel_override_y   f32  = 7
	viewmodel_override_z   f32  = -7
	viewmodel_override_fov f32  = 80

	no_flash bool

	killsay bool = true
	// skins
	skins_changer bool        = true
	skins         []SkinEntry = [
		SkinEntry{
			definition_index: .weapon_knife_karambit
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
			is_knife: true
		},
		SkinEntry{
			definition_index: .weapon_ak47
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_m4a1_silencer
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_m4a1
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_famas
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_sg556
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_awp
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_ssg08
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_cz75a
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_deagle
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_usp_silencer
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_glock
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_elite
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_revolver
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_p250
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_mac10
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_mp9
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_nova
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_mag7
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_sawedoff
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_xm1014
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		},
		SkinEntry{
			definition_index: .weapon_hkp2000
			quality: 0
			paint_kit: 0
			wear: 0.0
			seed: 0
		}
	]
	// visuals
	glow                      bool        = true
	glow_color_if_visible     utils.Color = utils.color_rbga(236, 240, 241, 130)
	glow_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241, 130)

	box                      bool        = true
	box_color_if_visible     utils.Color = utils.color_rbga(1, 1, 1, 255)
	box_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241, 255)

	names                      bool        = true
	hp                         bool        = true
	names_color_if_visible     utils.Color = utils.color_rbga(1, 1, 1, 255)
	names_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241, 255)

	weapon_name                      bool
	weapon_clip                      bool
	weapon_name_color_if_visible     utils.Color = utils.color_rbga(1, 1, 1, 255)
	weapon_name_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241, 255)

	snapline                      bool
	snapline_color_if_visible     utils.Color = utils.color_rbga(1, 1, 1, 255)
	snapline_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241, 255)

	radar bool = true

	watermark       bool        = true
	watermark_color utils.Color = utils.color_rbga(236, 240, 241, 255)

	indicator              bool        = true
	indicator_color_if_on  utils.Color = utils.color_rbga(108, 92, 231, 255)
	indicator_color_if_off utils.Color = utils.color_rbga(236, 240, 241, 255)

	fov_circle       bool        = true
	fov_circle_color utils.Color = utils.color_rbga(155, 89, 182, 255)
	// chams
	chams                      bool
	chams_is_visible_only      bool
	chams_material             int // default = 0
	chams_color_if_visible     utils.Color = utils.color_rbga(20, 75, 97, 255)
	chams_color_if_not_visible utils.Color = utils.color_rbga(0, 0, 0, 50)
	// engine

	engine                  bool = true
	fov                     f32  = 20
	engine_adjust_fov_scope bool = true

	engine_bones_list    []int = [0, 8, 9, 6, 5]
	engine_force_bone_id int // default = 0
	engine_pref_bone_id  int = 8

	engine_automatic_fire_key int = 0x5
	engine_force_bone_key     int = 0x43
	engine_force_awall_key    int = 0x06

	engine_automatic_fire_key_toggle bool
	engine_force_awall_key_toggle    bool = true
	engine_force_bone_key_toggle     bool = true

	engine_vhv_mode      bool
	engine_vhv_aw_factor f32
}

struct ConfigManager {
pub mut:
	configs                 []Config = [Config{}]
	active_config           &Config  = unsafe { nil }
	active_config_idx       int
	selected_config_in_menu int
}

pub fn (mut c ConfigManager) bootstrap() {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.bootstrap')
	}

	home := os.home_dir()
	golphook_folder := '$home\\golphook'
	if !os.exists(golphook_folder) {
		os.mkdir(golphook_folder) or {
			utils.error_critical('Failed to create ressource configs', 'folder')
		}
	}

	configs_file := '$home\\golphook\\.configs'
	if !os.exists(configs_file) {
		os.write_file(configs_file, 'text string') or {
			utils.error_critical('Failed to create ressource configs', 'file')
		}
	}

	configs_file_content := os.read_file(configs_file) or {
		utils.error_critical('Failed to acces ressource configs', 'file')
		return
	}

	mut configs := json.decode([]Config, configs_file_content) or {
		unsafe {
			utils.msg_c('failed to read configs default one will be set', utils.color_rbga(255,
				255, 255, 255))
		}
		c.active_config = &c.configs[0]
		return
	}

	c.configs.clear()

	c.configs = configs
	c.configs[0] = Config{}
	c.active_config = &c.configs[0]

	$if prod {
		C.VMProtectEnd()
	}
}

pub fn (mut c ConfigManager) export(for_config_with_index int) string {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.export')
	}

	json := json.encode(c.configs[for_config_with_index])

	$if prod {
		C.VMProtectEnd()
	}

	return json
}

pub fn (mut c ConfigManager) import_fc(from_text string) {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.import_fc')
	}

	mut cfg := json.decode(Config, from_text) or {
		unsafe { utils.msg_c('failed to decode config', utils.color_rbga(255, 255, 255,
			255)) }
		return
	}

	// in this code base there are this kind of case where casting to an it make crash
	// and f32 is the only one which don't crash
	cfg.name = f32(c.configs.len + 1).str()
	c.configs << cfg

	$if prod {
		C.VMProtectEnd()
	}
}

pub fn (mut c ConfigManager) delete(for_config_with_index int) {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.delete')
	}

	if for_config_with_index == 0 {
		unsafe {
			utils.msg_c('cannot delete default config', utils.color_rbga(255, 255, 255,
				255))
		}
		return
	}
	if for_config_with_index == c.active_config_idx {
		c.change_to(0)
	}
	c.configs.delete(for_config_with_index)
	c.save()

	$if prod {
		C.VMProtectEnd()
	}
}

pub fn (mut c ConfigManager) save() {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.save')
	}

	json := json.encode_pretty(c.configs)
	home := os.home_dir()
	configs_file := '$home\\golphook\\.configs'
	os.write_file(configs_file, json) or {
		utils.error_critical('Failed to access ressource configs', 'file')
	}

	$if prod {
		C.VMProtectEnd()
	}
}

pub fn (mut c ConfigManager) rename(for_config_with_index int, with_new_name string) {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.rename')
	}

	if for_config_with_index == 0 {
		unsafe { utils.msg_c('cannot rename default config', utils.color_rbga(255, 255,
			255, 255)) }
		return
	}

	c.configs[for_config_with_index].name = with_new_name
	c.save()

	$if prod {
		C.VMProtectEnd()
	}
}

pub fn (mut c ConfigManager) new_blank(with_name string) {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.new_blank')
	}

	mut new_cfg := Config{}
	new_cfg.name = f32(c.configs.len + 1).str()
	if with_name.len != 0 {
		new_cfg.name = with_name
	}
	c.configs << new_cfg

	$if prod {
		C.VMProtectEnd()
	}
}

pub fn (mut c ConfigManager) change_to(for_config_with_index int) {
	$if prod {
		C.VMProtectBeginMutation(c'cfg.change_to')
	}

	mut app_ctx := unsafe { app() }

	if for_config_with_index == c.active_config_idx {
		return
	}

	// tmp fix to keep backward compatibility with old configs

	if c.configs[for_config_with_index].skins.len == 0 {
		c.configs[for_config_with_index].skins = c.configs[0].skins
		c.save()
	}

	app_ctx.is_ok = false
	c.active_config = &c.configs[for_config_with_index]
	c.active_config_idx = for_config_with_index
	app_ctx.is_ok = true

	$if prod {
		C.VMProtectEnd()
	}
}
