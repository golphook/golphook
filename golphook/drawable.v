module golphook

import utils

struct Line {
	from_pos utils.Vec3
	to_pos utils.Vec3
	thickness f32
	color utils.Color
}

pub fn (l Line) draw() {
	mut app_ctx := unsafe { app() }
	unsafe {
		app_ctx.d3d.line.draw(l.from_pos, l.to_pos, l.thickness, l.color)
	}
}

pub fn new_line(fromPos utils.Vec3, toPos utils.Vec3, withThickness f32, andColor utils.Color) Line {
	return Line {from_pos: fromPos, to_pos: toPos, thickness: withThickness, color: andColor}
}

struct Text {
	pos utils.Vec3
	content string
	color utils.Color
	font_size u16
	format_falgs u32
}

pub fn (t Text) draw() {
	mut app_ctx := unsafe { app() }
	unsafe {
		font := app_ctx.d3d.get_font("Lucida Console", 18)
		font.draw_text(t.content, t.pos, t.format_falgs, t.color)
	}
}

pub fn new_text(atPos utils.Vec3, withContent string, withFontSize u16, withTextFormatFlags int, andColor utils.Color) Text {
	return Text {pos: atPos, content: withContent, color: andColor, font_size:withFontSize, format_falgs: u32(withTextFormatFlags)}
}

interface Drawable {
	draw()
}
