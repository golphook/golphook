module valve

import utils

pub enum EMaterialVarFlag {
	ignorez = 1 << 15
	wireframe = 1 << 28
}

pub struct IMaterial {}

[callconv: "fastcall"]
type P_set_material_flag = fn(voidptr, usize, EMaterialVarFlag, bool)

pub fn (i &IMaterial) set_material_flag(with_flag EMaterialVarFlag, is_on bool) {

	utils.call_vfunc<P_set_material_flag>(i, 29)(i, 0, with_flag, is_on)
}

pub struct IMaterialSystem {}

[callconv: "fastcall"]
type P_find_material = fn(voidptr, usize, &char, voidptr, bool, voidptr) &IMaterial

pub fn (i &IMaterialSystem) find_material(with_material string) &IMaterial {

	return utils.call_vfunc<P_find_material>(i, 84)(i, 0, &char(with_material.str), voidptr(0), true, voidptr(0))
}
