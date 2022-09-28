module nuklear

#flag -I @VMODROOT/exts/nuklear

#flag -D NK_INCLUDE_STANDARD_i32
#flag -D NK_INCLUDE_FIXED_TYPES
#flag -D NK_INCLUDE_STANDARD_IO
#flag -D NK_INCLUDE_STANDARD_VARARGS
#flag -D NK_INCLUDE_DEFAULT_ALLOCATOR
#flag -D NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#flag -D NK_INCLUDE_FONT_BAKING
#flag -D NK_INCLUDE_DEFAULT_FONT

#flag -D NK_IMPLEMENTATION
#flag -D NK_D3D9_IMPLEMENTATION

/*
start:
init hooks
d3d
bootstrap nk
hook window long


end:
( menu closed )
hooks release
menu release

*/

#include "nuklear.h"
#include "nuklear_d3d9.h"

// hi

pub struct C.nk_context {}
pub struct C.nk_rect {
	x f32
	y f32
	w f32
	h f32
}

pub struct C.nk_vec2 {
	x f32
	y f32
}

pub struct C.nk_color {
mut:
	r u8
	g u8
	b u8
	a u8
}

pub struct C.nk_colorf {
	r f32
	g f32
	b f32
	a f32
}




fn C.nk_d3d9_init(voidptr, int, int) &C.nk_context
fn C.nk_d3d9_font_stash_begin(&voidptr)
fn C.nk_d3d9_font_stash_end()
fn C.nk_d3d9_handle_event(C.HWND, u32, u32, int) int
fn C.nk_d3d9_render(int)
fn C.nk_d3d9_release()
fn C.nk_d3d9_resize(int, int)
fn C.nk_d3d9_shutdown()

fn C.nk_begin(voidptr, &char, C.nk_rect, u32) int
fn C.nk_end(voidptr)

fn C.nk_input_begin(voidptr)
fn C.nk_input_end(voidptr)

fn C.nk_layout_row_dynamic(voidptr, i32, i32)
fn C.nk_layout_row_end(voidptr)
fn C.nk_layout_row_begin(voidptr, int, f32, int)
fn C.nk_layout_row_push(voidptr, f32)
fn C.nk_checkbox_label(voidptr, &char, &i32) i32
fn C.nk_button_label(voidptr, &char) i32

fn C.nk_filter_default(voidptr, u8) i32

fn C.nk_property_int(voidptr, &char, i32, &i32, i32, i32, f32)
fn C.nk_propertyi(voidptr, &char, i32, i32, i32, i32, f32) i32
fn C.nk_property_float(voidptr, &char, f32, &f32, f32, f32, f32)

fn C.nk_edit_string(voidptr, i32, voidptr, &i32, i32, voidptr)
fn C.nk_label(voidptr, &char, i32)
fn C.nk_combo_begin_label(voidptr, &char, C.nk_vec2) i32
fn C.nk_combo_item_label(voidptr, &char, i32) i32
fn C.nk_combo_end(voidptr)
fn C.nk_widget_width(voidptr) f32

fn C.nk_group_begin(voidptr, &char, i32) i32
fn C.nk_group_end(voidptr)

fn C.nk_selectable_label(voidptr, &char, i32, &i32) i32

fn C.nk_color_f(&f32, &f32, &f32, &f32, C.nk_color)
fn C.nk_rgb_cf(C.nk_colorf) C.nk_color
fn C.nk_rgba_f(f32, f32, f32, f32) C.nk_color

fn C.nk_combo_begin_color(voidptr, C.nk_color, C.nk_vec2) i32
fn C.nk_color_picker(voidptr, C.nk_colorf, i32) C.nk_colorf

fn C.nk_style_from_table(voidptr, voidptr)
