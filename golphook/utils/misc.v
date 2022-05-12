module utils

pub struct HResult {
pub:
	val int
}

pub fn (h HResult) bool() bool {
	if h.val == C.S_OK {
		return true
	}
	return false
}

pub fn h_res(withHresult int) HResult {
	return HResult { val: withHresult }
}

[inline]
pub fn get_key(withVkCode int, toggle bool) bool {
	if toggle {
		return (C.GetAsyncKeyState(withVkCode) & 1) == 1
	}
	return C.GetAsyncKeyState(withVkCode) > 1
}

pub fn str_align(with_og_text string, with_spaces_count i32, and_final_sep string) string {

	mut final := with_og_text

	for _ in 0..(with_spaces_count - with_og_text.len) {
		final += " "
	}
	final += and_final_sep
	return final
}
