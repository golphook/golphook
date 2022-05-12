module valve

import utils

struct IInputSystem {}

[callconv: "fastcall"]
type P_enable_input = fn (voidptr, usize, bool)

pub fn (i &IInputSystem) enable_input(is_enabled bool) {
	utils.call_vfunc<P_enable_input>(i, 7)(i, 0, is_enabled)
}
