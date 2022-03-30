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
