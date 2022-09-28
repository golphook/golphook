module valve

import utils

pub struct IInputSystem {}

[callconv: "fastcall"]
type P_enable_input = fn (voidptr, usize, bool)

pub fn (i &IInputSystem) enable_input(is_enabled bool) {

	utils.call_vfunc<P_enable_input>(i, 7)(i, 0, is_enabled)
}

// test
pub fn (i &IInputSystem) camera_offset() utils.Value<utils.Vec3> {

	return utils.Value<utils.Vec3>{ptr: utils.get_val_offset<utils.Vec3>(i, 0x00B0)}
}

// test
pub fn (i &IInputSystem) is_in_third() utils.Value<bool> {

	return utils.Value<bool>{ptr: utils.get_val_offset<bool>(i, 0x00AD)}
}
