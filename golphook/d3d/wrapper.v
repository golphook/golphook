module d3d

import utils

#flag -I @VMODROOT/exts/directx
#flag -I @VMODROOT/golphook/d3d/c
#flag -L @VMODROOT/exts/directx

#flag -l d3d9
#flag -l d3dx9

#include "d3d9.h"
#include "d3dx9.h"

// hi

[typedef]
struct C.RECT {
pub mut:
	left int
	top int
	right int
	bottom int
}

[typedef]
struct C.D3DXVECTOR2 {
pub mut:
	x f32
	y f32
}

fn C.D3DXCreateFontA(voidptr, int, u32, u32, u32, bool, u32, u32, u32, u32, &char, &voidptr) int
fn C.D3DXCreateLine(voidptr, &voidptr) int

type P_idx_line_set_width = fn (voidptr, f32) int
type P_idx_line_draw = fn(voidptr, voidptr, u32, u32) int

type P_dx_draw_text_a = fn(voidptr, voidptr, &char, int, &C.RECT, u32, u32) int

type P_dx_release = fn (voidptr) u32
