module d3d

#flag -I @VMODROOT/exts/directx
#flag -L @VMODROOT/exts/directx

#flag -l d3d9
#flag -l d3dx9

#include "d3d9.h"
#include "d3dx9.h"
#include "D3dx9core.h"
#include "D3dx9tex.h"

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

fn C.D3DXCreateSprite(voidptr, &D3dSprite) int
fn C.D3DXCreateTextureFromFileInMemory(voidptr, voidptr, u32, &voidptr) int
fn C.D3DXCreateTextureFromFile(voidptr, &u8, &voidptr) int

type P_idx_line_set_width = fn (voidptr, f32) int
type P_idx_line_draw = fn(voidptr, voidptr, u32, u32) int
type P_idx_draw_text_a = fn(voidptr, voidptr, &char, int, &C.RECT, u32, u32) int
type P_idx_release = fn (voidptr) u32

type P_idx_sprite_begin = fn (voidptr, int) int
type P_idx_sprite_end = fn (voidptr) int
[callconv: "stdcall"] // ahaahhahahahahahaahhaha neved had to use it for all d3d method and it was working without before i went outside for 2 hours, i came back and got fuck 3 hours debuging ?????
type P_idx_sprite_draw = fn (voidptr, voidptr, voidptr, voidptr, voidptr, u32) int
