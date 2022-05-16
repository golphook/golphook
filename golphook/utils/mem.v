module utils

import time

#include "windows.h"

[inline]
pub fn get_virtual(inThis voidptr, at_index int) voidptr {
	return unsafe { ((*(&&voidptr(inThis)))[at_index]) }
}

[inline]
pub fn call_vfunc<T>(from_class voidptr, at_idx int) T {
	return T(get_virtual(from_class, at_idx))
}


[typedef]
struct C.IMAGE_DOS_HEADER {
	pad [14]u16
	padd [4]u16
	paddd [2]u16
	padddd [10]u16
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


pub fn patter_scan(inModule string, andSing string) ?voidptr {

	r := C.GetModuleHandleA(&char(inModule.str))
	dos := &C.IMAGE_DOS_HEADER(r)
	nt := &C.IMAGE_NT_HEADERS(voidptr(usize(voidptr(r)) + usize(dos.e_lfanew)))

	mut bytes_patten := andSing.split(" ").map(fn (i string) i16 {
		if i == "?" {
			return -1
		} else {
			return i16("0x$i".u8())
		}
	})

	pattern_size := bytes_patten.len
	base_addr := byteptr(r)

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

	return error("Cannot find address with pattern: $andSing")
}

// ne pas passer de voidptr dans T sinon ca fait un &voidptr ce qui est egal a void**
// alors que si a la palce on passe un usize ca fait usize*
pub fn get_val_offset<T>(inThis voidptr, withOffset usize) &T {
	return unsafe { &T(usize(inThis) + withOffset) }
}

struct Value<T> {
	ptr voidptr
}

pub fn (r &Value<T>) get<T>() T {
	return *&T(r.ptr)
}

pub fn (r &Value<T>) set(with_new_val T) {
	// bypass v cannot mut return value
	unsafe {
		*&T(r.ptr) = with_new_val
	}
}

pub fn wait_for_module(mut with_modules []string, and_max_timeout int) {

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
}
