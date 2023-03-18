module golphook

// export config is horrible but base64 module don't work in dlls
import utils
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
	$if vm ? {
		C.VMProtectBeginMutation(c'cfg.bootstrap')
	}

	c.configs[0] = Config{}
	c.active_config = &c.configs[0]

	$if vm ? {
		C.VMProtectEnd()
	}
}
