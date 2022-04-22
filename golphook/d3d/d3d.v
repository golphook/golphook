module d3d

import utils

struct D3d9Font {
pub mut:
	name string
	size int
	i_dxfont voidptr
}

[unsafe]
pub fn (d D3d9Font) draw_text(withText string, withPos utils.Vec3, withTextFormat u32, andColor utils.Color) bool {

	mut static o_fn := &P_dx_draw_text_a(0)
	if int(o_fn) == 0 {
		o_fn = &P_dx_draw_text_a(utils.get_virtual(d.i_dxfont, 14))
	}

	mut rect := C.RECT{}

	rect.top = int(withPos.x)
	rect.left = int(withPos.y)

	h_res := utils.h_res(o_fn(d.i_dxfont, voidptr(0), &char(withText.str), -1, &rect, withTextFormat, andColor.d3d()))

	return h_res.bool()
}

[unsafe]
pub fn (d D3d9Font) release() u32 {

	mut static o_fn := &P_dx_release(0)
	if int(o_fn) == 0 {
		o_fn = &P_dx_release(utils.get_virtual(d.i_dxfont, 2))
	}

	return o_fn(d.i_dxfont)
}

struct D3d9line {
pub mut:
	i_dxline voidptr
}

[unsafe]
fn (d D3d9line) set_width(withNewWidth f32) bool {

	mut static o_fn := &P_idx_line_set_width(0)
	if int(o_fn) == 0 {
		o_fn = &P_idx_line_set_width(utils.get_virtual(d.i_dxline, 11))
	}

	h_res := utils.h_res(o_fn(d.i_dxline, withNewWidth))
	return h_res.bool()
}

[unsafe]
pub fn (d D3d9line) draw(atPos utils.Vec3, toPos utils.Vec3, withWidth f32, andColor utils.Color) bool {

	mut static o_fn := &P_idx_line_draw(0)
	if int(o_fn) == 0 {
		o_fn = &P_idx_line_draw(utils.get_virtual(d.i_dxline, 5))
	}

	mut dx_vec_2_vertex := [2]C.D3DXVECTOR2{}
	dx_vec_2_vertex[0] = C.D3DXVECTOR2{x: atPos.x, y: atPos.y}
	dx_vec_2_vertex[1] = C.D3DXVECTOR2{x: toPos.x, y: toPos.y}

	mut is_set_width_went_ok := unsafe { d.set_width(withWidth) }
	if !is_set_width_went_ok {
		return false
	}

	h_res := utils.h_res(o_fn(d.i_dxline, &dx_vec_2_vertex, 2, andColor.d3d()))
	return h_res.bool()

}

[unsafe]
fn (d D3d9line) release() u32 {

	mut static o_fn := &P_dx_release(0)
	if int(o_fn) == 0 {
		o_fn = &P_dx_release(utils.get_virtual(d.i_dxline, 2))
	}
	// someone have to know that i spent litteraly 2h+ to debug this shit just
	//beacuse calling o_fn without handming it's return make a crash to a random place in csgo pls kill me
	return o_fn(d.i_dxline)
}

pub struct D3d9 {
pub mut:
	device voidptr
	//fonts map[string]map[u16]D3d9Font
	fonts []D3d9Font
	line D3d9line

	tmp_fnt D3d9Font

}

pub fn (mut d D3d9) create_font(withFontName string, withNameComplement string, withFontSize int, withFontWeight u32) {

	mut font := D3d9Font{name: "$withFontName$withNameComplement", size: withFontSize}

	h_res := utils.h_res(C.D3DXCreateFontA(d.device, withFontSize, 0, withFontWeight, 1, false, C.DEFAULT_CHARSET ,C.OUT_DEFAULT_PRECIS, C.ANTIALIASED_QUALITY, C.DEFAULT_PITCH | C.FF_DONTCARE, &char(withFontName.str), &font.i_dxfont))

	if !(h_res.bool()) {
		utils.error_critical("D3D failed to create drawing component", "D3DXCreateFont")
	}

	//d.fonts[withFontName][u16(withFontSize)] = font
	d.fonts << font
}

pub fn (mut d D3d9) create_line() {

	h_res := utils.h_res(C.D3DXCreateLine(d.device, &d.line.i_dxline))
	if !(h_res.bool()) {
		utils.error_critical("D3D failed to create drawing component", "D3DXCreateLine")
	}
}

pub fn (mut d D3d9) get_device() {
	mut device_scan := utils.patter_scan("shaderapidx9.dll", "A3 ? ? ? ? 8D 47 30") or { panic("$err") }
	d.device = voidptr(**(&&&u32(voidptr(usize(device_scan) + 1))))
}

pub fn (d D3d9) get_font(withName string, andSize u16) &D3d9Font {
	for i in 0..d.fonts.len - 1 {
		font := &d.fonts[i]
		if font.name == withName && font.size == int(andSize) {
			return unsafe { font }
		}
	}
	utils.pront("Failed to find font retry for sure one")
	return &d.fonts[0]
}

pub fn (mut d D3d9) bootstrap() {
	d.get_device()
	// for font_size in 1..20 {
	// 	d.create_font("Lucida Console", font_size, 500)
	// }

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
