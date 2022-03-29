module utils

#include "windows.h"

pub fn get_virtual(inThis voidptr, at_index int) voidptr {
	return unsafe { ((*(&&voidptr(inThis)))[at_index]) }
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
			return i16("0x$i".byte())
		}
	})

	pattern_size := bytes_patten.len
	base_addr := byteptr(r)

	max := nt.OptionalHeader.SizeOfImage - u32(pattern_size)

	for i in 0..max {
		mut is_match_pattern := true
		for j in 0..pattern_size {
			unsafe {
				if base_addr[i + j] != bytes_patten[j] && bytes_patten[j] != -1 {
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
