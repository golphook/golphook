module valve

import utils

struct IVModelInfo {}

type P_get_model_index = fn (&char) int

pub fn (mut i IVModelInfo) get_model_index(withModelName string) int {
	o_fn_add := utils.get_virtual(i, 2)

	o_fn := &P_get_model_index(o_fn_add)

	C.load_this(i)

	rs := o_fn(&char(withModelName.str))
	return rs
}
