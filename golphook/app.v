module golphook

import v.vmod

import utils

#include "windows.h"

fn C.MessageBoxA(int, &char, &char, int) int
fn C.FreeLibraryAndExitThread(voidptr, u32) bool
fn C.Beep(u32, u32) bool

[heap]
pub struct App {
pub mut:
	h_mod voidptr
	v_mod vmod.Manifest
	file &C.FILE = 0
}

pub fn (mut a App) bootstrap(withModuleHandle voidptr) {
	a.h_mod = withModuleHandle

	a.v_mod = vmod.decode( @VMOD_FILE ) or { panic(err.msg) }

	unsafe { utils.load_unload_console(true, a.file) }
	//C.MessageBoxA(0, c"golphook", c"hi", 0)
}

pub fn (mut a App) release() {
	unsafe { utils.load_unload_console(false, a.file) }
	C.FreeLibraryAndExitThread(a.h_mod, 0)
}

fn init_app_singleton() voidptr {
	mut s := &App{}
	return voidptr(s)
}

/*
const app_singleton = init_app_singleton()

pub fn app() &App {
	mut a := &App(app_singleton)
	return a
}
*/
