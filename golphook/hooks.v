module golphook

import utils

type O_frame_stage_notify = fn (u32)
type O_reset = fn (voidptr, voidptr) int

[callconv: "fastcall"]
type O_ret_add_check = fn (voidptr, voidptr, &u8) bool
type O_end_scene = fn (voidptr) bool

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
	end_scene HookEntry<O_end_scene>
	reset HookEntry<O_reset>
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
	h.reset = add_hook<O_reset>("Reset()", utils.get_virtual(app_ctx.d3d.device, 16), &hk_reset)
	h.end_scene = add_hook<O_end_scene>("EndScene()", utils.get_virtual(app_ctx.d3d.device, 42), &hk_end_scene)

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
			app_ctx.on_frame()
			app_ctx.visuals.on_frame()
			others_on_frame()
		}
	}

	app_ctx.hooks.frame_stage_notify.original_save(stage)

	$if prod { C.VMProtectEnd() }
}


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
}

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
fn hk_ret_add_check(ecx voidptr, edx voidptr, mod_name &u8) bool {
	return true
}
