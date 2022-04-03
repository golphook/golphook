module golphook

import utils
import math

struct Line {
	from_pos utils.Vec3
	to_pos utils.Vec3
	thickness f32
	color utils.Color
}

pub fn (l &Line) draw() {
	mut app_ctx := unsafe { app() }
	unsafe {
		app_ctx.d3d.line.draw(l.from_pos, l.to_pos, l.thickness, l.color)
	}
}

pub fn new_line(fromPos utils.Vec3, toPos utils.Vec3, withThickness f32, andColor utils.Color) &Line {
	return &Line {from_pos: fromPos, to_pos: toPos, thickness: withThickness, color: andColor}
}

struct Text {
	pos utils.Vec3
	content string
	color utils.Color
	font_size u16
	format_falgs u32
}

pub fn (t &Text) draw() {
	mut app_ctx := unsafe { app() }
	unsafe {
		font := app_ctx.d3d.get_font("Lucida Console", t.font_size)
		font.draw_text(t.content, t.pos, t.format_falgs, t.color)
	}
}

pub fn new_text(atPos utils.Vec3, withContent string, withFontSize u16, withTextFormatFlags int, andColor utils.Color) &Text {
	return &Text {pos: atPos, content: withContent, color: andColor, font_size:withFontSize, format_falgs: u32(withTextFormatFlags)}
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

pub fn (_ Rectangle) draw_rect(r Rectangle) {
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
}

pub fn (r &Rectangle) draw() {

	if r.outline_thickness == f32(0) {
		r.draw_rect(r)
	} else {
		mut new_rect := *(r)
		new_rect.pos.x = new_rect.pos.x + r.thickness
		new_rect.pos.y = new_rect.pos.y - r.thickness
		new_rect.height = new_rect.height - (r.thickness * 2)
		new_rect.width = new_rect.width - (r.thickness * 2)
		new_rect.color = utils.color_rbga(245, 59, 87,255)
		r.draw_rect(new_rect)
		r.draw_rect(r)
		new_rect = *(r)
		new_rect.pos.x = new_rect.pos.x - r.thickness
		new_rect.pos.y = new_rect.pos.y + r.thickness
		new_rect.height = new_rect.height + (r.thickness * 2)
		new_rect.width = new_rect.width + (r.thickness * 2)
		new_rect.color = utils.color_rbga(245, 59, 87,255)
		r.draw_rect(new_rect)
	}
	// if r.outline_thickness == f32(0) {
	// 	//r.draw_rect()
	// 	utils.pront("no thi")
	// } else {
	// 	mut app_ctx := unsafe { app() }
	// 	mut inter_outline := r.pos
	// 	//app_ctx.rnd_queue.push(new_rectangle(inter_outline, 30, 50, 3, 0, utils.color_rbga(255,255,255,255)))
	// 	//r.draw_rect()
	// 	utils.pront("thi")
	// 	//app_ctx.rnd_queue.push(new_rectangle(screen_pos, 30, 50, 2, 2, utils.color_rbga(255,255,255,255)))
	// }

}

pub fn new_rectangle(atPos utils.Vec3, withHeight f32, withWidth f32, withThickness f32, withOutlineThickness f32, andColor utils.Color) &Rectangle {
	return &Rectangle { pos: atPos, height: withHeight, width: withWidth, thickness: withThickness, outline_thickness: withOutlineThickness, color: andColor }
}


struct Circle {
	at_pos utils.Vec3
	thickness f32
	radius f32
	color utils.Color
}

pub fn (c &Circle) draw() {
	mut app_ctx := unsafe { app() }
	for i := f32(1); i <= 360; i += 10 {
		mut x := f32(i + 10)
		mut from := utils.new_vec2( c.at_pos.x + ( c.radius * math.cosf( i * math.pi / 180 ) ), c.at_pos.y + ( c.radius * math.sinf( i* math.pi / 180 ) ) )
		mut to := utils.new_vec2( c.at_pos.x + ( c.radius * math.cosf( x * math.pi / 180 ) ) , c.at_pos.y + ( c.radius * math.sinf( x* math.pi / 180 ) ) )
		unsafe {
			app_ctx.d3d.line.draw(from.vec_3(), to.vec_3(), c.thickness, c.color)
		}
	}
}

pub fn new_circle(atPos utils.Vec3, withThickness f32, withRadius f32, andColor utils.Color) &Circle {
	return &Circle {at_pos: atPos, thickness: withThickness, radius: withRadius, color: andColor}
}

interface Drawable {
	draw()
}
