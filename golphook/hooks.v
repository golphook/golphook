module golphook

import utils
import d3d

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

[typedef]
struct C.IDirect3DDevice9 {}

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

	mut device_scan := utils.patter_scan("shaderapidx9.dll", "A3 ? ? ? ? 8D 47 30") or { panic("$err") }
	device_add := voidptr(**(&&&u32(voidptr(usize(device_scan) + 1))))
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

	unsafe {
		ofn := &O_end_scene(app().hooks.end_scene.original_save)
		return ofn(dev)
	}

}
