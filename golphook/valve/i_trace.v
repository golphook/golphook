module valve

import utils

#flag -I @VMODROOT/golphook/c

#include "trace.h"

pub const (
	contents_solid = 0x1
	contents_moveable = 0x4000
	contents_monsterclip = 0x20000
	contents_window = 0x2
	contents_debris = 0x4000000
	contents_hitbox = 0x40000000
	contents_grate = 0x8
	contents_ignore_nodraw_opaque = 0x2000
	contents_opaque = 0x80

	mask_shot = (contents_solid | contents_moveable | contents_monsterclip | contents_window | contents_debris | contents_hitbox)
	mask_opaque = (contents_solid | contents_moveable | contents_opaque)
	mask_visible = (mask_opaque | contents_ignore_nodraw_opaque)
)

pub struct CTraceFilter {
pub mut:
	v_table voidptr
	p_skip voidptr
}

pub struct CSurface {
	name &char = unsafe { nil }
	surface_prop i16
	flags u16
}

pub struct CGameTrace {
pub mut:
	start_pos utils.Vec3
	end_pos utils.Vec3
	pad [20]u8
	fraction f32
	contents i32
	disp_flags u16
	all_solid bool
	start_solid bool
	pod [4]u8
	surface CSurface
	hit_group HitGroup
	pud [4]u8
	hit_entity voidptr
	hitbox int
}

[inline]
pub fn (c &CGameTrace) did_hit() bool {

    return c.fraction < 1 || c.all_solid || c.start_solid
}

[inline]
pub fn (c &CGameTrace) is_invisible() bool {

    return c.fraction > 0.97
}

pub fn (c &CGameTrace) damage_multiplier() f32 {

  return match c.hit_group {
		.head { 4.0 }
		.stomach { 1.25 }
		.left_leg { 0.75 }
		.right_leg { 0.75 }
		else {
			1.0
		}
	}
}

pub fn (c &CGameTrace) is_armored(hasHelmet bool) bool {

	return match c.hit_group {
		.head { hasHelmet }
		.chest { true }
		.stomach { true }
		.left_arm { true }
		.right_arm { true }
		else {
			false
		}
	}
}

pub struct Ray {
pub mut:
	start utils.Vec3
	pad f32
	delta utils.Vec3
	pod [40]u8
	is_ray bool
	is_swept bool
}

pub fn (mut r Ray) init(from_start utils.Vec3, to_end utils.Vec3) {

	$if prod { C.VMProtectBeginMutation(c"trace.init") }

    r.delta = to_end - from_start
    r.is_swept = (r.delta.lenght_sqr() != 0.0)
    r.is_ray = true
    r.start = from_start

	$if prod { C.VMProtectEnd() }
}

pub struct IEngineTrace {}

fn C.IEngineTrace_trace(voidptr, voidptr, u32, voidptr, voidptr)

pub fn (i &IEngineTrace) trace_ray(with_ray &Ray, with_mask u32, and_filter &CTraceFilter, to_trace &CGameTrace) {

	$if prod { C.VMProtectBeginMutation(c"trace.trace_ray") }

	C.IEngineTrace_trace(i, with_ray, with_mask, and_filter, to_trace)

	$if prod { C.VMProtectEnd() }
}
