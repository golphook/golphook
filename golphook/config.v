module golphook

// export config is horrible but base64 module don't work in dlls
import utils
import json
import os


struct Config {
pub mut:
	name string = 'golp'
	// others

	bop bool = true

	spectator             bool        = true
	spectator_count_color utils.Color = utils.color_rbga(108, 92, 231, 255)
	spectators_color      utils.Color = utils.color_rbga(255, 255, 255, 255)
	// visuals

	box                      bool        = true
	box_color_if_visible     utils.Color = utils.color_rbga(1, 1, 1, 255)
	box_color_if_not_visible utils.Color = utils.color_rbga(236, 240, 241, 255)


	watermark       bool        = true
	watermark_color utils.Color = utils.color_rbga(236, 240, 241, 255)

	// engine
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
		unsafe {
			utils.msg_c('failed to decode config', utils.color_rbga(255, 255, 255, 255))
		}
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
		unsafe {
			utils.msg_c('cannot rename default config', utils.color_rbga(255, 255, 255,
				255))
		}
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

	app_ctx.is_ok = false
	c.active_config = &c.configs[for_config_with_index]
	c.active_config_idx = for_config_with_index
	app_ctx.is_ok = true

	$if prod {
		C.VMProtectEnd()
	}
}
