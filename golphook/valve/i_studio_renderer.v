module valve

import utils

pub struct CDrawModelInfo {
pub:
	studio_hdr voidptr
	hardware_data voidptr
	decals int
	skin int
	body int
	hitbox_set int
	renderable &IClientRenderable
}

pub enum DrawModelState {
	draw_entire_model = 0
	draw_opaque_only = 0x01
	draw_translucent_only = 0x02
	draw_group_mask = 0x03
	draw_no_flexes = 0x04
	draw_static_lighting = 0x08
	draw_accuratetime = 0x10
	draw_no_shadows = 0x20
	draw_get_perf_stats = 0x40
	draw_wireframe = 0x80
	draw_item_blink = 0x100
	shadowdepthtexture = 0x200
	unused = 0x400
	skip_decals = 0x800
	model_is_cacheable = 0x1000
	shadowdepthtexture_include_translucent_materials = 0x2000
	no_primary_draw = 0x4000
	ssaodepthtexture = 0x8000
}

pub enum EOverrideType {
	normal = 0
	build_shadows
	depth_write
	selective
	ssao_depth_write
}

pub struct IStudioRender {}

[callconv: "fastcall"]
type P_set_color_modulation = fn (voidptr, usize, &utils.ColorRgbF)

[callconv: "fastcall"]
type P_set_alpha_modulation = fn (voidptr, usize, f32)

[callconv: "fastcall"]
type P_force_material_override = fn (voidptr, usize, &IMaterial, EOverrideType, int)

[callconv: "fastcall"]
type P_is_forced_material_override = fn (voidptr, usize) bool

pub fn (i &IStudioRender) set_color_modulation(with_color &utils.ColorRgbF) {

	utils.call_vfunc<P_set_color_modulation>(i, 27)(i, 0, with_color)
}

pub fn (i &IStudioRender) set_alpha_modulation(with_alpha f32) {

	utils.call_vfunc<P_set_alpha_modulation>(i, 28)(i, 0, with_alpha)
}

pub fn (i &IStudioRender) force_material_override(with_material &IMaterial, with_override_type EOverrideType, and_idx int) {

	utils.call_vfunc<P_force_material_override>(i, 33)(i, 0, with_material, with_override_type, and_idx)
}

pub fn (i &IStudioRender) is_forced_material_override() bool {

	return utils.call_vfunc<P_is_forced_material_override>(i, 34)(i, 0)
}
