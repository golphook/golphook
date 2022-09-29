module golphook

// all free() are freeing strings or some interfaces allocation and help reducing memory leaks,

import utils
import math

struct Line {
	from_pos utils.Vec3
	to_pos utils.Vec3
	thickness f32
	color utils.Color
}

pub fn (l &Line) draw() {

	$if prod { C.VMProtectBeginMutation(c"line.draw") }

	mut app_ctx := unsafe { app() }

	unsafe {
		app_ctx.d3d.line.draw(l.from_pos, l.to_pos, l.thickness, l.color)
	}

	$if prod { C.VMProtectEnd() }
}

fn (l &Line) free() {

	$if prod { C.VMProtectBeginMutation(c"line.free") }

	unsafe {
		free(l)
	}
	
	$if prod { C.VMProtectEnd() }
}

pub fn new_line(from_pos utils.Vec3, to_pos utils.Vec3, with_thickness f32, and_color utils.Color) Line {

	return Line {
		from_pos: from_pos
		to_pos: to_pos
		thickness: with_thickness
		color: and_color
	}
}

struct Text {
	pos utils.Vec3
	content string
	bold bool
	shadow bool
	color utils.Color
	font_size u16
	format_falgs u32
}

pub fn (t &Text) draw() {

	$if prod { C.VMProtectBeginMutation(c"text.draw") }

	mut app_ctx := unsafe { app() }

	unsafe {
		mut font := app_ctx.d3d.get_font("Lucida Console", t.font_size)

		if t.bold {
			font = app_ctx.d3d.get_font("Lucida Console bold", t.font_size)
		}

		if t.shadow {
			font.draw_text(t.content, t.pos + utils.op_vec(1), t.format_falgs, utils.color_rbga(1,1,1,255))
		}

		font.draw_text(t.content, t.pos, t.format_falgs, t.color)
	}

	$if prod { C.VMProtectEnd() }
}

fn (t &Text) free() {

	$if prod { C.VMProtectBeginMutation(c"text.free") }

	unsafe {
		t.content.free()
		free(t)
	}

	$if prod { C.VMProtectEnd() }
}

pub fn new_text(at_pos utils.Vec3, with_content string, with_font_size u16, is_bold bool, has_shadow bool, with_fmt_flags int, and_color utils.Color) Text {

	return Text {
		pos: at_pos
		content: with_content
		color: and_color
		font_size:with_font_size
		format_falgs: u32(with_fmt_flags)
		bold: is_bold
		shadow: has_shadow
	}
}

struct Rectangle {
pub mut:
	pos utils.Vec3
	height f32
	width f32
	thickness f32
	outline_thickness f32
	color utils.Color
}

pub fn (r &Rectangle) draw() {

	$if prod { C.VMProtectBeginMutation(c"rect.draw") }

	mut app_ctx := unsafe { app() }

		/*
	 *                 (-)
	 *                  ^
	 *                  |
	 *                  |
	 *  x (-) <- ---------------- -> (+)
	 *                  |
	 *                  |
	 *                  v
	 *                 (+)
	 *                  y
	 * */

	mut v1 := utils.new_vec2(r.pos.x, r.pos.y)
	mut v2 := utils.new_vec2(r.pos.x + r.width, r.pos.y)
	unsafe {
		app_ctx.d3d.line.draw(v1.vec_3(), v2.vec_3(), r.thickness, r.color)
	}

	v1 = utils.new_vec2(r.pos.x, r.pos.y - r.height)
	v2 = utils.new_vec2(r.pos.x + r.width, r.pos.y - r.height)
	unsafe {
		app_ctx.d3d.line.draw(v1.vec_3(), v2.vec_3(), r.thickness, r.color)
	}

	v1 = utils.new_vec2(r.pos.x, r.pos.y + (r.thickness / 2))
	v2 = utils.new_vec2(r.pos.x, (r.pos.y - r.height) - (r.thickness / 2))
	unsafe {
		app_ctx.d3d.line.draw(v1.vec_3(), v2.vec_3(), r.thickness, r.color)
	}

	v1 = utils.new_vec2(r.pos.x + r.width, r.pos.y + (r.thickness / 2))
	v2 = utils.new_vec2(r.pos.x + r.width, (r.pos.y - r.height) - (r.thickness / 2))
	unsafe {
		app_ctx.d3d.line.draw(v1.vec_3(), v2.vec_3(), r.thickness, r.color)
	}

	$if prod { C.VMProtectEnd() }
}

fn (r &Rectangle) free() {

	$if prod { C.VMProtectBeginMutation(c"rect.free") }

	unsafe {
		free(r)
	}

	$if prod { C.VMProtectEnd() }
}

pub fn new_rectangle(at_pos utils.Vec3, with_height f32, with_width f32, with_thickness f32, with_outline_thickness f32, and_color utils.Color) Rectangle {

	return Rectangle {
		pos: at_pos
		height: with_height
		width: with_width
		thickness: with_thickness // not used
		outline_thickness: with_outline_thickness // not used
		color: and_color
	}
}


struct Circle {
	at_pos utils.Vec3
	thickness f32
	radius f32
	color utils.Color
}

pub fn (c &Circle) draw() {

	$if prod { C.VMProtectBeginMutation(c"circle.draw") }

	mut app_ctx := unsafe { app() }

	for i := f32(1); i <= 360; i += 10 {
		mut x := f32(i + 10)
		mut from := utils.new_vec2( c.at_pos.x + ( c.radius * math.cosf( i * math.pi / 180 ) ), c.at_pos.y + ( c.radius * math.sinf( i* math.pi / 180 ) ) )
		mut to := utils.new_vec2( c.at_pos.x + ( c.radius * math.cosf( x * math.pi / 180 ) ) , c.at_pos.y + ( c.radius * math.sinf( x* math.pi / 180 ) ) )
		unsafe {
			app_ctx.d3d.line.draw(from.vec_3(), to.vec_3(), c.thickness, c.color)
		}
	}
	
	$if prod { C.VMProtectEnd() }
}

fn (c &Circle) free() {

	$if prod { C.VMProtectBeginMutation(c"circle.free") }

	unsafe {
		free(c)
	}

	$if prod { C.VMProtectEnd() }
}

pub fn new_circle(at_pos utils.Vec3, with_thickness f32, with_radius f32, and_color utils.Color) Circle {

	return Circle {
		at_pos: at_pos
		thickness: with_thickness
		radius: with_radius
		color: and_color
	}
}

interface Drawable {
	draw()
	free()
}
