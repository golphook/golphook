module valve

import utils

pub struct IVModelInfo {}

[callconv: "fastcall"]
type P_get_model_index = fn (voidptr, usize, &char) int

pub fn (i &IVModelInfo) get_model_index(with_model_name string) int {
	return utils.call_vfunc<P_get_model_index>(i, 2)(i, 0, &char(with_model_name.str))
}
