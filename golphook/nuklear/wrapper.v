module nuklear

#flag -I @VMODROOT/exts/nuklear

#flag -D NK_INCLUDE_STANDARD_BOOL
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

struct C.nk_context {}
struct C.nk_font_atlas {}
struct C.nk_rect {
	x f32
	y f32
	w f32
	h f32
}


fn C.nk_d3d9_init(voidptr, int, int) &C.nk_context
fn C.nk_d3d9_font_stash_begin(&&C.nk_font_atlas)
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

fn C.nk_layout_row_static(voidptr, f32, i32, i32)
fn C.nk_layout_row_end(voidptr)
fn C.nk_button_label(voidptr, &char) bool
