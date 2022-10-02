module d3d

import utils

pub struct D3dSprite {
pub:
	i_dxsprite voidptr
}

[unsafe]
pub fn (d &D3dSprite) begin(with_flags int) bool {

	$if prod { C.VMProtectBeginMutation(c"d3d_sprite.begin") }

	mut static o_fn := &P_idx_sprite_begin(0)
	if isnil(o_fn) {
		o_fn = &P_idx_sprite_begin(utils.get_virtual(d.i_dxsprite, 8))
	}

	o_fn(d.i_dxsprite, with_flags)

	$if prod { C.VMProtectEnd() }

	return true
}

[unsafe; callconv: "stdcall"]
pub fn (d &D3dSprite) draw(texture voidptr, with_rect &utils.Vec2, at_center &utils.Vec3, at_pos &utils.Vec3, and_color utils.Color) {
	
	$if prod { C.VMProtectBeginMutation(c"d3d_sprite.draw") }

	mut static o_fn := &P_idx_sprite_draw(0)
	if isnil(o_fn) {
		o_fn = &P_idx_sprite_draw(utils.get_virtual(d.i_dxsprite, 9))
	}

	// utils.h_res cause crash here ?? why not -__-
	o_fn(d.i_dxsprite, texture, with_rect, at_center, at_pos, 0xFFFFFFFF)

	$if prod { C.VMProtectEnd() }

}

[unsafe]
pub fn (d &D3dSprite) end() bool {

	$if prod { C.VMProtectBeginMutation(c"d3d_sprite.end") }

	mut static o_fn := &P_idx_sprite_end(0)
	if isnil(o_fn) {
		o_fn = &P_idx_sprite_end(utils.get_virtual(d.i_dxsprite, 11))
	}

	o_fn(d.i_dxsprite)

	$if prod { C.VMProtectEnd() }

	return true
}

[unsafe]
pub fn (d D3dSprite) release() u32 {

	$if prod { C.VMProtectBeginMutation(c"d3d_sprite.release") }

	mut static o_fn := &P_idx_release(0)
	if isnil(o_fn) {
		o_fn = &P_idx_release(utils.get_virtual(d.i_dxsprite, 2))
	}

	$if prod { C.VMProtectEnd() }

	return o_fn(d.i_dxsprite)
}

pub struct D3dTexture {
pub mut:
	i_dxtexture voidptr
}

[unsafe]
pub fn (d D3dTexture) release() u32 {

	$if prod { C.VMProtectBeginMutation(c"d3d_texture.release") }

	mut static o_fn := &P_idx_release(0)
	if isnil(o_fn) {
		o_fn = &P_idx_release(utils.get_virtual(d.i_dxtexture, 2))
	}

	$if prod { C.VMProtectEnd() }

	return o_fn(d.i_dxtexture)
}



struct D3d9Font {
pub mut:
	name string
	size int
	i_dxfont voidptr
}

[unsafe]
pub fn (d D3d9Font) draw_text(with_text string, at_pos utils.Vec3, with_text_format u32, and_color utils.Color) bool {

	$if prod { C.VMProtectBeginMutation(c"d3d_font.draw_text") }

	mut static o_fn := &P_idx_draw_text_a(0)
	if isnil(o_fn) {
		o_fn = &P_idx_draw_text_a(utils.get_virtual(d.i_dxfont, 14))
	}

	mut rect := C.RECT{
		top: int(at_pos.x)
		left: int(at_pos.y)
	}

	h_res := utils.h_res(o_fn(d.i_dxfont, voidptr(0), &char(with_text.str), -1, &rect, with_text_format, and_color.d3d()))

	$if prod { C.VMProtectEnd() }

	return h_res.bool()
}

[unsafe]
pub fn (d D3d9Font) release() u32 {

	$if prod { C.VMProtectBeginMutation(c"d3d_font.release") }

	mut static o_fn := &P_idx_release(0)
	if isnil(o_fn) {
		o_fn = &P_idx_release(utils.get_virtual(d.i_dxfont, 2))
	}

	$if prod { C.VMProtectEnd() }

	return o_fn(d.i_dxfont)
}

struct D3d9line {
pub mut:
	i_dxline voidptr
}

[unsafe]
fn (d D3d9line) set_width(with_new_width f32) bool {

	$if prod { C.VMProtectBeginMutation(c"d3d_line.set_width") }

	mut static o_fn := &P_idx_line_set_width(0)
	if isnil(o_fn) {
		o_fn = &P_idx_line_set_width(utils.get_virtual(d.i_dxline, 11))
	}

	h_res := utils.h_res(o_fn(d.i_dxline, with_new_width))

	$if prod { C.VMProtectEnd() }

	return h_res.bool()
}

[unsafe]
pub fn (d D3d9line) draw(at_pos utils.Vec3, to_pos utils.Vec3, has_width f32, and_color utils.Color) bool {

	$if prod { C.VMProtectBeginMutation(c"d3d_line.draw") }

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

	$if prod { C.VMProtectEnd() }	

	return h_res.bool()

}

[unsafe]
fn (d D3d9line) release() u32 {

	$if prod { C.VMProtectBeginMutation(c"d3d_line.release") }

	mut static o_fn := &P_idx_release(0)
	if isnil(o_fn) {
		o_fn = &P_idx_release(utils.get_virtual(d.i_dxline, 2))
	}
	// someone have to know that i spent litteraly 2h+ to debug this shit just
	// beacuse calling o_fn without handling it's return make a crash to a random place in csgo pls kill me

	$if prod { C.VMProtectEnd() }

	return o_fn(d.i_dxline)
}

pub struct D3d9 {
pub mut:
	device voidptr

	fonts []D3d9Font
	line D3d9line
}

pub fn (mut d D3d9) create_font(with_name string, with_name_complement string, has_size int, and_has_weight u32) {

	$if prod { C.VMProtectBeginMutation(c"d3D.create_font") }

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

	$if prod { C.VMProtectEnd() }
}

pub fn (mut d D3d9) create_line() {

	$if prod { C.VMProtectBeginMutation(c"d3d.create_line") }

	h_res := utils.h_res(C.D3DXCreateLine(d.device, &d.line.i_dxline))

	if !(h_res.bool()) {
		utils.error_critical("D3D failed to create drawing component", "D3DXCreateLine")
	}

	$if prod { C.VMProtectEnd() }
}

pub fn (mut d D3d9) get_device() {

	$if prod { C.VMProtectBeginMutation(c"d3d.get_device") }

	mut device_scan := utils.pattern_scan("shaderapidx9.dll", "A3 ? ? ? ? 8D 47 30") or {
		utils.error_critical("Failed to scan for patern:", "d3d device")
	}

	d.device = voidptr(**(&&&u32(voidptr(usize(device_scan) + 1))))

	$if prod { C.VMProtectEnd() }
}

pub fn (d &D3d9) get_font(with_name string, has_size u16) &D3d9Font {

	$if prod { C.VMProtectBeginMutation(c"d3d.get_font") }

	for i in 0..(d.fonts.len - 1) {
		font := &d.fonts[i]
		if font.name == with_name && font.size == int(has_size) {
			return unsafe { font }
		}
	}

	utils.pront("Failed to find font retry for sure one")

	$if prod { C.VMProtectEnd() }

	return &d.fonts[0]
}

pub fn (mut d D3d9) bootstrap() {

	$if prod { C.VMProtectBeginMutation(c"d3d.bootstrap") }

	d.get_device()

	for font_size in 1..20 {
		d.create_font("Lucida Console", "", font_size, 100)
	}

	for font_size in 1..20 {
		d.create_font("Lucida Console", " bold", font_size, 600)
	}

	d.create_line()

	$if prod { C.VMProtectEnd() }
}

pub fn (mut d D3d9) release() {

	$if prod { C.VMProtectBeginMutation(c"d3d.release") }

	unsafe {
		d.line.release()
	}

	for f in d.fonts {
		unsafe {
			f.release()
		}
	}

	d.fonts.clear()

	$if prod { C.VMProtectEnd() }
}
