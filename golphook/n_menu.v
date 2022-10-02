module golphook

// nuklear is my favourite ui lib even it was so long to wrap it

import nuklear
import utils
import clipboard

const menu_height = 212.0
const menu_width = 512.0
const item_height = 15

enum MenuTab {
	visuals
	misc
	engine
	config
}

struct NMenu {
pub mut:
	nk_ctx nuklear.Nuklear

	is_opened bool

	tabs []bool = [false, false, false, false]
	current_tab MenuTab = .visuals

	tmp_check bool

	killsounds []map[string]int = [{"woof": 0}, {"crossfire": 1}]
	configs []map[string]int = []
	engine_keys []map[string]int = [{"mouse 1": 0x1}, {"mouse 4": 0x5}, {"mouse 5": 0x06}, {"alt": 0x12}, {"b": 0x42}, {"c": 0x43}, {"x": 0x58}]
	engine_bones []map[string]int = [{"head": 8}, {"body": 5}, {"pelvis": 0}]

	chams_materials []map[string]int = [{"ambientcube": 0}, {"gold": 1}, {"ct_fbi_glass": 2}, {"glass": 3}, {"crystal_clear": 4}, {"crystal_blue": 5}, {"velvet": 6}]

	weapons_names []map[string]int = [
		{"knife": 0},

		{"ak": 1},
		{"m4a1": 2},
		{"m4a4": 3},
		{"famas": 4},
		{"kreig": 5},
		{"awp": 6},
		{"scout": 7},
		{"cz": 8},
		{"deagle": 9},
		{"usp": 10},
		{"p2k": 21}
		{"glock": 11},
		{"dualies": 12},
		{"revolver": 13},
		{"p250": 14},
		{"mac10": 15},
		{"mp9": 16},
		{"nova": 17},
		{"mag7": 18},
		{"sawed-off": 19},
		{"xm": 20},
	]
	knifes []map[string]int = [
		{"karambit": 507},
		{"m9": 508},
		{"butterfly": 515},
		{"flop": 505},
		{"gaut": 506},
		{"mayonet": 500},
		{"hunt": 509},
		{"navaja": 520}
		{"classic": 503}
	]
	item_quality []map[string]int = [
		{"normal": 0},
		{"genuine": 1},
		{"vintage": 2},
		{"unusual": 3},
		{"community": 5},
		{"developer": 6},
		{"self-made": 7},
		{"customized": 8},
		{"strange": 9},
		{"completed": 10},
		{"tournament": 12}
	]

	tmp_rename_buff [64]char
	tmp_rename_len int

}

fn (mut m NMenu) bootstrap(dev voidptr) {
	
	$if prod { C.VMProtectBeginMutation(c"menu.bootstrap") }

	mut app_ctx := unsafe { app() }

	m.nk_ctx.bootstrap(dev, app_ctx.wnd_width, app_ctx.wnd_height)

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) release(isReset bool) {

	$if prod { C.VMProtectBeginMutation(c"menu.release") }

	mut app_ctx := unsafe { app() }

	m.is_opened = false

	if !isReset {
		C.SetWindowLongA( C.FindWindowA(c"Valve001", &char(0)), -4, i32(app_ctx.hooks.wnd_proc.original_save))
	}

	m.nk_ctx.release()

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) on_send_scene() {

	$if prod { C.VMProtectBeginMutation(c"menu.on_end_scene") }

	if m.is_opened {
		m.render()
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) apply_style() {

	$if prod { C.VMProtectBeginMutation(c"mneu.apply_style") }

	mut col_table := []C.nk_color{len: C.NK_COLOR_COUNT}

	col_table[C.NK_COLOR_TEXT] = C.nk_color{171, 158, 179, 255}
    col_table[C.NK_COLOR_BORDER] = C.nk_color{0, 0, 0, 0}
    col_table[C.NK_COLOR_WINDOW] = C.nk_color{39, 33, 42, 255}
    col_table[C.NK_COLOR_BUTTON] = C.nk_color{63, 53, 68, 255}
    col_table[C.NK_COLOR_BUTTON_HOVER] = C.nk_color{65, 57, 73, 255}
    col_table[C.NK_COLOR_BUTTON_ACTIVE] = C.nk_color{52, 44, 56, 255}
    col_table[C.NK_COLOR_TOGGLE] = C.nk_color{63, 53, 68, 255}
    col_table[C.NK_COLOR_TOGGLE_HOVER] = C.nk_color{65, 57, 73, 255}
    col_table[C.NK_COLOR_TOGGLE_CURSOR] = C.nk_color{52, 44, 56, 255}
    col_table[C.NK_COLOR_SELECT] = C.nk_color{63, 53, 68, 255}
    col_table[C.NK_COLOR_SELECT_ACTIVE] = C.nk_color{63, 53, 68, 255}
    col_table[C.NK_COLOR_PROPERTY] = C.nk_color{63, 53, 68, 255}
    col_table[C.NK_COLOR_EDIT] = C.nk_color{63, 53, 68, 255}
    col_table[C.NK_COLOR_COMBO] = C.nk_color{63, 53, 68, 255}

	m.nk_ctx.style_from_table(col_table.data)

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) menu_item(itemName string, itemId int) {

	$if prod { C.VMProtectBeginMutation(c"menu.menu_item") }

	if m.nk_ctx.selectable_label(itemName, C.NK_TEXT_CENTERED, &m.tabs[itemId]) {

		for mut item in m.tabs {
			item = false
		}
		m.tabs[itemId] = true

		match itemId {
			0 { m.current_tab = .visuals }
			1 { m.current_tab = .misc }
			2 { m.current_tab = .engine }
			3 { m.current_tab = .config }
			else {}
		}

	}

	$if prod { C.VMProtectEnd() }
}


fn (mut m NMenu) menu_bar() {

	$if prod { C.VMProtectBeginMutation(c"menu.menu_bar") }

	m.nk_ctx.layout_row_dynamic(item_height, 4)

	m.menu_item("visuals", 0)
	m.menu_item("misc", 1)
	m.menu_item("engine", 2)
	m.menu_item("config", 3)

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) table_combo(mut val &int, mut table []map[string]int, callback fn (&App)) {

	$if prod { C.VMProtectBeginMutation(c"menu.table_combo") }

	mut app_ctx := unsafe { app() }

	combo_vec := C.nk_vec2{x:m.nk_ctx.widget_width(), y:200.0}

	mut current_index := 0
	for idx,v_map in table {
		if v_map[v_map.keys()[0]] == *val {
			current_index = idx
		}
	}

	if m.nk_ctx.combo_begin_label(table[current_index].keys()[0], combo_vec) {
		m.nk_ctx.layout_row_dynamic(item_height, 1)

		for mut v_map in table {
			if m.nk_ctx.combo_item_label(v_map.keys()[0], C.NK_TEXT_LEFT) {
				val = v_map[v_map.keys()[0]]
				callback(app_ctx)
			}
		}
		m.nk_ctx.combo_end()
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) color_picker(mut col &utils.Color) {

	$if prod { C.VMProtectBeginMutation(c"menu.color_picker") }

	mut tmp_colf := col.nk_colorf()

	color_vec := C.nk_vec2{300, 400}
	if m.nk_ctx.combo_begin_color(C.nk_rgb_cf(tmp_colf), color_vec) {
		m.nk_ctx.layout_row_dynamic(80, 1)

		tmp_colf = m.nk_ctx.color_picker(tmp_colf, C.NK_RGBA)
		mut tmp_nk_color := C.nk_rgba_f(tmp_colf.r, tmp_colf.g, tmp_colf.b, tmp_colf.a)
		col = utils.color_rbga(tmp_nk_color.r, tmp_nk_color.g, tmp_nk_color.b, tmp_nk_color.a)

		m.nk_ctx.layout_row_dynamic(item_height, 1)

		tmp_nk_color.r = m.nk_ctx.propertyi("#R:", 0, tmp_nk_color.r, 255, 1, 1)
		tmp_nk_color.g = m.nk_ctx.propertyi("#G:", 0, tmp_nk_color.g, 255, 1, 1)
		tmp_nk_color.b = m.nk_ctx.propertyi("#B:", 0, tmp_nk_color.b, 255, 1, 1)
		tmp_nk_color.a = m.nk_ctx.propertyi("#A:", 0, tmp_nk_color.a, 255, 1, 1)

		col = utils.color_rbga(tmp_nk_color.r, tmp_nk_color.g, tmp_nk_color.b, tmp_nk_color.a)

		m.nk_ctx.combo_end()
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) tab_visuals() {

	$if prod { C.VMProtectBeginMutation(c"menu.tab_visuals") }

	mut app_ctx := unsafe { app() }

	m.nk_ctx.layout_row_dynamic(menu_height-41, 2)

	if m.nk_ctx.group_begin("visuals_1", C.NK_WINDOW_NO_SCROLLBAR) {
		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("box", mut &app_ctx.config.active_config.box)

		if app_ctx.config.active_config.box {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.box_color_if_visible)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.box_color_if_not_visible)
		}

		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("snapline", mut &app_ctx.config.active_config.snapline)

		if app_ctx.config.active_config.snapline {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.snapline_color_if_visible)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.snapline_color_if_not_visible)
		}

		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("names", mut &app_ctx.config.active_config.names)

		if app_ctx.config.active_config.names {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.names_color_if_visible)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.names_color_if_not_visible)
		}

		m.nk_ctx.layout_row_end()

		if app_ctx.config.active_config.names {
			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
			m.nk_ctx.layout_row_push(1.0)
			m.nk_ctx.checkbox_label("health", mut &app_ctx.config.active_config.hp)
			m.nk_ctx.layout_row_end()
		}

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("weapon name", mut &app_ctx.config.active_config.weapon_name)

		if app_ctx.config.active_config.weapon_name {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.weapon_name_color_if_visible)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.weapon_name_color_if_not_visible)
		}

		m.nk_ctx.layout_row_end()

		if app_ctx.config.active_config.weapon_name {
			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
			m.nk_ctx.layout_row_push(1.0)
			m.nk_ctx.checkbox_label("clip", mut &app_ctx.config.active_config.weapon_clip)
			m.nk_ctx.layout_row_end()
		}

		m.nk_ctx.group_end()
	}

	if m.nk_ctx.group_begin("visuals_2", C.NK_WINDOW_NO_SCROLLBAR) {
		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("glow", mut &app_ctx.config.active_config.glow)

		if app_ctx.config.active_config.glow {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.glow_color_if_visible)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.glow_color_if_not_visible)
		}

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("chams", mut &app_ctx.config.active_config.chams)

		if app_ctx.config.active_config.chams {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.chams_color_if_visible)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.chams_color_if_not_visible)
		}

		m.nk_ctx.layout_row_end()

		if app_ctx.config.active_config.chams {
			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
			m.nk_ctx.layout_row_push(0.6)
			m.nk_ctx.label("material", C.NK_TEXT_LEFT)
			if app_ctx.config.active_config.killsound {
				m.nk_ctx.layout_row_push(0.4)
				m.table_combo(mut &app_ctx.config.active_config.chams_material, mut m.chams_materials, fn (mut app_ctx &App) {})
			}
			m.nk_ctx.layout_row_end()

			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
			m.nk_ctx.layout_row_push(1)
			m.nk_ctx.checkbox_label("visible only", mut &app_ctx.config.active_config.chams_is_visible_only)
			m.nk_ctx.layout_row_end()
		}

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.checkbox_label("radar", mut &app_ctx.config.active_config.radar)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.group_end()
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) tab_misc() {

	$if prod { C.VMProtectBeginMutation(c"menu.tab_misc") }

	mut app_ctx := unsafe { app() }

	m.nk_ctx.layout_row_dynamic(menu_height-41, 2)

	if m.nk_ctx.group_begin("misc_1", C.NK_WINDOW_NO_SCROLLBAR) {
		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.checkbox_label("viewmodel", mut &app_ctx.config.active_config.viewmodel_override)
		m.nk_ctx.layout_row_end()

		if app_ctx.config.active_config.viewmodel_override {
			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
			m.nk_ctx.layout_row_push(0.5)
			m.nk_ctx.property_float("x", -20, &app_ctx.config.active_config.viewmodel_override_x, 20, 0.2, 0.2)
			m.nk_ctx.layout_row_push(0.5)
			m.nk_ctx.property_float("y", -20, &app_ctx.config.active_config.viewmodel_override_y, 20, 0.2, 0.2)
			m.nk_ctx.layout_row_end()

			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
			m.nk_ctx.layout_row_push(0.5)
			m.nk_ctx.property_float("z", -20, &app_ctx.config.active_config.viewmodel_override_z, 20, 0.2, 0.2)
			m.nk_ctx.layout_row_push(0.5)
			m.nk_ctx.property_float("fov", -200, &app_ctx.config.active_config.viewmodel_override_fov, 200, 1, 1.0)
			m.nk_ctx.layout_row_end()
		}

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.checkbox_label("bop", mut &app_ctx.config.active_config.bop)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
		m.nk_ctx.layout_row_push(0.6)
		m.nk_ctx.checkbox_label("killsound", mut &app_ctx.config.active_config.killsound)
		if app_ctx.config.active_config.killsound {
			m.nk_ctx.layout_row_push(0.4)
			m.table_combo(mut &app_ctx.config.active_config.killsound_type, mut m.killsounds, fn (mut app_ctx &App) {})
		}
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.checkbox_label("killsay", mut &app_ctx.config.active_config.killsay)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1)
		m.nk_ctx.checkbox_label("no flash", mut &app_ctx.config.active_config.no_flash)
		m.nk_ctx.layout_row_end()



		m.nk_ctx.group_end()
	}

	if m.nk_ctx.group_begin("misc_2", C.NK_WINDOW_NO_SCROLLBAR) {
		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("spectators", mut &app_ctx.config.active_config.spectator)

		if app_ctx.config.active_config.spectator {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.spectator_count_color)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.spectators_color)
		}

		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.4)
		m.nk_ctx.checkbox_label("indicators", mut &app_ctx.config.active_config.indicator)

		if app_ctx.config.active_config.indicator {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.indicator_color_if_on)

			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.indicator_color_if_off)
		}

		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
		m.nk_ctx.layout_row_push(0.7)
		m.nk_ctx.checkbox_label("fov circle", mut &app_ctx.config.active_config.fov_circle)

		if app_ctx.config.active_config.fov_circle {
			m.nk_ctx.layout_row_push(0.3)
			m.color_picker(mut &app_ctx.config.active_config.fov_circle_color)
		}


		m.nk_ctx.layout_row_end()

		m.nk_ctx.group_end()
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) tab_engine() {

	$if prod { C.VMProtectBeginMutation(c"menu.tab_engine") }

	mut app_ctx := unsafe { app() }

	m.nk_ctx.layout_row_dynamic(menu_height-41, 2)

	if m.nk_ctx.group_begin("engine_1", C.NK_WINDOW_NO_SCROLLBAR) {
		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.checkbox_label("engine", mut &app_ctx.config.active_config.engine)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.property_float("fov", 0, &app_ctx.config.active_config.fov, 670, 1, 1)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.checkbox_label("adjust fov by scope", mut &app_ctx.config.active_config.engine_adjust_fov_scope)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.5)
		mut toggled := if app_ctx.config.active_config.engine_automatic_fire_key_toggle { "toggle" } else { "press" }
		m.nk_ctx.label("as key ($toggled)", C.NK_TEXT_LEFT)
		m.nk_ctx.layout_row_push(0.45)
		m.table_combo(mut &app_ctx.config.active_config.engine_automatic_fire_key, mut m.engine_keys, fn (mut app_ctx &App) {})
		m.nk_ctx.layout_row_push(0.05)
		m.nk_ctx.checkbox_label("1", mut &app_ctx.config.active_config.engine_automatic_fire_key_toggle)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.5)
		toggled = if app_ctx.config.active_config.engine_force_awall_key_toggle { "toggle" } else { "press" }
		m.nk_ctx.label("nwc key ($toggled)", C.NK_TEXT_LEFT)
		m.nk_ctx.layout_row_push(0.45)
		m.table_combo(mut &app_ctx.config.active_config.engine_force_awall_key, mut m.engine_keys, fn (mut app_ctx &App) {})
		m.nk_ctx.layout_row_push(0.05)
		m.nk_ctx.checkbox_label("2", mut &app_ctx.config.active_config.engine_force_awall_key_toggle)
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 3)
		m.nk_ctx.layout_row_push(0.5)
		toggled = if app_ctx.config.active_config.engine_force_bone_key_toggle { "toggle" } else { "press" }
		m.nk_ctx.label("fb key ($toggled)", C.NK_TEXT_LEFT)
		m.nk_ctx.layout_row_push(0.45)
		m.table_combo(mut&app_ctx.config.active_config.engine_force_bone_key, mut m.engine_keys, fn (mut app_ctx &App) {})
		m.nk_ctx.layout_row_push(0.05)
		m.nk_ctx.checkbox_label("3", mut &app_ctx.config.active_config.engine_force_bone_key_toggle)
		m.nk_ctx.layout_row_end()


		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
		m.nk_ctx.layout_row_push(0.6)
		m.nk_ctx.label("prefered bone", C.NK_TEXT_LEFT)
		m.nk_ctx.layout_row_push(0.4)
		m.table_combo(mut &app_ctx.config.active_config.engine_pref_bone_id, mut m.engine_bones, fn (mut app_ctx &App) {})
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
		m.nk_ctx.layout_row_push(0.6)
		m.nk_ctx.label("force bone", C.NK_TEXT_LEFT)
		m.nk_ctx.layout_row_push(0.4)
		m.table_combo(mut &app_ctx.config.active_config.engine_force_bone_id, mut m.engine_bones, fn (mut app_ctx &App) {})
		m.nk_ctx.layout_row_end()

		m.nk_ctx.group_end()
	}

	if m.nk_ctx.group_begin("engine_2", C.NK_WINDOW_NO_SCROLLBAR) {

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
		m.nk_ctx.layout_row_push(1.0)
		m.nk_ctx.checkbox_label("vhv mode", mut &app_ctx.config.active_config.engine_vhv_mode)
		m.nk_ctx.layout_row_end()

		if app_ctx.config.active_config.engine_vhv_mode {
			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
			m.nk_ctx.layout_row_push(1.0)
			m.nk_ctx.property_float("legit aw factor", 0, &app_ctx.config.active_config.engine_vhv_aw_factor, 17, 0.1, 0.1)
			m.nk_ctx.layout_row_end()
		}

		m.nk_ctx.group_end()
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) tab_config() {

	$if prod { C.VMProtectBeginMutation(c"menu.tab_config") }

	mut app_ctx := unsafe { app() }

	m.configs.clear()
	for idx, cfg in app_ctx.config.configs {
		m.configs << {cfg.name: idx}
	}

	m.nk_ctx.layout_row_dynamic(menu_height-41, 2)

	if m.nk_ctx.group_begin("cfg_1", C.NK_WINDOW_NO_SCROLLBAR) {


		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
		m.nk_ctx.layout_row_push(0.6)
		m.nk_ctx.label("configs", C.NK_TEXT_LEFT)
		m.nk_ctx.layout_row_push(0.4)
		m.table_combo(mut &app_ctx.config.selected_config_in_menu, mut m.configs, fn (mut app_ctx &App) {
			app_ctx.config.change_to(app_ctx.config.selected_config_in_menu)
		})
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 4)
		m.nk_ctx.layout_row_push(0.25)
		if m.nk_ctx.button_label("import") {
			mut c := clipboard.new()
			app_ctx.config.import_fc(c.get_text())
		}
		m.nk_ctx.layout_row_push(0.25)
		if m.nk_ctx.button_label("export") {
			mut c := clipboard.new()
			exported_cfg := app_ctx.config.export(app_ctx.config.selected_config_in_menu)
			unsafe { utils.msg_c(exported_cfg, utils.color_rbga(108, 92, 231, 255)) }
			c.copy(exported_cfg)
		}
		m.nk_ctx.layout_row_push(0.25)
		if m.nk_ctx.button_label("save") {
			app_ctx.config.save()
		}
		m.nk_ctx.layout_row_push(0.25)
		if m.nk_ctx.button_label("delete") {
			app_ctx.config.delete(app_ctx.config.selected_config_in_menu)
		}
		m.nk_ctx.layout_row_end()

		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, 19, 2)
		m.nk_ctx.layout_row_push(0.48)
		m.nk_ctx.edit_string(C.NK_EDIT_SIMPLE, &m.tmp_rename_buff[0], &m.tmp_rename_len, 17, C.nk_filter_default)
		m.nk_ctx.layout_row_push(0.25)
		if m.nk_ctx.button_label("rename") {
			new_name := unsafe { ((&m.tmp_rename_buff[0]).vstring_with_len(m.tmp_rename_len)).clone() }
			app_ctx.config.rename(app_ctx.config.selected_config_in_menu, new_name)
		}
		m.nk_ctx.layout_row_push(0.25)
		if m.nk_ctx.button_label("new") {
			new_name := unsafe { ((&m.tmp_rename_buff[0]).vstring_with_len(m.tmp_rename_len)).clone() }
			app_ctx.config.new_blank(new_name)
		}
		m.nk_ctx.layout_row_end()

		m.nk_ctx.group_end()
	}

	if m.nk_ctx.group_begin("cfg_2", C.NK_WINDOW_NO_SCROLLBAR) {
		m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
		m.nk_ctx.layout_row_push(0.6)
		m.nk_ctx.checkbox_label("skins changer", mut &app_ctx.config.active_config.skins_changer)
		if app_ctx.config.active_config.knife_changer {
			m.nk_ctx.layout_row_push(0.4)
			m.table_combo(mut &app_ctx.skins.current_selected_in_menu, mut m.weapons_names, fn (mut app_ctx &App) {})
		}
		m.nk_ctx.layout_row_end()

		if app_ctx.config.active_config.skins_changer {
			if app_ctx.skins.current_selected_in_menu == 0 {
				m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
				m.nk_ctx.layout_row_push(0.6)
				m.nk_ctx.label("knife", C.NK_TEXT_LEFT)
				if app_ctx.config.active_config.knife_changer {
					m.nk_ctx.layout_row_push(0.4)
					unsafe { m.table_combo(mut &int(&app_ctx.config.active_config.skins[0].definition_index), mut m.knifes, fn (mut app_ctx &App) {}) }
				}
				m.nk_ctx.layout_row_end()
			}

			if app_ctx.skins.current_selected_in_menu == 1 {
				m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
				m.nk_ctx.layout_row_push(0.6)
				m.nk_ctx.label("knife", C.NK_TEXT_LEFT)
				if app_ctx.config.active_config.knife_changer {
					m.nk_ctx.layout_row_push(0.4)
					unsafe { m.table_combo(mut &int(&app_ctx.config.active_config.skins[1].definition_index), mut m.knifes, fn (mut app_ctx &App) {}) }
				}
				m.nk_ctx.layout_row_end()
			}

			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
			m.nk_ctx.layout_row_push(1)
			m.nk_ctx.property_float("wear", 0, &app_ctx.config.active_config.skins[app_ctx.skins.current_selected_in_menu].wear, 1, 0.01, 0.01)
			m.nk_ctx.layout_row_end()

			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
			m.nk_ctx.layout_row_push(1)
			m.nk_ctx.property_int("paint kit", 0, &app_ctx.config.active_config.skins[app_ctx.skins.current_selected_in_menu].paint_kit, 10_000, 1, 1)
			m.nk_ctx.layout_row_end()

			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 1)
			m.nk_ctx.layout_row_push(1)
			m.nk_ctx.property_int("seed", 0, &app_ctx.config.active_config.skins[app_ctx.skins.current_selected_in_menu].seed, 1000, 1, 1)
			m.nk_ctx.layout_row_end()

			m.nk_ctx.layout_row_begin(C.NK_DYNAMIC, item_height, 2)
			m.nk_ctx.layout_row_push(0.6)
			m.nk_ctx.label("quality", C.NK_TEXT_LEFT)
			if app_ctx.config.active_config.knife_changer {
				m.nk_ctx.layout_row_push(0.4)
				unsafe { m.table_combo(mut &int(&app_ctx.config.active_config.skins[app_ctx.skins.current_selected_in_menu].quality), mut m.item_quality, fn (mut app_ctx &App) {}) }
			}
			m.nk_ctx.layout_row_end()
		}

		m.nk_ctx.group_end()
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut m NMenu) render() {

	$if prod { C.VMProtectBeginMutation(c"menu.render") }

	m.apply_style()
	m.nk_ctx.begin("golphook", C.nk_rect{x: 27 y:27, w:menu_width, h:menu_height}, u32(C.NK_WINDOW_MOVABLE | C.NK_WINDOW_NO_SCROLLBAR))

	m.menu_bar()

	match m.current_tab {
		.visuals { m.tab_visuals() }
		.misc { m.tab_misc() }
		.engine { m.tab_engine() }
		.config { m.tab_config() }
	}

	m.nk_ctx.end()
	m.nk_ctx.render()

	m.nk_ctx.input_begin()
	m.nk_ctx.input_end()

	$if prod { C.VMProtectEnd() }
}
