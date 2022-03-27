module golphook

import v.vmod

import utils
import valve

[heap]
pub struct App {
pub mut:
	h_mod voidptr
	v_mod vmod.Manifest
	file &C.FILE = 0

	interfaces Interfaces
	hooks Hooks
}

pub fn (mut a App) bootstrap(withModuleHandle voidptr) {
	a.h_mod = withModuleHandle

	a.v_mod = vmod.decode( @VMOD_FILE ) or { panic(err.msg) }

	unsafe { utils.load_unload_console(true, a.file) }

	a.interfaces = Interfaces{}
	a.interfaces.bootstrap()

	a.hooks = Hooks{}
	a.hooks.bootstrap()

	// valve.msg("hello")
	// valve.msg_c(utils.Color{142, 68, 173, 255}, "no way !")
}

pub fn (mut a App) release() {

	a.hooks.release()

	utils.print("bye :)")
	unsafe { utils.load_unload_console(false, a.file) }
	C.FreeLibraryAndExitThread(a.h_mod, 0)
}

pub fn (a App) test() {
	valve.msg_c(utils.Color{142, 68, 173, 255}, "test")
}



[unsafe]
pub fn app() &App {

	mut static ctx := voidptr(0)

	if int(ctx) == 0 {
		ctx = voidptr(&App{})
	}
	return &App(ctx)
}
