module utils

import time

#include "windows.h"

[inline]
pub fn get_virtual(in_this_obj voidptr, at_index int) voidptr {
	return unsafe { ((*(&&voidptr(in_this_obj)))[at_index]) }
}

[inline]
pub fn call_vfunc<T>(from_class voidptr, at_idx int) T {
	return T(get_virtual(from_class, at_idx))
}

// ne pas passer de voidptr dans T sinon ca fait un &voidptr ce qui est egal a void**
// alors que si a la palce on passe un usize ca fait usize*
pub fn get_val_offset<T>(in_this_obj voidptr, at_offset usize) &T {
	return unsafe { &T(usize(in_this_obj) + at_offset) }
}

struct Value<T> {
	ptr voidptr
}

pub fn (r &Value<T>) get<T>() T {

	return *&T(r.ptr)
}

pub fn (r &Value<T>) set(with_new_val T) {

	$if prod { C.VMProtectBeginMutation(c"utils.set_val") }

	// bypass v cannot mut return value
	unsafe {
		*&T(r.ptr) = with_new_val
	}
	
	$if prod { C.VMProtectEnd() }
}

[typedef]
struct C.IMAGE_DOS_HEADER {
	pad [14]u16
	pud [4]u16
	ped [2]u16
	pyd [10]u16
	e_lfanew int
}

[typedef]
struct C.IMAGE_OPTIONAL_HEADER {
	Magic u16
	pad [52]byte
	SizeOfImage u32
}


[typedef]
struct C.IMAGE_NT_HEADERS {
	pad [24]u8
	OptionalHeader C.IMAGE_OPTIONAL_HEADER
}


pub fn pattern_scan(in_module string, with_sig string) ?voidptr {

	$if prod { C.VMProtectBeginMutation(c"utils.pattern_scan") }

	module_base := C.GetModuleHandleA(&char(in_module.str))
	dos := &C.IMAGE_DOS_HEADER(module_base)
	nt := &C.IMAGE_NT_HEADERS(voidptr(usize(voidptr(module_base)) + usize(dos.e_lfanew)))

	mut bytes_patten := with_sig.split(" ").map(fn (i string) i16 {
		if i == "?" {
			return -1
		} else {
			return i16("0x$i".u8())
		}
	})

	pattern_size := bytes_patten.len
	base_addr := &u8(module_base)

	max := nt.OptionalHeader.SizeOfImage - u32(pattern_size)

	for i in 0..max {
		mut is_match_pattern := true
		for j in 0..pattern_size {
			unsafe {
				if base_addr[i + j] != u8(bytes_patten[j]) && bytes_patten[j] != -1 {
					is_match_pattern = false
					break
				}
			}
		}

		if is_match_pattern {
			unsafe { return voidptr(&base_addr[i]) }
		}
	}

	$if prod { C.VMProtectEnd() }

	return error("Cannot find address with pattern: $with_sig")
}

pub fn wait_for_module(mut with_modules []string, and_max_timeout int) {

	$if prod { C.VMProtectBeginMutation(c"utils.wait_for_mods") }

	mut total_waited := 0

	for {
		for idx, mod in with_modules {
			if int(C.GetModuleHandleA(&char(mod.str))) != 0 {
				utils.pront(mod)
				with_modules.delete(idx)
			}
		}

		if with_modules.len != 0 {
			if total_waited > and_max_timeout {
				utils.error_critical("Some module arn't loaded", with_modules.join(", "))
			}
			total_waited++
		} else {
			break
		}
		C.Sleep(1000)
	}

	$if prod { C.VMProtectEnd() }
}
