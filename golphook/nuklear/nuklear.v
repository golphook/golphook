module nuklear

pub struct Nuklear {
pub mut:
	nk_ctx voidptr
}

pub fn (mut n Nuklear) bootstrap(with_dev voidptr, withWidth int, and_ans_height i32) {

	$if prod { C.VMProtectBeginMutation(c"nuklear.bootstrap") }

	// TODO: use function param
	n.nk_ctx = C.nk_d3d9_init(with_dev, 1280, 900)

	mut font_stash := voidptr(0)

	C.nk_d3d9_font_stash_begin(&font_stash)
	C.nk_d3d9_font_stash_end()

	$if prod { C.VMProtectEnd() }
}

pub fn (mut n Nuklear) release() {

	C.nk_d3d9_shutdown()
}

pub fn handle_event(with_hwnd C.HWND, with_msg u32, with_param u32, and_lparam int) bool {

	return C.nk_d3d9_handle_event(with_hwnd, with_msg, with_param, and_lparam) == 1
}

pub fn (n &Nuklear) render() {

	C.nk_d3d9_render(C.NK_ANTI_ALIASING_ON)
}

pub fn (n &Nuklear) begin(with_title string, with_rect C.nk_rect, and_flags u32) bool {

	return C.nk_begin(n.nk_ctx, &char(with_title.str), with_rect, and_flags) == 1
}

pub fn (n &Nuklear) end() {

	C.nk_end(n.nk_ctx)
}

pub fn (n &Nuklear) input_begin() {

	C.nk_input_begin(n.nk_ctx)
}

pub fn (n &Nuklear) input_end() {

	C.nk_input_end(n.nk_ctx)
}

pub fn (n &Nuklear) layout_row_dynamic(with_height f32, and_nbs_of_cols i32) {

	C.nk_layout_row_dynamic(n.nk_ctx, with_height, and_nbs_of_cols)
}

pub fn (n &Nuklear) layout_row_begin(with_fmt int, row_has_height f32, and_nbs_of_cols i32) {

	C.nk_layout_row_begin(n.nk_ctx, with_fmt, row_has_height, and_nbs_of_cols)
}

pub fn (n &Nuklear) layout_row_push(with_ratio f32) {

	C.nk_layout_row_push(n.nk_ctx, with_ratio)
}

pub fn (n &Nuklear) layout_row_end() {

	C.nk_layout_row_end(n.nk_ctx)
}

pub fn (n &Nuklear) checkbox_label(with_label string, mut and_active &bool) bool {
	
	$if prod { C.VMProtectBeginMutation(c"nuklear.checkbox_label") }

	// since nuklear is a C lib and v use C as a backend, it use nk_bool as bool value but
	// nk_bool is 4 bytes and v bool is 1 bytes, so when giving v bool directly it overwrite
	// values after the v bool :)
	mut tmp_int_bool := int(*and_active)
	is_checkbox := C.nk_checkbox_label(n.nk_ctx, &char(with_label.str), &tmp_int_bool) == 1
	and_active = (tmp_int_bool == 1)

	$if prod { C.VMProtectEnd() }
	return is_checkbox
}

pub fn (n &Nuklear) button_label(with_label string) bool {

	return C.nk_button_label(n.nk_ctx, &char(with_label.str)) == 1
}

pub fn (n &Nuklear) property_float(with_label string, from_min f32, with_val &f32, to_max f32, with_step f32, and_inc_by_pxl f32) {

	C.nk_property_float(n.nk_ctx, &char(with_label.str), from_min, with_val, to_max, with_step, and_inc_by_pxl)
}

pub fn (n &Nuklear) property_int(with_label string, from_min i32, with_val &i32, to_max i32, with_step i32, and_inc_by_pxl f32) {

	C.nk_property_int(n.nk_ctx, &char(with_label.str), from_min, with_val, to_max, with_step, and_inc_by_pxl)
}

pub fn (n &Nuklear) propertyi(with_label string, from_min i32, with_val i32, to_max i32, with_step i32, and_inc_by_pxl i32) i32 {

	return C.nk_propertyi(n.nk_ctx, &char(with_label.str), from_min, with_val, to_max, with_step, and_inc_by_pxl)
}

pub fn (n &Nuklear) edit_string(with_flags i32, to_buffer voidptr, has_len &i32, and_max_len i32, and_filter voidptr) {

	C.nk_edit_string(n.nk_ctx, with_flags, to_buffer, has_len, and_max_len, and_filter)
}

pub fn (n &Nuklear) label(with_label string, and_flags i32) {

	C.nk_label(n.nk_ctx, &char(with_label.str), and_flags)
}

pub fn (n &Nuklear) combo_begin_label(with_label string, and_rect C.nk_vec2) bool {

	return C.nk_combo_begin_label(n.nk_ctx, &char(with_label.str), and_rect) == 1
}

pub fn (n &Nuklear) combo_item_label(with_label string, and_flags i32) bool {

	return C.nk_combo_item_label(n.nk_ctx, &char(with_label.str), and_flags) == 1
}

pub fn (n &Nuklear) combo_end() {

	C.nk_combo_end(n.nk_ctx)
}
pub fn (n &Nuklear) widget_width() f32 {

	return C.nk_widget_width(n.nk_ctx)
}

pub fn (n &Nuklear) group_begin(with_label string, and_flags i32) bool {

	return C.nk_group_begin(n.nk_ctx, &char(with_label.str), and_flags) == 1
}

pub fn (n &Nuklear) group_end() {

	C.nk_group_end(n.nk_ctx)
}

pub fn (c &Nuklear) selectable_label(title string, flags i32, active &bool) bool{

	return C.nk_selectable_label(c.nk_ctx, &char(title.str), flags, &i32(active)) == 1
}

pub fn (c &Nuklear) combo_begin_color(col C.nk_color, vec C.nk_vec2) bool {

	return C.nk_combo_begin_color(c.nk_ctx, col, vec) == 1
}

pub fn (c &Nuklear) color_picker(col C.nk_colorf, flags i32) C.nk_colorf {

	return C.nk_color_picker(c.nk_ctx, col, flags)
}

pub fn (c &Nuklear) style_from_table(table voidptr) {

	C.nk_style_from_table(c.nk_ctx, table)
}
