module golphook

import utils
import valve
import nuklear

type O_frame_stage_notify = fn (u32)
type O_end_scene = fn (voidptr) bool
type O_reset = fn (voidptr, voidptr) int

[callconv: "stdcall"]
type O_set_viewmodel_offets = fn (int, f32, f32, f32) int

type O_get_viewmodel_fov = fn () f32

// [callconv: "fastcall"]
// type O_lock_cursor = fn (voidptr, voidptr)

struct HookEntry<T> {
pub mut:
	name          string   [required]
	original_addr voidptr  [required]
	original_save voidptr
	hooked        voidptr  [required]
}



fn (mut h HookEntry<T>) hook() {
	if C.MH_CreateHook(h.original_addr, h.hooked, &h.original_save) != C.MH_OK {
		utils.error_critical('Failed to hook function', h.name)
		return
	}
}

struct Hooks {
pub mut:
	frame_stage_notify HookEntry<O_frame_stage_notify>
	end_scene HookEntry<O_end_scene>
	reset HookEntry<O_reset>
	wnd_proc HookEntry<O_end_scene>
	set_viewmodel_offets HookEntry<O_set_viewmodel_offets>
	get_viewmodel_fov HookEntry<O_get_viewmodel_fov>
	// lock_cursor HookEntry<O_lock_cursor>
}

fn (mut h Hooks) bootstrap() {
	mut app_ctx := unsafe { app() }

	if C.MH_Initialize() != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_Initialize()')
		return
	}

	frm_stg_ntfy_addr := utils.get_virtual(unsafe { voidptr(app().interfaces.i_base_client) },
		37)

	h.frame_stage_notify = HookEntry<O_frame_stage_notify>{
		name: 'FrameStageNotify()'
		original_addr: frm_stg_ntfy_addr
		hooked: &hk_frame_stage_notify
	}
	h.frame_stage_notify.hook()

	device_add := unsafe { app().d3d.device }
	reset_add := utils.get_virtual(device_add, 16)

	h.reset = HookEntry<O_reset>{
		name: 'Reset()'
		original_addr: reset_add
		hooked: &hk_reset
	}
	h.reset.hook()

	// lock_cursor_add := utils.get_virtual(app_ctx.interfaces.i_surface, 67)
	// h.lock_cursor = HookEntry<O_lock_cursor>{
	// 	name: 'LockCursor()'
	// 	original_addr: lock_cursor_add
	// 	hooked: &hk_lock_cursor
	// }
	// h.lock_cursor.hook()

	end_scene_add := utils.get_virtual(device_add, 42)

	h.end_scene = HookEntry<O_end_scene>{
		name: 'EndScene()'
		original_addr: end_scene_add
		hooked: &hk_end_scene
	}
	h.end_scene.hook()

	h.wnd_proc = HookEntry<O_end_scene>{
		name: 'WndProc()'
		original_addr: voidptr(0)
		hooked: &hk_wnd_proc
	}

	h.wnd_proc.original_save = voidptr( C.SetWindowLongA( C.FindWindowA(c"Valve001", &char(0)), -4, i32(h.wnd_proc.hooked)) )
	C.printf(c"wndproc : %p \n", h.wnd_proc.original_save)

	mut set_viewmodel_offets_add := utils.patter_scan("client.dll", "55 8B EC 8B 45 08 F3 0F 7E 45") or { panic("$err") }
	h.set_viewmodel_offets = HookEntry<O_set_viewmodel_offets>{
		name: 'SetViewmodelOffsets()'
		original_addr: set_viewmodel_offets_add
		hooked: &hk_set_viewmodel_offets
	}
	h.set_viewmodel_offets.hook()

	mut get_viewmodel_fov_add := utils.patter_scan("client.dll", "55 8B EC 8B 4D 04 83 EC 08 57") or { panic("$err") }
	h.get_viewmodel_fov = HookEntry<O_get_viewmodel_fov>{
		name: 'GetViewModelFov()'
		original_addr: get_viewmodel_fov_add
		hooked: &hk_get_viewmodel_fov
	}
	h.get_viewmodel_fov.hook()

	if C.MH_EnableHook(C.MH_ALL_HOOKS) != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_EnableHook()')
		return
	}
}



fn (mut h Hooks) release() {
	if C.MH_DisableHook(C.MH_ALL_HOOKS) != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_DisableHook()')
		return
	}

	if C.MH_Uninitialize() != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_Uninitialize()')
		return
	}
}

[unsafe; windows_stdcall]
fn hk_frame_stage_notify(a u32) {

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront('hk_frame_stage_notify() OK !')
	}

	mut app_ctx := unsafe { app() }
	if app_ctx.is_ok {
		if app_ctx.interfaces.cdll_int.is_in_game() && app_ctx.interfaces.cdll_int.is_connected() {
			app_ctx.ent_cacher.on_frame()
			app_ctx.on_frame()
			app_ctx.engine.on_frame()
			visuals_on_frame()
			others_on_frame()
			app_ctx.kill_sound.on_frame()
		}

	}

	unsafe {
		ofn := &O_frame_stage_notify(app().hooks.frame_stage_notify.original_save)
		ofn(a)
	}
}

[unsafe; windows_stdcall]
fn hk_end_scene(dev voidptr) bool {
	mut app_ctx := unsafe { app() }
	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront('hk_end_scene() OK !')
		app_ctx.menu.bootstrap(dev)

	}

	if app_ctx.is_ok {
		visuals_on_end_scene()
		app_ctx.rnd_queue.draw_queue()
	}

	app_ctx.menu.on_send_scene()

	unsafe {
		ofn := &O_end_scene(app().hooks.end_scene.original_save)
		return ofn(dev)
	}

}

[unsafe; windows_stdcall]
fn hk_reset(dev voidptr, params voidptr) int {

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront('hk_reset() OK !')
	}

	mut app_ctx := unsafe { app() }
	if app_ctx.is_ok {
		app_ctx.is_ok = false
		app_ctx.rnd_queue.clear(-1)
		app_ctx.d3d.release()
		app_ctx.menu.release(true)
	}

	unsafe {
		ofn := &O_reset(app().hooks.reset.original_save)
		ret := ofn(dev, params)

		if !app_ctx.is_ok {
			app_ctx.d3d.bootstrap()
			app_ctx.menu.bootstrap(dev)
			app_ctx.is_ok = true
		}
		return ret
	}
}

[unsafe; callconv: "fastcall"]
fn hk_set_viewmodel_offets(ecx voidptr, edx voidptr, smt int, x f32, y f32, z f32) int {

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront('hk_set_viewmodel_offetsl() OK !')
	}

	mut og_x := x
	mut og_y := y
	mut og_z := z

	mut app_ctx := unsafe { app() }
	if app_ctx.is_ok {
		if app_ctx.interfaces.cdll_int.is_in_game() && app_ctx.interfaces.cdll_int.is_connected() {

			if app_ctx.config.active_config.viewmodel_override {
				og_x += app_ctx.config.active_config.viewmodel_override_x
				og_y += app_ctx.config.active_config.viewmodel_override_y
				og_z += app_ctx.config.active_config.viewmodel_override_z
			}
		}
	}

	unsafe {
		ofn := &O_set_viewmodel_offets(app().hooks.set_viewmodel_offets.original_save)
		C.load_this(ecx)
		return ofn(smt ,og_x, og_y, og_z)
	}
}

[unsafe; windows_stdcall]
fn hk_get_viewmodel_fov() f32 {

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront('hk_get_viewmodel_fov() OK !')
	}

	mut app_ctx := unsafe { app() }

	mut og_viewmodel_fov := f32(0.0)

	unsafe {
		ofn := &O_get_viewmodel_fov(app().hooks.get_viewmodel_fov.original_save)
		og_viewmodel_fov = ofn()
	}

	if app_ctx.is_ok {
		if app_ctx.interfaces.cdll_int.is_in_game() && app_ctx.interfaces.cdll_int.is_connected() {
			if app_ctx.config.active_config.viewmodel_override {
				return app_ctx.config.active_config.viewmodel_override_fov
			}
		}
	}
	// og_viewmodel_fov = 100

	return og_viewmodel_fov
}

[callconv: "stdcall"]
fn hk_wnd_proc(withHwnd C.HWND, withMsg u32, withWParam u32, andLParam int) bool {

	mut app_ctx := unsafe { app() }

	if withMsg == C.WM_KEYUP {
		if withWParam == C.VK_INSERT {
			// not proud of this but it ok for now
			if !app_ctx.interfaces.cdll_int.is_con_visible() || app_ctx.menu.is_opened {
				app_ctx.interfaces.cdll_int.execute_client_cmd_unrectricted("toggleconsole")
				//app_ctx.interfaces.c_input.enable_input(!app_ctx.menu.is_opened)
			}
			app_ctx.menu.is_opened = !app_ctx.menu.is_opened

		}
	}

	if app_ctx.menu.is_opened {
		if nuklear.handle_event(withHwnd, withMsg, withWParam, andLParam) == 1 {
			return false
		}
	}

    return C.CallWindowProcW(app_ctx.hooks.wnd_proc.original_save, withHwnd, withMsg, withWParam, andLParam)
}
// [unsafe; callconv: "fastcall"]
// fn hk_lock_cursor(ecx voidptr, edx voidptr) {
//
// 	mut static is_called_once := false
// 	if !is_called_once {
// 		is_called_once = true
// 		utils.pront('hk_lock_cursor() OK !')
// 	}
//
// 	mut app_ctx := unsafe { app() }
//
// 	if app_ctx.is_ok {
// 		// if app_ctx.menu.is_opened {
// 		// 	app_ctx.interfaces.i_surface.unlock_cursor()
// 		// 	return
// 		// }
// 	}
//
// 	unsafe {
// 		ofn := &O_lock_cursor(app().hooks.lock_cursor.original_save)
// 		//C.load_this(ecx)
// 		ofn(ecx, edx)
// 	}
// }
