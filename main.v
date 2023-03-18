module main

import golphook

fn hello(h_mod voidptr) {

	$if vm ? { C.VMProtectBeginMutation(c"hello") }
	
	mut ctx := unsafe { golphook.app() }
	ctx.bootstrap(h_mod)

	for {
		if (C.GetAsyncKeyState(C.VK_END) & 1) == 1 {
			ctx.is_ok = false
			ctx.release()
		}
		C.Sleep(670)

	}

	$if vm ? { C.VMProtectEnd() }
}

[export: "DllMain"; callconv: "stdcall"]
fn dll_main(h_mod voidptr, reason i32, res voidptr) bool {

	$if vm ? { C.VMProtectBeginMutation(c"dll_main") }

	if reason == u32(C.DLL_PROCESS_ATTACH) {

		C.DisableThreadLibraryCalls(h_mod)

		go hello(h_mod)
	}

	$if vm ? { C.VMProtectEnd() }

	return true
}
