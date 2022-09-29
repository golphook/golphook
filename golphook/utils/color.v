module utils

import nuklear

#flag -I @VMODROOT/golphook/c

#include "d3dh.h"

// TODO: Recreate in V
fn C.d3d_rgba(r int, g int, b int, a int) u32

pub struct ColorRgbF {
pub mut:
	r f32
	g f32
	b f32
}

pub struct ColorRgbaF {
pub mut:
	r f32
	g f32
	b f32
	a f32
}

struct ColorRgba {
pub mut:
	r u8
	g u8
	b u8
	a u8
}

pub union Color {
	ColorRgba
mut:
	rgba u32 [skip]
}

// Get methods to avoid using unsafe to access union in the code

[inline]
pub fn (c &Color) r() u8 {

	return unsafe { c.r }
}

[inline]
pub fn (c &Color) g() u8 {

	return unsafe { c.g }
}

[inline]
pub fn (c &Color) b() u8 {

	return unsafe { c.b }
}

[inline]
pub fn (c &Color) a() u8 {

	return unsafe { c.a }
}

[inline]
pub fn (c &Color) rgba() u32 {

	return unsafe { c.rgba }
}

[inline]
pub fn (c &Color) d3d() u32 {

	return C.d3d_rgba(c.r(), c.g(), c.b(), c.a())
}

[inline]
pub fn (c &Color) rgbaf() ColorRgbaF {

	$if prod { C.VMProtectBeginMutation(c"color.rgbaf") }

	mut r_ := f32(c.r()) / 255.0
	mut g_ := f32(c.g()) / 255.0
	mut b_ := f32(c.b()) / 255.0
	mut a_ := f32(c.a()) / 255.0

	$if prod { C.VMProtectEnd() }

	return ColorRgbaF{r: r_, g: g_, b: b_, a: a_}
}

[inline]
pub fn (c &Color) rgbf() ColorRgbF {

	$if prod { C.VMProtectBeginMutation(c"color.rgbf") }

	mut r_ := f32(c.r()) / 255.0
	mut g_ := f32(c.g()) / 255.0
	mut b_ := f32(c.b()) / 255.0

	$if prod { C.VMProtectEnd() }

	return ColorRgbF{r: r_, g: g_, b: b_}
}

[inline]
pub fn (c &Color) nk_colorf() C.nk_colorf {

	$if prod { C.VMProtectBeginMutation(c"color.nkcolf") }
	
	mut r_ := f32(c.r()) / 255.0
	mut g_ := f32(c.g()) / 255.0
	mut b_ := f32(c.b()) / 255.0
	mut a_ := f32(c.a()) / 255.0

	$if prod { C.VMProtectEnd() }

	return C.nk_colorf{r: r_, g: g_, b: b_, a: a_}
}

pub fn color_rbga<T>(r_ T, g_ T, b_ T, a_ T) Color {

	return Color{ColorRgba: ColorRgba{r:u8(r_), g:u8(g_), b:u8(b_), a:u8(a_)}}
}

pub fn color_f_rbga<T>(r_ T, g_ T, b_ T, a_ T) Color {

	return Color{ColorRgba: ColorRgba{r:u8(r_ * 255.0), g:u8(g_ * 255.0), b:u8(b_ * 255.0), a:u8(a_ * 255.0)}}
}

pub fn color_hex(withHex u32) Color {

	no := Color{rgba: withHex}
	return Color{ColorRgba: ColorRgba{r:no.a(), g:no.r(), b:no.g(), a:no.b()}}
}
