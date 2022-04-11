module utils

pub struct ColorRgbaF {
mut:
	r f32
	g f32
	b f32
	a f32
}

struct ColorRgba {
mut:
	r byte
	g byte
	b byte
	a byte

}

union Color {
	ColorRgba
mut:
	rgba u32 [skip]
}

// Get methods to avoid using unsafe to access union in the code

[inline]
pub fn (c &Color) r() byte {
	return unsafe { c.r }
}

[inline]
pub fn (c &Color) g() byte {
	return unsafe { c.g }
}

[inline]
pub fn (c &Color) b() byte {
	return unsafe { c.b }
}

[inline]
pub fn (c &Color) a() byte {
	return unsafe { c.a }
}

[inline]
pub fn (c &Color) rgba() u32 {
	return unsafe { c.rgba }
}

[inline]
pub fn (c &Color) rgbaf() ColorRgbaF {

	mut r_ := f32(c.r()) / 255.0
	mut g_ := f32(c.g()) / 255.0
	mut b_ := f32(c.b()) / 255.0
	mut a_ := f32(c.a()) / 255.0

	return ColorRgbaF{r: r_, g: g_, b: b_, a: a_}
}



pub fn color_rbga<T>(r_ T, g_ T, b_ T, a_ T) Color {
	return Color{ColorRgba: ColorRgba{r:byte(r_), g:byte(g_), b:byte(b_), a:byte(a_)}}
}

pub fn color_f_rbga<T>(r_ T, g_ T, b_ T, a_ T) Color {
	return Color{ColorRgba: ColorRgba{r:byte(r_ * 255.0), g:byte(g_ * 255.0), b:byte(b_ * 255.0), a:byte(a_ * 255.0)}}
}

pub fn color_hex(withHex u32) Color {
	no := Color{rgba: withHex}
	return Color{ColorRgba: ColorRgba{r:no.a(), g:no.r(), b:no.g(), a:no.b()}}
}
