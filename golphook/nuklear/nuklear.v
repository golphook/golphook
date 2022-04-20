module nuklear

pub struct Nuklear {
pub mut:
	nk_ctx voidptr
}

pub fn (mut c Nuklear) bootstrap(withDevice voidptr, withWidth int, andHeight i32) {
	c.nk_ctx = C.nk_d3d9_init(withDevice, withWidth, andHeight)

	mut font_stash := &C.nk_font_atlas{}

	C.nk_d3d9_font_stash_begin(&font_stash)
	C.nk_d3d9_font_stash_end()
}

pub fn (mut c Nuklear) release() {
	C.nk_d3d9_shutdown()
}

pub fn (c &Nuklear) begin(withTile string, withRect C.nk_rect, andFlags u32) int {
	return C.nk_begin(c.nk_ctx, c"&char(withTile.str)", withRect, andFlags)
}

pub fn handle_event(withHwnd C.HWND, withMsg u32, withWParam u32, andLParam int) int {
	return C.nk_d3d9_handle_event(withHwnd, withMsg, withWParam, andLParam)
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
pub fn (mut c Nuklear) render() {
	C.nk_d3d9_render(C.NK_ANTI_ALIASING_ON)
}

pub fn (c &Nuklear) button_label(withTitle string) bool {
	return C.nk_button_label(c.nk_ctx, c"&char(withTitle.str)")
}

pub fn (c &Nuklear) layout_row_static(withHeight f32, withItemWidth i32, andCols i32) {
	C.nk_layout_row_static(c.nk_ctx, withHeight, withItemWidth, andCols)
}

pub fn (c &Nuklear) layout_row_end() {
	C.nk_layout_row_end(c.nk_ctx)
}
