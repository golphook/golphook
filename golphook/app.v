module golphook

import v.vmod
import utils
import offsets
import valve
import d3d

[heap]
pub struct App {
pub mut:
	h_mod voidptr
	h_wnd C.HWND
	h_client voidptr

	wnd_height int
	wnd_width int

	v_mod vmod.Manifest
	file  &C.FILE = 0

	interfaces &Interfaces = 0
	hooks      &Hooks = 0
	d3d &d3d.D3d9 = 0
	rnd_queue &RenderQueue = 0
	ent_cacher &EntityCacher = 0
	config &ConfigManager = 0

	engine &Engine = 0
	visuals &Visuals = 0
	menu &NMenu = 0
	chams &Chams = 0
	kill_sound &KillSound = 0
	skins &Skins = 0

	is_ok bool
}

pub fn (mut a App) bootstrap(with_module_handle voidptr) {

	a.h_mod = with_module_handle

	$if debug {
		utils.load_unload_console(true, a.file)
	}

	utils.pront('[+] initializing the golp !\n')

	utils.pront('[-] waiting for modules to load...')
	mut modules := ["client.dll", "engine.dll", "vstdlib.dll", "vguimatsurface.dll", "inputsystem.dll", "studiorender.dll", "materialsystem.dll"]
	utils.wait_for_module(mut modules, 40)

	a.h_client = voidptr(C.GetModuleHandleA(c"client.dll"))
	a.v_mod = vmod.decode(@VMOD_FILE) or { panic(err.msg()) }

	a.h_wnd = C.FindWindowA(0, c"Counter-Strike: Global Offensive - Direct3D 9")

	if usize(a.h_wnd) == 0 {
		utils.error_critical('Failed to find window with name', 'Counter-Strike: Global Offensive - Direct3D 9')
	}

	offsets.load()
	a.config = &ConfigManager{}
	a.config.bootstrap()
	a.interfaces = &Interfaces{}
	a.interfaces.bootstrap()
	a.interfaces.cdll_int.get_screen_size(&a.wnd_width, &a.wnd_height)
	a.d3d = &d3d.D3d9{}
	a.d3d.bootstrap()
	a.kill_sound = &KillSound{}
	a.rnd_queue = &RenderQueue{}
	a.ent_cacher = &EntityCacher{}
	a.engine = &Engine{}
	a.visuals = &Visuals{}
	a.chams = &Chams{}
	a.skins = &Skins{}
	a.menu = &NMenu{}
	a.hooks = &Hooks{}
	a.hooks.bootstrap()

	C.Beep(670, 200)
	C.Beep(730, 150)

	utils.pront('\n[*] golp is ready | Hi golphook v$a.v_mod.version :)\n')
	a.is_ok = true
}

pub fn (mut a App) release() {

	a.hooks.release()
	a.menu.release(false)
	a.d3d.release()

	utils.pront('\n[*] bye golpy\n')

	unsafe { utils.load_unload_console(false, a.file) }

	C.FreeLibraryAndExitThread(a.h_mod, 0)
}

pub fn (mut a App) on_frame() {

	a.interfaces.cdll_int.get_screen_size(&a.wnd_width, &a.wnd_height)
}

[unsafe]
pub fn app() &App {

	mut static ctx := voidptr(0)

	if isnil(ctx) {
		ctx = voidptr(&App{})

		if isnil(ctx) {
			utils.error_critical('Failed to initialize app', '')
		}
	}
	return &App(ctx)
}
