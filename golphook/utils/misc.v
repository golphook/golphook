module utils

pub struct HResult {
pub:
	val int
}

pub fn (h HResult) bool() bool {

	return if h.val == C.S_OK {
		true
	} else {
		false
	}
}

pub fn h_res(with_hres int) HResult {

	return HResult {val: with_hres}
}

[inline]
pub fn get_key(with_vk_code int, is_toggle bool) bool {

	return if is_toggle {
		(C.GetAsyncKeyState(with_vk_code) & 1) == 1
	} else {
		C.GetAsyncKeyState(with_vk_code) > 1
	}
}

pub fn str_align(with_og_text string, with_spaces_count i32, and_final_sep string) string {

	$if prod { C.VMProtectBeginMutation(c"utils.str_align") }

	mut final := with_og_text

	for _ in 0..(with_spaces_count - with_og_text.len) {
		final += " "
	}
	final += and_final_sep

	$if prod { C.VMProtectEnd() }
	return final
}
