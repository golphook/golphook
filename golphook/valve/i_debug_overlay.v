module valve

import utils

struct IVDebugOverlay {}

type P_screen_pos_1 = fn (&utils.Vec3, &utils.Vec3) int
type P_screen_pos_2 = fn (f32, f32, &utils.Vec3) int

pub fn (mut i IVDebugOverlay) screen_pos(vecIn &utils.Vec3 ,vecOut &utils.Vec3) int {
	o_fn_add := utils.get_virtual(i, 12)

	o_fn := &P_screen_pos_1(o_fn_add)

	rs := o_fn(vecIn, vecOut)
	return rs
}

pub fn (mut i IVDebugOverlay) screen_pos_raw(withX f32, withY f32, vecOut &utils.Vec3) int {
	o_fn_add := utils.get_virtual(i, 12)

	o_fn := &P_screen_pos_2(o_fn_add)

	rs := o_fn(withX, withY, vecOut)
	return rs
}
