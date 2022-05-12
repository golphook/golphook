module nuklear

pub struct Nuklear {
pub mut:
	nk_ctx voidptr
}

pub fn (mut c Nuklear) bootstrap(withDevice voidptr, withWidth int, andHeight i32) {
	c.nk_ctx = C.nk_d3d9_init(withDevice, 1280, 900)

	mut font_stash := voidptr(0)

	C.nk_d3d9_font_stash_begin(&font_stash)
	C.nk_d3d9_font_stash_end()
}

pub fn (mut c Nuklear) release() {
	C.nk_d3d9_shutdown()
}

pub fn handle_event(withHwnd C.HWND, withMsg u32, withWParam u32, andLParam int) bool {
	return C.nk_d3d9_handle_event(withHwnd, withMsg, withWParam, andLParam) == 1
}

pub fn (mut c Nuklear) render() {
	C.nk_d3d9_render(C.NK_ANTI_ALIASING_ON)
}

pub fn (c &Nuklear) begin(withTile string, withRect C.nk_rect, andFlags u32) bool {
	return C.nk_begin(c.nk_ctx, &char(withTile.str), withRect, andFlags) == 1
}

pub fn (c &Nuklear) end() {
	C.nk_end(c.nk_ctx)
}

pub fn (c &Nuklear) input_begin() {
	C.nk_input_begin(c.nk_ctx)
}

pub fn (c &Nuklear) input_end() {
	C.nk_input_end(c.nk_ctx)
}

pub fn (c &Nuklear) layout_row_dynamic(withHeight f32, andCols i32) {
	C.nk_layout_row_dynamic(c.nk_ctx, withHeight, andCols)
}

pub fn (c &Nuklear) layout_row_begin(fmt int, rowHeight f32, cols i32) {
	C.nk_layout_row_begin(c.nk_ctx, fmt, rowHeight, cols)
}

pub fn (c &Nuklear) layout_row_push(val f32) {
	C.nk_layout_row_push(c.nk_ctx, val)
}

pub fn (c &Nuklear) layout_row_end() {
	C.nk_layout_row_end(c.nk_ctx)
}

pub fn (c &Nuklear) checkbox_label(label string, mut active &bool) bool {
	// since nuklear is a C lib and v use C as a backend, it use nk_bool as bool value but
	// nk_bool is 4 bytes and v bool is 1 bytes, so when giving v bool directly it overwrite
	// values after the v bool :)
	mut tmp_int_bool := int(*active)
	r := C.nk_checkbox_label(c.nk_ctx, &char(label.str), &tmp_int_bool) == 1
	active = (tmp_int_bool == 1)
	return r
}

pub fn (c &Nuklear) button_label(withTitle string) bool {
	return C.nk_button_label(c.nk_ctx, &char(withTitle.str)) == 1
}

pub fn (c &Nuklear) property_float(label string, min f32, val &f32, max f32, step f32, inc_pxl f32) {
	C.nk_property_float(c.nk_ctx, &char(label.str), min, val, max, step, inc_pxl)
}

pub fn (c &Nuklear) property_int(label string, min i32, val &i32, max i32, step i32, inc_pxl f32) {
	C.nk_property_int(c.nk_ctx, &char(label.str), min, val, max, step, inc_pxl)
}

pub fn (c &Nuklear) propertyi(label string, min i32, val i32, max i32, step i32, inc_pxl i32) i32 {
	return C.nk_propertyi(c.nk_ctx, &char(label.str), min, val, max, step, inc_pxl)
}

pub fn (c &Nuklear) edit_string(flags i32, buffer voidptr, len &i32, max i32, filter voidptr) {
	C.nk_edit_string(c.nk_ctx, flags, buffer, len, max, filter)
}

pub fn (c &Nuklear) label(withTitle string, flags i32) {
	C.nk_label(c.nk_ctx, &char(withTitle.str), flags)
}

pub fn (c &Nuklear) combo_begin_label(withTitle string, rect C.nk_vec2) bool {
	return C.nk_combo_begin_label(c.nk_ctx, &char(withTitle.str), rect) == 1
}

pub fn (c &Nuklear) combo_item_label(withTitle string, flags i32) bool {
	return C.nk_combo_item_label(c.nk_ctx, &char(withTitle.str), flags) == 1
}

pub fn (c &Nuklear) combo_end() {
	C.nk_combo_end(c.nk_ctx)
}
pub fn (c &Nuklear) widget_width() f32 {
	return C.nk_widget_width(c.nk_ctx)
}

pub fn (c &Nuklear) group_begin(title string, flags i32) bool {
	return C.nk_group_begin(c.nk_ctx, &char(title.str), flags) == 1
}

pub fn (c &Nuklear) group_end() {
	C.nk_group_end(c.nk_ctx)
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
