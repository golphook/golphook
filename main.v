module main

import golphook
// hi

fn hello(h_mod voidptr) {


	mut ctx := unsafe { golphook.app() }
	ctx.bootstrap(h_mod)

	for {
		if (C.GetAsyncKeyState(C.VK_END) & 1) == 1 {
			ctx.is_ok = false
			ctx.release()
		}
		C.Sleep(670)
	}
}

[export: DllMain; callconv: "stdcall"]
fn dll_main(h_mod voidptr, reason u32, res voidptr) bool {
	if reason == u32(C.DLL_PROCESS_ATTACH) {
		// mut ctx := unsafe { golphook.app() }
		// ctx.bootstrap(h_mod)
		go hello(h_mod)
	}

	return true
}
