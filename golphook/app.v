module golphook

import v.vmod
import utils
import valve
import d3d
//import render

[heap]
pub struct App {
pub mut:
	h_mod voidptr
	v_mod vmod.Manifest
	file  &C.FILE = 0
	h_wnd C.HWND

	interfaces &Interfaces = 0
	hooks      &Hooks = 0
	d3d &d3d.D3d9 = 0

	is_ok bool
}

pub fn (mut a App) bootstrap(withModuleHandle voidptr) {
	utils.pront('bootstraping..')
	a.h_mod = withModuleHandle

	a.v_mod = vmod.decode(@VMOD_FILE) or { panic(err.msg) }

	$if debug {
		utils.load_unload_console(true, a.file)
	}

	a.h_wnd = C.FindWindowA(0, c"Counter-Strike: Global Offensive - Direct3D 9")

	if usize(a.h_wnd) == 0 {
		utils.error_critical('Failed to find window with name', 'Counter-Strike: Global Offensive - Direct3D 9')
	}

	a.interfaces = &Interfaces{}
	a.interfaces.bootstrap()

	a.d3d = &d3d.D3d9{}
	a.d3d.bootstrap()

	a.hooks = &Hooks{}
	a.hooks.bootstrap()


	C.Beep(670, 200)
	C.Beep(730, 150)

	utils.pront('all done ! | Hi golphook v$a.v_mod.version :)')

	// valve.msg("hello")
	// valve.msg_c(utils.Color{142, 68, 173, 255}, "no way !")
}

pub fn (mut a App) release() {
	a.hooks.release()
	a.d3d.release()
	utils.pront('bye :)')
	unsafe { utils.load_unload_console(false, a.file) }
	C.FreeLibraryAndExitThread(a.h_mod, 0)
}

pub fn (a App) test() {
	unsafe { valve.msg_c(utils.color_rbga<int>(142, 68, 173, 255), 'test') }
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
