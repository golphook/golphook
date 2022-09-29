module valve

import utils

type P_con_color_msg = fn (&utils.Color, &char)
type P_con_msg = fn (&char)

[unsafe]
pub fn msg_c(with_color utils.Color, and_text string) {

	$if prod { C.VMProtectBeginMutation(c"valve.msg_C") }
	
	// TODO: ici memory leak a cause de color =
	color := &with_color

	mut static o_fn := &P_con_color_msg(0)
	if isnil(o_fn) {
		o_fn = &P_con_color_msg(C.GetProcAddress(C.GetModuleHandleA(c'tier0.dll'), c'?ConColorMsg@@YAXABVColor@@PBDZZ'))
	}

	mut final := '[golphook] $and_text \n'

	o_fn(color, &char(final.str))

	$if prod { C.VMProtectEnd() }
}

[unsafe]
pub fn msg(with_text string) {

	$if prod { C.VMProtectBeginMutation(c"valve.msg") }

	mut static o_fn := &P_con_msg(0)
	if isnil(o_fn) {
		o_fn = &P_con_msg(C.GetProcAddress(C.GetModuleHandleA(c'tier0.dll'), c'?ConMsg@@YAXPBDZZ'))
	}

	mut final := '[golphook] $with_text \n'

	o_fn(&char(final.str))

	$if prod { C.VMProtectEnd() }
}
