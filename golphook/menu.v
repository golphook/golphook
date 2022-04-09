module golphook

import utils
import math

struct Menu {
pub mut:
	is_open bool
	base_menu_pos utils.Vec3 = utils.new_vec2(37, 280).vec_3()
	items_count int = 0
	tab_items_count int = 0
	selected int = 0

	should_change bool
	should_increment bool
	should_decrement bool
}

fn (mut m Menu) item_bool(name string ,mut value &bool) {
	mut color := utils.color_rbga(255,255,255,255)
	if m.selected == m.items_count {
		color = utils.color_rbga(108, 92, 231, 255)
	}

	if m.should_change && m.selected == m.items_count {
		value = !(*value)
	}

	new_text(m.base_menu_pos + utils.new_vec2(m.base_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name:", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color).draw()
	new_text(m.base_menu_pos + utils.new_vec2(m.base_menu_pos.x + (m.items_count - m.tab_items_count)*15, 130).vec_3(), "${*value}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)).draw()
	m.items_count++
}

fn (mut m Menu) item_i<T>(name string ,mut value &T, step T, min T ,max T) {
	mut color := utils.color_rbga(255,255,255,255)
	if m.selected == m.items_count {
		color = utils.color_rbga(108, 92, 231, 255)
	}

	if m.selected == m.items_count {
		if m.should_increment {
			utils.pront("+")
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

	new_text(m.base_menu_pos + utils.new_vec2(m.base_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name:", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color).draw()
	new_text(m.base_menu_pos + utils.new_vec2(m.base_menu_pos.x + (m.items_count - m.tab_items_count)*15, 130).vec_3(), "${f32(*value)}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)).draw()
	m.items_count++
}

fn (mut m Menu) item_pair<T>(name string ,mut value &T, pairs []map[u32]string) {
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

	new_text(m.base_menu_pos + utils.new_vec2(m.base_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "$name:", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, color).draw()
	new_text(m.base_menu_pos + utils.new_vec2(m.base_menu_pos.x + (m.items_count - m.tab_items_count)*15, 130).vec_3(), "${new[new.keys()[0]]}", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)).draw()
	m.items_count++
}

fn (mut m Menu) sep(name string) {
	new_text(m.base_menu_pos + utils.new_vec2(m.base_menu_pos.x + (m.items_count - m.tab_items_count)*15, 0).vec_3(), "- $name", 12, true, true, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)).draw()
	m.base_menu_pos.x += 8
}

fn (mut m Menu) tab() {
	m.base_menu_pos.y += 200
	m.base_menu_pos.x = 37
	m.tab_items_count = m.items_count
}

fn (mut m Menu) handle_keys() {
	m.should_change = false
	m.should_increment = false
	m.should_decrement = false
	if (C.GetAsyncKeyState(C.VK_PRIOR) & 1) == 1 {
		if m.selected != 0 {
			m.selected--
		}
	}
	if (C.GetAsyncKeyState(C.VK_NEXT) & 1) == 1 {

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

	old := m.base_menu_pos

	m.sep("esp")

	m.item_bool("box", mut &app_ctx.config.active_config.box)
	m.item_bool("names", mut &app_ctx.config.active_config.names)
	if app_ctx.config.active_config.names {
		m.item_bool("health", mut &app_ctx.config.active_config.hp)
	}
	m.item_bool("glow", mut &app_ctx.config.active_config.glow)
	m.item_bool("snapline", mut &app_ctx.config.active_config.snapline)

	m.tab()
	m.sep("misc")
	m.item_bool("spectators", mut &app_ctx.config.active_config.spectator)
	m.item_bool("indicators", mut &app_ctx.config.active_config.indicator)
	m.item_bool("fov circle", mut &app_ctx.config.active_config.fov_circle)
	m.item_bool("bop", mut &app_ctx.config.active_config.bop)
	m.item_bool("knife changer", mut &app_ctx.config.active_config.knife_changer)
	if app_ctx.config.active_config.knife_changer {
		m.item_pair<int>("knife", mut &app_ctx.config.active_config.knife_type, [{u32(0): "karambit"}, {u32(1): "m9"}, {u32(2): "butterfly"}])
	}

	m.tab()
	m.sep("engine")
	m.item_bool("engine", mut &app_ctx.config.active_config.engine)
	m.item_i<f32>("fov", mut &app_ctx.config.active_config.fov, 1, 0, 300)
	m.item_pair<u32>("as key", mut &app_ctx.config.active_config.engine_automatic_fire_key, [{u32(0x5): "mouse 4"}, {u32(0x01): "mouse 1"}])
	m.item_pair<u32>("fb key", mut &app_ctx.config.active_config.engine_force_bone_key, [{u32(0x58): "X"}, {u32(0x43): "C"}, {u32(0x42): "B"}])

	m.handle_keys()
	m.items_count = 0
	m.tab_items_count = 0
	m.base_menu_pos = old

}


fn (mut m Menu) on_send_scene() {
	mut app_ctx := unsafe { app() }

	if (C.GetAsyncKeyState(C.VK_HOME) & 1) == 1 {
		m.is_open = !m.is_open
	}

	if m.is_open {

		m.render()
	}
}
