module valve

import utils

pub struct IEntityList {}

[callconv: "fastcall"]
type P_get_client_entity = fn (voidptr, usize, i32) voidptr

[callconv: "fastcall"]
type P_get_client_entity_handle = fn (voidptr, usize, u32) voidptr

[callconv: "fastcall"]
type P_get_highest_index = fn(voidptr, usize) u32


pub fn (i &IEntityList) get_client_entity(at_idx int) voidptr {

	return utils.call_vfunc<P_get_client_entity>(i, 3)(i, 0, at_idx)
}

pub fn (i &IEntityList) get_client_entity_handle(with_hnd u32) voidptr {

	return utils.call_vfunc<P_get_client_entity_handle>(i, 4)(i, 0, with_hnd)
}

pub fn (i &IEntityList) get_highest_index() u32 {

	return utils.call_vfunc<P_get_highest_index>(i, 6)(i, 0)
}
