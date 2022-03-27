module golphook

import v.vmod
import golphook.utils
import golphook.valve

[heap]
pub struct App {
pub mut:
	h_mod voidptr
	v_mod vmod.Manifest
	file  &C.FILE = 0

	interfaces Interfaces
	hooks      Hooks

	is_ok bool
}

pub fn (mut a App) bootstrap(withModuleHandle voidptr) {
	utils.print('bootstraping..')

	a.h_mod = withModuleHandle

	a.v_mod = vmod.decode(@VMOD_FILE) or { panic(err.msg) }

	$if debug {
		utils.load_unload_console(true, a.file)
	}
	a.interfaces = Interfaces{}
	a.interfaces.bootstrap()

	a.hooks = Hooks{}
	a.hooks.bootstrap()

	C.Beep(670, 200)
	C.Beep(730, 150)

	utils.print('all done !')

	// valve.msg("hello")
	// valve.msg_c(utils.Color{142, 68, 173, 255}, "no way !")
}

pub fn (mut a App) release() {
	a.hooks.release()

	utils.print('bye :)')
	unsafe { utils.load_unload_console(false, a.file) }
	C.FreeLibraryAndExitThread(a.h_mod, 0)
}

pub fn (a App) test() {
	unsafe { valve.msg_c(utils.Color{142, 68, 173, 255}, 'test') }
}

[unsafe]
pub fn app() &App {
	mut static ctx := voidptr(0)

	if int(ctx) == 0 {
		ctx = voidptr(&App{})

		if int(ctx) == 0 {
			utils.error_critical('Failed to initialize app', '')
		}
	}
	return &App(ctx)
}
