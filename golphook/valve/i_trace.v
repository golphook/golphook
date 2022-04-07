module valve

import utils

// pub const (
// 	contents_solid = 0x1
// 	contents_moveable = 0x4000
// 	contents_monsterclip = 0x20000
// 	contents_window = 0x2
// 	contents_debris = 0x4000000
// 	contents_hitbox = 0x40000000
// 	contents_grate = 0x8
// 	contents_ignore_nodraw_opaque = 0x2000
// 	contents_opaque = 0x80
//
// 	mask_shot = (contents_solid | contents_moveable | contents_monsterclip | contents_window | contents_debris | contents_hitbox)
// 	mask_opaque = (contents_solid | contents_moveable | contents_opaque)
// 	mask_visible = (mask_opaque | contents_ignore_nodraw_opaque)
// )
//
// pub struct CTraceFilter {
// pub mut:
//     pad [4]u8
//     p_skip voidptr
// }
//
// pub struct CSurface {
//     name &char
//     surface_prop i16
//     flags u16
// }
//
// pub struct CPlane {
//     normal utils.Vec3
//     dist f32
//     plane_type byte
//     signbits byte
//     pad [2]byte
// }
//
//
// pub struct CGameTrace {
// pub mut:
//     start_pos utils.Vec3
//     end_pos utils.Vec3
//     plane CPlane
//     fraction f32
//     contents int
//     disp_flags u32
//     all_solid bool
//     start_solid bool
//     fraction_left_solid f32
//     surface CSurface
//     hit_group int
//     physics_bone int
//     world_durface_index u16
//     hit_entity voidptr
//     hitbox int
// }
//
// [inline]
// pub fn (c &CGameTrace) did_hit() bool {
//     return c.fraction < 1 || c.all_solid || c.start_solid
// }
//
// [inline]
// pub fn (c &CGameTrace) is_invisible() bool {
//     return c.fraction > 0.97
// }
//
// pub struct Ray {
// pub mut:
//     start utils.Vec3
//     delta utils.Vec3
//     start_offset utils.Vec3
//     extents utils.Vec3
//     world_axis_transform voidptr
//     is_ray bool
//     is_swept bool
// }
//
// pub fn (mut r Ray) init(start utils.Vec3, end utils.Vec3) {
//     r.delta = end - start
//     r.is_swept = (r.delta.lenght_sqr() != 0.0)
//     r.extents = utils.new_vec3(0,0,0)
//     r.world_axis_transform = voidptr(0)
//     r.is_ray = true
//     r.start_offset = utils.new_vec3(0,0,0)
//     r.start = start
// }
//
// struct IEngineTrace {}
//
// type P_trace_ray = fn (&Ray, u32, &CTraceFilter, &CGameTrace)
// type P_trace_ray_ent = fn (voidptr, u32, voidptr, voidptr)
//
//
// pub fn (i &IEngineTrace) trace_ray(withRay &Ray, withMask u32, withFilter &CTraceFilter, andTrace &CGameTrace) {
// 	o_fn_add := utils.get_virtual(i, 4)
//
// 	o_fn := &P_trace_ray(o_fn_add)
//
// 	//C.load_this(i)
//
// 	o_fn(withRay, withMask, withFilter, andTrace)
// }
//
// pub fn (i &IEngineTrace) trace_ray_ent(withRay &Ray, withMask u32, withFilter voidptr, andTrace &CGameTrace) {
// 	o_fn_add := utils.get_virtual(i, 3)
//
// 	o_fn := &P_trace_ray_ent(o_fn_add)
//
// 	//C.load_this(i)
//
// 	o_fn(withRay, withMask, withFilter, andTrace)
// }


// pub fn visible(ent &valve.Entity) {
// 	mut app_ctx := unsafe { app() }
//
//
// 	mut tr := &valve.CGameTrace{}
// 	mut ray := &valve.Ray{}
// 	mut filter := &valve.CTraceFilter{}
// 	filter.p_skip = voidptr(app_ctx.ent_cacher.local_player)
//
// 	mut end := ent.bone(8) or {
// 		utils.pront("faield bone 1")
// 		return
// 	}
// 	mut from := app_ctx.ent_cacher.local_player.bone(8) or {
// 		utils.pront("faield bone 2")
// 		return
// 	}
//
// 	ray.init(from, end)
// 	app_ctx.interfaces.i_engine_trace.trace_ray(ray, valve.mask_shot | valve.contents_grate, filter, tr)
// 	//app_ctx.interfaces.i_engine_trace.trace_ray_ent(ray, valve.mask_shot | valve.contents_grate, ent, tr)
//
// 	// if tr.is_invisible() {
// 	// 	mut screen_pos ,box_height, box_width := calculate_box(ent, (utils.distance_from(app_ctx.ent_cacher.local_player.origin(), ent.origin()) / 57)) or { return }
// 	// 	app_ctx.rnd_queue.push(new_text(utils.new_vec2((screen_pos.y - box_height), screen_pos.x + (box_width + 30)).vec_3(), "visible: ${tr.is_invisible()}", 9, C.DT_LEFT | C.DT_NOCLIP, utils.color_rbga(255,255,255,255)))
// 	// }
// }
