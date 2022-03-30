module valve

import utils


struct IEntityList {
}

type P_get_client_entity = fn (voidptr, u32) voidptr
type P_get_client_entity_handle = fn (voidptr, u32) voidptr
type P_get_highest_index = fn(voidptr) u32

pub fn (mut i IEntityList) get_client_entity(atIndex u32) voidptr {
	fn_add := utils.get_virtual(i, 3)

	o_fn := &P_get_client_entity(fn_add)
	return o_fn(i, atIndex)
}

pub fn (mut i IEntityList) get_client_entity_handle(withHandle u32) voidptr {
	fn_add := utils.get_virtual(i, 4)

	o_fn := &P_get_client_entity_handle(fn_add)
	return o_fn(i, withHandle)
}

pub fn (mut i IEntityList) get_highest_index() u32 {
	fn_add := utils.get_virtual(i, 4)

	o_fn := &P_get_highest_index(fn_add)
	return o_fn(i)
}
