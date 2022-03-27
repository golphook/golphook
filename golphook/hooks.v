module golphook

import utils

type O_frame_stage_notify = fn (u32)

struct HookEntry<T> {
pub mut:
	name string [required]
	original_addr voidptr [required]
	original_save &voidptr = 0
	hooked voidptr [required]
}

fn (mut h HookEntry<T>) hook() {
	if C.MH_CreateHook(h.original_addr, h.hooked, h.original_save) != C.MH_OK {
		utils.print("MH_CreateHook(h.original_addr, h.hooked, &h.original_save) failed")
		return
	}
}

struct Hooks {
pub mut:
	frame_stage_notify HookEntry<O_frame_stage_notify>
}

fn (mut h Hooks) bootstrap() {


	if C.MH_Initialize() != C.MH_OK {
		utils.print("MH_Initialize() failed")
		return
	}


	frm_stg_ntfy_addr := utils.get_virtual(unsafe { voidptr(app().interfaces.i_base_client) }, 37)
	h.frame_stage_notify = HookEntry<O_frame_stage_notify>{name: "FrameStageNotify()", original_addr: frm_stg_ntfy_addr ,hooked: &hk_frame_stage_notify}
	h.frame_stage_notify.hook()


	if C.MH_EnableHook(C.MH_ALL_HOOKS) != C.MH_OK {
		utils.print("MH_EnableHook(C.MH_ALL_HOOKS) failed")
		return
	}
}

fn (mut h Hooks) release() {
	if C.MH_DisableHook(C.MH_ALL_HOOKS) != C.MH_OK {
		utils.print("MH_DisableHook() failed")
		return
	}

	if C.MH_Uninitialize() != C.MH_OK {
		utils.print("MH_Uninitialize() failed")
		return
	}
}
[unsafe; windows_stdcall]
fn hk_frame_stage_notify(a u32) {

	mut static abc := false
	if !abc {
		abc = true
		utils.print("hk_frame_stage_notify() OK !")
		C.Beep(670, 667)
	}

	if (C.GetAsyncKeyState(C.VK_SHIFT) & 1) == 1 {
		utils.print("mom")
	}

	unsafe { &O_frame_stage_notify( app().hooks.frame_stage_notify.original_addr ) }
}
