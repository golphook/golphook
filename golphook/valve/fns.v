module valve

import utils

type P_con_color_msg = fn (&utils.Color, &char)
type P_con_msg = fn (&char)

[unsafe]
pub fn msg_c(withColor utils.Color, text string) {
	color := &withColor

	mut static fn_add := voidptr(0)
	if int(fn_add) == 0 {
		fn_add = C.GetProcAddress(C.GetModuleHandleA(c"tier0.dll"), c"?ConColorMsg@@YAXABVColor@@PBDZZ")
	}
	o_fn := &P_con_color_msg(fn_add)

	mut final := "[golphook] $text \n"

	o_fn(color, &char(final.str))
}

[unsafe]
pub fn msg(text string) {

	mut static fn_add := voidptr(0)
	if int(fn_add) == 0 {
		fn_add = C.GetProcAddress(C.GetModuleHandleA(c"tier0.dll"), c"?ConMsg@@YAXPBDZZ")
	}
	o_fn := &P_con_msg(fn_add)

	mut final := "[golphook] $text \n"

	o_fn(&char(final.str))
}
