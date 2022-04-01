module golphook

import utils

type O_frame_stage_notify = fn (u32)
type O_end_scene = fn (voidptr) bool

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
}

fn (mut h Hooks) bootstrap() {



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
	end_scene_add := utils.get_virtual(device_add, 42)

	h.end_scene = HookEntry<O_end_scene>{
		name: 'EndScene()'
		original_addr: end_scene_add
		hooked: &hk_end_scene
	}
	h.end_scene.hook()


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
		app_ctx.ent_cacher.on_frame()
		app_ctx.on_frame()
	}

	unsafe {
		ofn := &O_frame_stage_notify(app().hooks.frame_stage_notify.original_save)
		ofn(a)
	}
}

[unsafe; windows_stdcall]
fn hk_end_scene(dev voidptr) bool {

	mut static is_called_once := false
	if !is_called_once {
		is_called_once = true
		utils.pront('hk_end_scene() OK !')
	}

	mut app_ctx := unsafe { app() }

	if app_ctx.is_ok {

		app_ctx.rnd_queue.draw_queue()

	}

	unsafe {
		ofn := &O_end_scene(app().hooks.end_scene.original_save)
		return ofn(dev)
	}

}
