module valve

import utils

pub struct IVDebugOverlay {}

[callconv: "fastcall"]
type P_screen_pos = fn (voidptr, usize, &utils.Vec3, &utils.Vec3) int

[callconv: "fastcall"]
type P_screen_pos_raw = fn (voidptr, usize, f32, f32, &utils.Vec3) int

pub fn (i &IVDebugOverlay) screen_pos(from_vec &utils.Vec3, to_vec &utils.Vec3) bool {

	return utils.call_vfunc<P_screen_pos>(i, 13)(i, 0, from_vec, to_vec) == 0
}

pub fn (i &IVDebugOverlay) screen_pos_raw(from_x f32, and_y f32, to_vec &utils.Vec3) bool {

	return utils.call_vfunc<P_screen_pos_raw>(i, 14)(i, 0, from_x, and_y, to_vec) == 0
}
