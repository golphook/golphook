module valve

import utils

pub struct ISurface {}

[callconv: "fastcall"]
type P_lock_cursor = fn (voidptr, usize)

[callconv: "fastcall"]
type P_unlock_cursor = fn (voidptr, usize)

pub fn (i &ISurface) unlock_cursor() {

	utils.call_vfunc<P_unlock_cursor>(i, 66)(i, 0)
}

pub fn (i &ISurface) lock_cursor() {

	utils.call_vfunc<P_lock_cursor>(i, 67)(i, 0)
}
