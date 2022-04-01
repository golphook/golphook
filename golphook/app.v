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
	v_mod vmod.Manifest
	file  &C.FILE = 0
	h_wnd C.HWND

	interfaces &Interfaces = 0
	hooks      &Hooks = 0
	d3d &d3d.D3d9 = 0
	rnd_queue &RenderQueue = 0
	ent_cacher &EntityCacher = 0

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

	offsets.load()
	//utils.pront("-- ${offsets.db.netvars.m_vec_view_offset == 264}")
	a.interfaces = &Interfaces{}
	a.interfaces.bootstrap()

	a.d3d = &d3d.D3d9{}
	a.d3d.bootstrap()

	a.rnd_queue = &RenderQueue{}
	a.ent_cacher = &EntityCacher{}

	a.hooks = &Hooks{}
	a.hooks.bootstrap()


	C.Beep(670, 200)
	C.Beep(730, 150)

	utils.pront('all done ! | Hi golphook v$a.v_mod.version :)')
	a.is_ok = true

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

pub fn (mut a App) on_frame() {
	//unsafe { valve.msg_c(utils.color_rbga<int>(142, 68, 173, 255), 'test') }
	a.rnd_queue.push(new_text(utils.new_vec2(4, 4).vec_3(), "golphook v$a.v_mod.version", 12, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	//a.test_sdk()

	// for i in 0..16 {
	// 	ent := a.interfaces.i_entity_list.get_client_entity(i)
	// 	if int(ent) != 0 {
	// 		e_ent := &valve.Entity(ent)
	// 		if e_ent.is_alive() {
	//
	// 			pos := e_ent.origin()
	// 			screen_pos := utils.new_vec3(0,0,0)
	// 			res := a.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
	// 			if res == 0 {
	// 				//C.printf(c"%i -> %f - %f - %f | %f - %f - %f (%i)\n",i ,pos.x, pos.y, pos.z, screen_pos.x, screen_pos.y, screen_pos.z, res)
	// 				a.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "golphook v$a.v_mod.version", 12, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
	// 			}
	// 		}
	// 	}
	// }

	ents := a.ent_cacher.filter(fn (e &valve.Entity, ctx &EntityCacher) bool {
		return e.is_alive() && e.team() != ctx.local_player.team()
	})
	for ent in ents {
		pos := ent.origin()
		screen_pos := utils.new_vec3(0,0,0)
		res := a.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
		if res == 0 {
			a.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "golphook v$a.v_mod.version", 12, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
		}
	}
}

pub fn (mut a App) test_sdk() {

	if (C.GetAsyncKeyState(C.VK_SHIFT) & 1) == 1 {
		utils.pront("Testing -----------")
		// for i in 0..32 {
		// 	ent := a.interfaces.i_entity_list.get_client_entity(i)
		// 	if int(ent) != 0 {
		// 		e_ent := &valve.Entity(ent)
		// 		if e_ent.is_alive() {
		// 			// pos := e_ent.abs_origin()
		// 			// C.printf(c"%f - %f - %f \n", pos.x, pos.y, pos.z)
		// 			// team := e_ent.team()
		// 			// C.printf(c"%i - %i \n", i, team)
		//
		// 			// pos := e_ent.bone(7)
		// 			// C.printf(c"%f - %f - %f \n", pos.x, pos.y, pos.z)
		//
		// 			pos := e_ent.origin()
		// 			screen_pos := utils.new_vec3(0,0,0)
		// 			res := a.interfaces.i_debug_overlay.screen_pos(pos, screen_pos)
		//
		// 			C.printf(c"%i -> %f - %f - %f | %f - %f - %f (%i)\n",i ,pos.x, pos.y, pos.z, screen_pos.x, screen_pos.y, screen_pos.z, res)
		// 			a.rnd_queue.push(new_text(utils.new_vec2(screen_pos.y, screen_pos.x).vec_3(), "golphook v$a.v_mod.version", 12, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
		//
		// 		}
		// 	}
		// }
		// utils.pront("Testing -----------")
		C.printf(c"local player -> %i \n", a.interfaces.cdll_int.get_local_player())

	}

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
