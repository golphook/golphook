module d3d

import utils

struct D3d9Font {
pub mut:
	name string
	size int
	i_dxfont voidptr
}

[unsafe]
pub fn (d D3d9Font) draw_text(with_text string, at_pos utils.Vec3, with_text_format u32, and_color utils.Color) bool {

	mut static o_fn := &P_idx_draw_text_a(0)
	if isnil(o_fn) {
		o_fn = &P_idx_draw_text_a(utils.get_virtual(d.i_dxfont, 14))
	}

	mut rect := C.RECT{
		top: int(at_pos.x)
		left: int(at_pos.y)
	}

	h_res := utils.h_res(o_fn(d.i_dxfont, voidptr(0), &char(with_text.str), -1, &rect, with_text_format, and_color.d3d()))

	return h_res.bool()
}

[unsafe]
pub fn (d D3d9Font) release() u32 {

	mut static o_fn := &P_idx_release(0)
	if isnil(o_fn) {
		o_fn = &P_idx_release(utils.get_virtual(d.i_dxfont, 2))
	}

	return o_fn(d.i_dxfont)
}

struct D3d9line {
pub mut:
	i_dxline voidptr
}

[unsafe]
fn (d D3d9line) set_width(with_new_width f32) bool {

	mut static o_fn := &P_idx_line_set_width(0)
	if isnil(o_fn) {
		o_fn = &P_idx_line_set_width(utils.get_virtual(d.i_dxline, 11))
	}

	h_res := utils.h_res(o_fn(d.i_dxline, with_new_width))
	return h_res.bool()
}

[unsafe]
pub fn (d D3d9line) draw(at_pos utils.Vec3, to_pos utils.Vec3, has_width f32, and_color utils.Color) bool {

	mut static o_fn := &P_idx_line_draw(0)
	if isnil(o_fn) {
		o_fn = &P_idx_line_draw(utils.get_virtual(d.i_dxline, 5))
	}

	dx_vec_2_vertex := [
		C.D3DXVECTOR2{x: at_pos.x, y: at_pos.y},
		C.D3DXVECTOR2{x: to_pos.x, y: to_pos.y}
	]!

	is_set_width_went_ok := unsafe { d.set_width(has_width) }
	if !is_set_width_went_ok {
		return false
	}

	h_res := utils.h_res(o_fn(d.i_dxline, &dx_vec_2_vertex, 2, and_color.d3d()))
	return h_res.bool()

}

[unsafe]
fn (d D3d9line) release() u32 {

	mut static o_fn := &P_idx_release(0)
	if isnil(o_fn) {
		o_fn = &P_idx_release(utils.get_virtual(d.i_dxline, 2))
	}
	// someone have to know that i spent litteraly 2h+ to debug this shit just
	// beacuse calling o_fn without handling it's return make a crash to a random place in csgo pls kill me
	return o_fn(d.i_dxline)
}

pub struct D3d9 {
pub mut:
	device voidptr

	fonts []D3d9Font
	line D3d9line
}

pub fn (mut d D3d9) create_font(with_name string, with_name_complement string, has_size int, and_has_weight u32) {

	mut font := D3d9Font{name: "$with_name$with_name_complement", size: has_size}

	h_res := utils.h_res(
		C.D3DXCreateFontA(
			d.device, has_size, 0, and_has_weight, 1, false,
			C.DEFAULT_CHARSET ,C.OUT_DEFAULT_PRECIS, C.ANTIALIASED_QUALITY, C.DEFAULT_PITCH | C.FF_DONTCARE,
			&char(with_name.str), &font.i_dxfont
		)
	)

	if !(h_res.bool()) {
		utils.error_critical("D3D failed to create drawing component", "D3DXCreateFont")
	}

	d.fonts << font
}

pub fn (mut d D3d9) create_line() {

	h_res := utils.h_res(C.D3DXCreateLine(d.device, &d.line.i_dxline))

	if !(h_res.bool()) {
		utils.error_critical("D3D failed to create drawing component", "D3DXCreateLine")
	}
}

pub fn (mut d D3d9) get_device() {

	mut device_scan := utils.pattern_scan("shaderapidx9.dll", "A3 ? ? ? ? 8D 47 30") or {
		utils.error_critical("Failed to scan for patern:", "d3d device")
	}

	d.device = voidptr(**(&&&u32(voidptr(usize(device_scan) + 1))))
}

pub fn (d &D3d9) get_font(with_name string, has_size u16) &D3d9Font {

	for i in 0..(d.fonts.len - 1) {
		font := &d.fonts[i]
		if font.name == with_name && font.size == int(has_size) {
			return unsafe { font }
		}
	}

	utils.pront("Failed to find font retry for sure one")
	return &d.fonts[0]
}

pub fn (mut d D3d9) bootstrap() {

	d.get_device()

	for font_size in 1..20 {
		d.create_font("Lucida Console", "", font_size, 100)
	}

	for font_size in 1..20 {
		d.create_font("Lucida Console", " bold", font_size, 600)
	}

	d.create_line()
}

pub fn (mut d D3d9) release() {

	unsafe {
		d.line.release()
	}

	for f in d.fonts {
		unsafe {
			f.release()
		}
	}

	d.fonts.clear()
}
