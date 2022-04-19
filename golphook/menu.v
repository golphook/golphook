module golphook

import utils
import math
import clipboard
import os

import offsets

struct Menu {
pub mut:
	is_open bool
	base_menu_pos utils.Vec3 = utils.new_vec2(37, 280).vec_3()
	relative_menu_pos utils.Vec3
	items_count int
	tab_items_count int
	selected int

	in_menu bool
	in_secret_menu_enabled bool

	should_change bool
	should_increment bool
	should_decrement bool
}

fn (mut m Menu) item_bool(name string ,mut value &bool) {
	mut app_ctx := unsafe { app() }
	mut color := utils.color_rbga(255,255,255,255)
	if m.selected == m.items_count {
		color = utils.color_rbga(108, 92, 231, 255)
	}

	if m.should_change && m.selected == m.items_count {
		value = !(*value)
	}

	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name:", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color))
	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 130).vec_3(), "${*value}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	m.items_count++
}

fn (mut m Menu) item_i<T>(name string ,mut value &T, step T, min T ,max T) {
	mut app_ctx := unsafe { app() }
	mut color := utils.color_rbga(255,255,255,255)
	if m.selected == m.items_count {
		color = utils.color_rbga(108, 92, 231, 255)
	}

	if m.selected == m.items_count {
		if m.should_increment {
			if value < max {
				value = (*value) + step
			}
		}
		if m.should_decrement {
			if value > min {
				value = (*value) - step
			}
		}
	}

	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name:", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color))
	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 130).vec_3(), "${f32(*value)}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	m.items_count++
}

fn (mut m Menu) item_pair<T>(name string ,mut value &T, pairs []map[u32]string) {
	mut app_ctx := unsafe { app() }
	mut color := utils.color_rbga(255,255,255,255)
	if m.selected == m.items_count {
		color = utils.color_rbga(108, 92, 231, 255)
	}

	mut current_index := 0
	for i,v in pairs {
		if *value in v.keys() {
			current_index = i
			break
		}
	}

	mut new := pairs[current_index].clone()

	if m.selected == m.items_count {

		if m.should_increment {
			if (current_index + 1) < pairs.len {
				new = pairs[current_index + 1].clone()
			}
		}
		if m.should_decrement {
			if (current_index - 1) >= 0 {
				new = pairs[current_index - 1].clone()
			}
		}
	}

	value = new.keys()[0]

	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name:", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color))
	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 130).vec_3(), "${new[new.keys()[0]]}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	m.items_count++
}

fn (mut m Menu) item_pair_callback<T>(name string ,mut value &T, pairs []map[u32]string, callback fn (&App)) {
	mut app_ctx := unsafe { app() }
	mut color := utils.color_rbga(255,255,255,255)
	if m.selected == m.items_count {
		color = utils.color_rbga(108, 92, 231, 255)
	}

	mut current_index := 0
	for i,v in pairs {
		if *value in v.keys() {
			current_index = i
			break
		}
	}

	mut new := pairs[current_index].clone()

	if m.selected == m.items_count {

		if m.should_increment {
			if (current_index + 1) < pairs.len {
				new = pairs[current_index + 1].clone()
			}
		}
		if m.should_decrement {
			if (current_index - 1) >= 0 {
				new = pairs[current_index - 1].clone()
			}
		}
	}

	if m.should_change && m.selected == m.items_count {
		callback(app_ctx)
	}


	value = new.keys()[0]

	mut selected_color := utils.color_rbga(255,255,255,255)
	if current_index == app_ctx.config.active_config_idx {
		selected_color = utils.color_rbga(108, 92, 231, 255)
	}

	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name:", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color))
	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 130).vec_3(), "${new[new.keys()[0]]}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, selected_color))
	m.items_count++
}

fn (mut m Menu) sep(name string) {
	mut app_ctx := unsafe { app() }
	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "- $name", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	m.relative_menu_pos.x += 8
}

fn (mut m Menu) tab() {
	m.relative_menu_pos.y += 200
	m.relative_menu_pos.x = m.base_menu_pos.x
	m.tab_items_count = m.items_count
}

fn (mut m Menu) item_callback(name string , callback fn (&App)) {
	mut app_ctx := unsafe { app() }
	mut color := utils.color_rbga(255,255,255,255)
	if m.selected == m.items_count {
		color = utils.color_rbga(108, 92, 231, 255)
	}

	if m.should_change && m.selected == m.items_count {
		callback(app_ctx)
	}

	app_ctx.rnd_queue.push(new_text(m.relative_menu_pos + utils.new_vec2(m.relative_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color))
	m.items_count++
}
fn (mut m Menu) handle_keys() {
	m.should_change = false
	m.should_increment = false
	m.should_decrement = false
	if (C.GetAsyncKeyState(C.VK_UP) & 1) == 1 {
		if m.selected != 0 {
			m.selected--
		}
	}
	if (C.GetAsyncKeyState(C.VK_DOWN) & 1) == 1 {

		if m.selected < m.items_count - 1 {
			m.selected++
		}
	}
	if (C.GetAsyncKeyState(C.VK_RETURN) & 1) == 1 {

		m.should_change = true
	}

	if (C.GetAsyncKeyState(C.VK_RIGHT) & 1) == 1 {

		m.should_increment = true
	}

	if (C.GetAsyncKeyState(C.VK_LEFT) & 1) == 1 {

		m.should_decrement = true
	}
}

fn (mut m Menu) render() {
	mut app_ctx := unsafe { app() }

	old := m.relative_menu_pos

	m.sep("esp")

	m.item_bool("box", mut &app_ctx.config.active_config.box)
	m.item_bool("names", mut &app_ctx.config.active_config.names)
	if app_ctx.config.active_config.names {
		m.item_bool("health", mut &app_ctx.config.active_config.hp)
	}
	m.item_bool("glow", mut &app_ctx.config.active_config.glow)
	m.item_bool("snapline", mut &app_ctx.config.active_config.snapline)
	m.item_bool("radar", mut &app_ctx.config.active_config.radar)

	m.tab()
	m.sep("misc")
	m.item_bool("spectators", mut &app_ctx.config.active_config.spectator)
	m.item_bool("indicators", mut &app_ctx.config.active_config.indicator)
	m.item_bool("fov circle", mut &app_ctx.config.active_config.fov_circle)
	m.item_bool("bop", mut &app_ctx.config.active_config.bop)
	m.item_bool("knife changer", mut &app_ctx.config.active_config.knife_changer)
	if app_ctx.config.active_config.knife_changer {
		m.item_pair<int>("knife", mut &app_ctx.config.active_config.knife_type, [{u32(0): "karambit"}, {u32(1): "m9"}, {u32(2): "butterfly"}, {u32(3): "flop"}, {u32(4): "gut"}, {u32(5): "bayonet"}])
	}
	m.item_bool("viewmodel", mut &app_ctx.config.active_config.viewmodel_override)
	if app_ctx.config.active_config.viewmodel_override {
		m.item_i<f32>("x", mut &app_ctx.config.active_config.viewmodel_override_x, 1, -20, 20)
		m.item_i<f32>("y", mut &app_ctx.config.active_config.viewmodel_override_y, 1, -20, 20)
		m.item_i<f32>("z", mut &app_ctx.config.active_config.viewmodel_override_z, 1, -20, 20)
		m.item_i<f32>("fov", mut &app_ctx.config.active_config.viewmodel_override_fov, 1, -200, 200)
	}
	m.item_bool("killsound", mut &app_ctx.config.active_config.killsound)

	m.tab()
	m.sep("engine")
	m.item_bool("engine", mut &app_ctx.config.active_config.engine)
	m.item_i<f32>("fov", mut &app_ctx.config.active_config.fov, 1, 0, 300)
	m.item_pair<u32>("as key", mut &app_ctx.config.active_config.engine_automatic_fire_key, [{u32(0x5): "mouse 4"}, {u32(0x01): "mouse 1"}, {u32(0x12): "alt"}, {u32(0x06): "mouse 5"}])
	m.item_pair<u32>("aw key", mut &app_ctx.config.active_config.engine_force_awall_key, [{u32(0x5): "mouse 4"}, {u32(0x01): "mouse 1"}, {u32(0x12): "alt"}, {u32(0x06): "mouse 5"}])
	m.item_pair<u32>("fb key", mut &app_ctx.config.active_config.engine_force_bone_key, [{u32(0x58): "X"}, {u32(0x43): "C"}, {u32(0x42): "B"}, {u32(0x5): "mouse 4"}, {u32(0x06): "mouse 5"}, {u32(0x41): "mouse 5"}])
	if m.in_secret_menu_enabled {
		m.sep("secret")
		m.item_bool("crossfire", mut &app_ctx.config.active_config.crossfire)
	}

	m.tab()
	m.sep("config")
	mut configs := []map[u32]string{}{}
	for i, c in app_ctx.config.configs {
		configs << {u32(i): c.name}
	}
	m.item_pair_callback<u32>("configs", mut &app_ctx.config.selected_config_in_menu, configs, fn (mut app_ctx &App) {
		app_ctx.config.change_to(int(app_ctx.config.selected_config_in_menu))
	})

	m.item_callback("import", fn (mut app_ctx &App) {
		mut c := clipboard.new()
		app_ctx.config.import_fc(c.get_text())
	})
	m.item_callback("export", fn (mut app_ctx &App) {
		mut c := clipboard.new()
		exported_cfg := app_ctx.config.export(int(app_ctx.config.selected_config_in_menu))
		unsafe { utils.msg_c(utils.color_rbga(108, 92, 231, 255), exported_cfg) }
		c.copy(exported_cfg)
	})
	m.item_callback("save", fn (mut app_ctx &App) {
		app_ctx.config.save()
	})
	m.item_callback("delete", fn (mut app_ctx &App) {
		app_ctx.config.delete(int(app_ctx.config.selected_config_in_menu))
	})

	m.handle_keys()
	m.items_count = 0
	m.tab_items_count = 0
	m.relative_menu_pos = old

}


fn (mut m Menu) on_send_scene() {
	mut app_ctx := unsafe { app() }
	if (C.GetAsyncKeyState(C.VK_DELETE) & 1) == 1 {
		m.is_open = !m.is_open
		if C.GetAsyncKeyState(0x4F) > 1 {
			C.Beep(670, 100)
			m.in_secret_menu_enabled = !m.in_secret_menu_enabled
		}
	}


	m.relative_menu_pos = m.base_menu_pos
	m.in_menu = false
	mut save := m.base_menu_pos
	if !(app_ctx.interfaces.cdll_int.is_in_game() && app_ctx.interfaces.cdll_int.is_connected()) {
		m.base_menu_pos.y += 570
		m.base_menu_pos.x -= 11
		m.relative_menu_pos = m.base_menu_pos
		m.in_menu = true
	}

	if m.is_open {

		m.render()
	}

	m.base_menu_pos = save
}
