module main

import golphook

// hi

fn hello(h_mod voidptr) {

	mut ctx := unsafe { golphook.app() }
	ctx.bootstrap(h_mod)

	for {
		if (C.GetAsyncKeyState(C.VK_DELETE) & 1) == 1 {
			ctx.release()
		}
		C.Sleep(670)
	}


}

[windows_stdcall; export: DllMain]
fn dll_main(h_mod voidptr, reason u32, res voidptr) bool {

	if reason == u32(C.DLL_PROCESS_ATTACH) {
		go hello(h_mod)
	}

	return true
}
