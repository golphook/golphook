module golphook

import utils
import valve

type O_frame_stage_notify = fn (u32)
type O_end_scene = fn (voidptr) bool
type O_reset = fn (voidptr, voidptr) int
type O_get_viewmodel_fov = fn () f32

[callconv: "fastcall"]
type O_set_viewmodel_offets = fn (voidptr, voidptr, int, f32, f32, f32) int

[callconv: "fastcall"]
type O_lock_cursor = fn (voidptr, voidptr)

[callconv: "fastcall"]
type O_draw_model = fn (voidptr, voidptr, voidptr, &valve.CDrawModelInfo, voidptr, &f32, &f32, &utils.Vec3, int)

[callconv: "fastcall"]
type O_ret_add_check = fn (voidptr, voidptr, &u8) bool

[callconv: "stdcall"]
type O_present = fn (voidptr, voidptr, voidptr, voidptr, voidptr) int

struct HookEntry<T> {
pub mut:
	name          string   [required]
	original_addr voidptr  [required]
	original_save T
	hooked        voidptr  [required]
}

fn (mut h HookEntry<T>) hook() {

	$if prod { C.VMProtectBeginMutation(c"hooks.hook_entry") }

	if C.MH_CreateHook(h.original_addr, h.hooked, &h.original_save) != C.MH_OK {
		utils.error_critical('Failed to hook function', h.name)
		return
	}

	$if prod { C.VMProtectEnd() }
}

fn add_hook<T>(with_name string, with_og_add voidptr, and_hkd_fn voidptr) HookEntry<T> {

	$if prod { C.VMProtectBeginMutation(c"hooks.add_hook") }

	mut hk_entry := HookEntry<T>{
		name: with_name
		original_addr: with_og_add
		hooked: and_hkd_fn
	}
	hk_entry.hook()
	utils.pront(utils.str_align("[+] $with_name", 40, "| Ok!"))

	$if prod { C.VMProtectEnd() }

	return hk_entry

}

struct Hooks {
pub mut:
	frame_stage_notify HookEntry<O_frame_stage_notify>
	present HookEntry<O_present>
	reset HookEntry<O_reset>
	wnd_proc HookEntry<voidptr>
	set_viewmodel_offets HookEntry<O_set_viewmodel_offets>
	get_viewmodel_fov HookEntry<O_get_viewmodel_fov>
	lock_cursor HookEntry<O_lock_cursor>
	draw_model HookEntry<O_draw_model>
	ret_add_check HookEntry<O_ret_add_check>
}

fn (mut h Hooks) bootstrap() {

	$if prod { C.VMProtectBeginMutation(c"hooks.bootstrap") }

	mut app_ctx := unsafe { app() }

	utils.pront("\n[-] bootstraping hooks...")

	if C.MH_Initialize() != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_Initialize()')
		return
	}

	retadd_check_add_client := utils.pattern_scan("client.dll", "55 8B EC 56 8B F1 33 C0 57 8B 7D 08 8B 8E ? ? ? ? 85 C9 7E") or { panic("$err") }
	retadd_check_add_studio := utils.pattern_scan("studiorender.dll", "55 8B EC 56 8B F1 33 C0 57 8B 7D 08 8B 8E ? ? ? ? 85 C9 7E") or { panic("$err") }
	retadd_check_add_mat := utils.pattern_scan("materialsystem.dll", "55 8B EC 56 8B F1 33 C0 57 8B 7D 08 8B 8E ? ? ? ? 85 C9 7E") or { panic("$err") }
	retadd_check_add_engine := utils.pattern_scan("engine.dll", "55 8B EC 56 8B F1 33 C0 57 8B 7D 08 8B 8E ? ? ? ? 85 C9 7E") or { panic("$err") }

	h.ret_add_check = add_hook<O_ret_add_check>("ret_add_check_client()", retadd_check_add_client, &hk_ret_add_check)
	h.ret_add_check = add_hook<O_ret_add_check>("ret_add_check_studio()", retadd_check_add_studio, &hk_ret_add_check)
	h.ret_add_check = add_hook<O_ret_add_check>("ret_add_check_engine()", retadd_check_add_engine, &hk_ret_add_check)
	h.ret_add_check = add_hook<O_ret_add_check>("ret_add_check_mat()", retadd_check_add_mat, &hk_ret_add_check)

	h.frame_stage_notify = add_hook<O_frame_stage_notify>("FrameStageNotify()", utils.get_virtual(app_ctx.interfaces.i_base_client, 37), &hk_frame_stage_notify)
	a := utils.pattern_scan("discordhook.dll", "53 57 FF 15 ? ? ? ? 89 C6 85 C0 78 2E") or { voidptr(0) }
	mut b := usize(a) + 0x2
	c := b + 0x2
	h.present = add_hook<O_present>("Present()", voidptr(**&&usize(c)), &hk_present)	

	set_viewmodel_offets_add := utils.pattern_scan("client.dll", "55 8B EC 8B 45 08 F3 0F 7E 45") or { panic("$err") }
	h.set_viewmodel_offets = add_hook<O_set_viewmodel_offets>("SetViewmodelOffsets()", set_viewmodel_offets_add, &hk_set_viewmodel_offets)

	get_viewmodel_fov_add := utils.pattern_scan("client.dll", "55 8B EC 8B 4D 04 83 EC 08 57") or { panic("$err") }
	h.get_viewmodel_fov = add_hook<O_get_viewmodel_fov>("GetViewModelFov()", get_viewmodel_fov_add, &hk_get_viewmodel_fov)

	if C.MH_EnableHook(C.MH_ALL_HOOKS) != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_EnableHook()')
		return
	}

	$if prod { C.VMProtectEnd() }
}

fn (mut h Hooks) release() {

	$if prod { C.VMProtectBeginMutation(c"hook.release") }

	if C.MH_DisableHook(C.MH_ALL_HOOKS) != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_DisableHook()')
		return
	}

	if C.MH_Uninitialize() != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_Uninitialize()')
		return
	}

	$if prod { C.VMProtectEnd() }
}

[unsafe; callconv: "stdcall"]
fn hk_frame_stage_notify(stage u32) {

	$if prod { C.VMProtectBeginMutation(c"hk_frame_stage_notify") }

	mut app_ctx := unsafe { app() }

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
	
		utils.pront(utils.str_align("[*] hk_frame_stage_notify()", 40, "| Called"))
	}

	if app_ctx.is_ok {
		if app_ctx.interfaces.cdll_int.is_in_game() && app_ctx.interfaces.cdll_int.is_connected() {
			app_ctx.ent_cacher.on_frame()
			app_ctx.skins.on_frame()
			app_ctx.on_frame()
			app_ctx.visuals.on_frame()
			others_on_frame()
		}
	}

	app_ctx.hooks.frame_stage_notify.original_save(stage)

	$if prod { C.VMProtectEnd() }
}

[callconv: "stdcall"; unsafe]
fn hk_present(this voidptr, a voidptr, b voidptr, c voidptr, d voidptr) int {

	mut app_ctx := unsafe { app() }

	mut static called_once := false

	if !called_once {
		utils.pront(utils.str_align("[*] present()", 40, "| Called"))
		app_ctx.d3d.device = this
		app_ctx.d3d.bootstrap()
		app_ctx.hooks.reset = add_hook<O_reset>("Reset()", utils.get_virtual(this, 16), &hk_reset)
	if C.MH_EnableHook(C.MH_ALL_HOOKS) != C.MH_OK {
		utils.error_critical('Error with a minhook fn', 'MH_EnableHook()')
	}
		called_once = true
	}

	if app_ctx.is_ok {
		app_ctx.visuals.on_end_scene()
		app_ctx.rnd_queue.draw_queue()
	}

	return app_ctx.hooks.present.original_save(this, a, b, c, d)
}
/*
[unsafe; callconv: "stdcall"]
fn hk_end_scene(dev voidptr) bool {

	$if prod { C.VMProtectBeginMutation(c"hk_end_scene") }

	mut app_ctx := unsafe { app() }


	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront(utils.str_align("[*] hk_end_scene()", 40, "| Called"))
	}

	if app_ctx.is_ok {
		app_ctx.visuals.on_end_scene()
		app_ctx.rnd_queue.draw_queue()
	}

	$if prod { C.VMProtectEnd() }

	return app_ctx.hooks.end_scene.original_save(dev)
}*/

[unsafe; callconv: "stdcall"]
fn hk_reset(dev voidptr, params voidptr) int {

	$if prod { C.VMProtectBeginMutation(c"hk_reset") }

	mut app_ctx := unsafe { app() }

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront(utils.str_align("[*] hk_reset()", 40, "| Called"))
	}

	if app_ctx.is_ok {
		app_ctx.is_ok = false
		app_ctx.rnd_queue.clear(-1)
		app_ctx.d3d.release()
	}

	ret := app_ctx.hooks.reset.original_save(dev, params)

	if !app_ctx.is_ok {
		app_ctx.d3d.bootstrap()
		app_ctx.is_ok = true
	}

	$if prod { C.VMProtectEnd() }

	return ret
}

[unsafe; callconv: "fastcall"]
fn hk_set_viewmodel_offets(ecx voidptr, edx voidptr, smt int, x f32, y f32, z f32) int {

	$if prod { C.VMProtectBeginMutation(c"hk_set_viewmodel_offsets") }

	mut app_ctx := unsafe { app() }

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront(utils.str_align("[*] hk_set_viewmodel_offets()", 40, "| Called"))
	}

	mut og_x := x
	mut og_y := y
	mut og_z := z

	if app_ctx.is_ok {
		if app_ctx.interfaces.cdll_int.is_in_game() && app_ctx.interfaces.cdll_int.is_connected() {

			if app_ctx.config.active_config.viewmodel_override {
				og_x += app_ctx.config.active_config.viewmodel_override_x
				og_y += app_ctx.config.active_config.viewmodel_override_y
				og_z += app_ctx.config.active_config.viewmodel_override_z
			}
		}
	}

	$if prod { C.VMProtectEnd() }

	return app_ctx.hooks.set_viewmodel_offets.original_save(ecx, edx, smt ,og_x, og_y, og_z)
}

[unsafe; callconv: "stdcall"]
fn hk_get_viewmodel_fov() f32 {

	$if prod { C.VMProtectBeginMutation(c"hk_get_viewmodel_fov") }

	mut app_ctx := unsafe { app() }

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront(utils.str_align("[*] hk_get_viewmodel_fov()", 40, "| Called"))
	}

	mut og_viewmodel_fov := f32(0.0)

	og_viewmodel_fov = app_ctx.hooks.get_viewmodel_fov.original_save()

	if app_ctx.is_ok {
		if app_ctx.interfaces.cdll_int.is_in_game() && app_ctx.interfaces.cdll_int.is_connected() {
			if app_ctx.config.active_config.viewmodel_override {
				return app_ctx.config.active_config.viewmodel_override_fov
			}
		}
	}

	$if prod { C.VMProtectEnd() }

	return og_viewmodel_fov
}

[unsafe; callconv: "fastcall"]
fn hk_ret_add_check(ecx voidptr, edx voidptr, mod_name &u8) bool {
	return true
}
