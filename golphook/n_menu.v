module golphook

import nuklear
import utils

struct NMenu {
pub mut:
	nk_ctx nuklear.Nuklear

	is_opened bool
}

fn (mut m NMenu) bootstrap(dev voidptr) {
	mut app_ctx := unsafe { app() }

	m.nk_ctx.bootstrap(dev, 800, 600)

}

fn (mut m NMenu) release(isReset bool) {
	mut app_ctx := unsafe { app() }
	m.is_opened = false

	if !isReset {
		C.SetWindowLongA( C.FindWindowA(c"Valve001", &char(0)), -4, i32(app_ctx.hooks.wnd_proc.original_save))
	}

	m.nk_ctx.release()
}

fn (mut m NMenu) on_send_scene() {
	if m.is_opened {
		m.render()
	}
}

fn (mut m NMenu) render() {
	m.nk_ctx.begin("hellosdsss", C.nk_rect{x: 50.0, y:50.0, w:220.0, h:200.0}, u32(C.NK_WINDOW_BORDER | C.NK_WINDOW_MOVABLE | C.NK_WINDOW_NO_SCROLLBAR))
	m.nk_ctx.layout_row_static(30.0, 80, 1)

	if m.nk_ctx.button_label("hello") {
		utils.pront("hi")
	}

	//m.nk_ctx.layout_row_end()

	m.nk_ctx.end()
	m.nk_ctx.render()

	m.nk_ctx.input_begin()
	m.nk_ctx.input_end()
}
