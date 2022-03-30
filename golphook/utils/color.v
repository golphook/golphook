module utils

struct ColorRgba {
mut:
	a byte = 255
	b byte
	g byte
	r byte
}

union Color {
	ColorRgba
mut:
	hex u32
}

// Get methods to avoid using unsafe to access union in the code

[inline]
pub fn (c Color) r() byte {
	return unsafe { c.r }
}

[inline]
pub fn (c Color) g() byte {
	return unsafe { c.g }
}

[inline]
pub fn (c Color) b() byte {
	return unsafe { c.b }
}

[inline]
pub fn (c Color) a() byte {
	return unsafe { c.a }
}

[inline]
pub fn (c Color) hex() u32 {
	return unsafe { c.hex }
}

pub fn color_rbga<T>(r_ T, g_ T, b_ T, a_ T) Color {
	return Color{ColorRgba: ColorRgba{r:byte(r_), g:byte(g_), b:byte(b_), a:byte(a_)}}
}

pub fn color_f_rbga<T>(r_ T, g_ T, b_ T, a_ T) Color {
	return Color{ColorRgba: ColorRgba{r:byte(r_ * 255.0), g:byte(g_ * 255.0), b:byte(b_ * 255.0), a:byte(a_ * 255.0)}}
}

pub fn color_hex(withHex u32) Color {
	return Color{hex: withHex}
}
