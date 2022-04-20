module valve

import utils

struct IInputSystem {}

type P_enable_input = fn (bool)

pub fn (mut i IInputSystem) enable_input(withVal bool) {
	o_fn_add := utils.get_virtual(i, 7)

	o_fn := &P_enable_input(o_fn_add)
	C.load_this(i)
	o_fn(withVal)
}
