module main

import golphook

import time
import golphook.utils

#include "windows.h"

// hi

fn C.puts(&char)
fn C.GetAsyncKeyState(int) u16

fn spawn(h_mod voidptr) {
	mut a := &golphook.App{}
	a.bootstrap(h_mod)

	C.puts(c"hi")
	for {
	    if (C.GetAsyncKeyState(C.VK_SHIFT) & 1) == 1 {
	    	C.puts(c"mom")
	    }
		if (C.GetAsyncKeyState(C.VK_DELETE) & 1) == 1 {
			a.release()
			break
	    }
  }
}

[windows_stdcall; export: DllMain]
fn dll_main(h_mod voidptr, reason u32, res voidptr) bool {

	if reason == u32(C.DLL_PROCESS_ATTACH) {
		go spawn(h_mod)
	}

	return true
}
