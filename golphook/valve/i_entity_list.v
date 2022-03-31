module valve

import utils

#flag -I @VMODROOT/golphook/c

#include "reg.h"

fn C.load_this(voidptr)

struct IEntityList {
}

type P_get_client_entity = fn (int) voidptr
type P_get_client_entity_handle = fn (u32) voidptr
type P_get_highest_index = fn() u32

pub fn (mut i IEntityList) get_client_entity(atIndex int) voidptr {
	o_fn_add := utils.get_virtual(i, 3)

	o_fn := &P_get_client_entity(o_fn_add)

	// kill me for this but i dont the choice to do like this, v inline asm dont support msvc one, and a absolutly need to pass the this ptr to ecx
	// this is definitly no safe beause its "emulate" a thiscall
	C.load_this(i)

	rs := o_fn(atIndex)
	return rs
}

pub fn (mut i IEntityList) get_client_entity_handle(withHandle u32) voidptr {
	o_fn_add := utils.get_virtual(i, 4)

	// to test if load_this(i) is needed here also

	o_fn := &P_get_client_entity_handle(o_fn_add)
	return o_fn(withHandle)
}

pub fn (mut i IEntityList) get_highest_index() u32 {
	o_fn_add := utils.get_virtual(i, 6)

	// to test if load_this(i) is needed here also

	o_fn := &P_get_highest_index(o_fn_add)
	return o_fn()
}
