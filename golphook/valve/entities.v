module valve

import utils
import offsets

[callconv: "fastcall"]
type P_ent_get_handle = fn (voidptr, usize) voidptr

[callconv: "fastcall"]
type P_ent_index = fn (voidptr, usize) int

[callconv: "fastcall"]
type P_ent_collideable = fn (voidptr, usize) voidptr

[callconv: "fastcall"]
type P_ent_client_class = fn (voidptr, usize) &CCLientClass

[callconv: "fastcall"]
type P_is_player_or_weapon = fn (voidptr, usize) bool

[callconv: "fastcall"]
type P_abs_angle = fn (voidptr, usize) &utils.Angle

[callconv: "fastcall"]
type P_abs_origin = fn (voidptr, usize) &utils.Vec3

[callconv: "fastcall"]
type P_set_abs_origin = fn (voidptr, usize, &utils.Vec3)

[callconv: "fastcall"]
type P_set_abs_angle = fn (voidptr, usize, &utils.Angle)

[callconv: "fastcall"]
type P_observer_target = fn (voidptr, usize) &Entity_t

[callconv: "fastcall"]
type P_get_base_entity = fn (voidptr, usize) &Entity_t

[callconv: "fastcall"]
type P_get_i_client_unknown = fn (voidptr, usize) &IClientUnknown

// hi

pub struct IClientUnknown {}

pub fn (i &IClientUnknown) get_base_entity() &Entity_t {
	return utils.call_vfunc<P_get_base_entity>(i, 7)(i, 0)
}

pub struct IClientRenderable {}

pub fn (i &IClientRenderable) get_i_client_unknown() &IClientUnknown {
	return utils.call_vfunc<P_get_i_client_unknown>(i, 0)(i, 0)
}

// Entity_t

pub struct Entity_t {}

pub fn (e &Entity_t) animating() voidptr {

	return voidptr(usize(e) + 0x4)
}

pub fn (e &Entity_t) networkable() voidptr {

	return voidptr(usize(e) + 0x8)
}

pub fn (e &Entity_t) handle() voidptr {
	return utils.call_vfunc<P_ent_get_handle>(e, 2)(e, 0)

}

pub fn (e &Entity_t) collideable() voidptr {

	return utils.call_vfunc<P_ent_collideable>(e, 3)(e, 0)
}

pub fn (e &Entity_t) client_class() &CCLientClass {

	return utils.call_vfunc<P_ent_client_class>(e.networkable(), 2)(e.networkable(), 0)
}

pub fn (e &Entity_t) is_player() bool {

	return utils.call_vfunc<P_is_player_or_weapon>(e, 158)(e, 0)
}

pub fn (e &Entity_t) is_weapon() bool {

	return utils.call_vfunc<P_is_player_or_weapon>(e, 166)(e, 0)
}

pub fn (e &Entity_t) index() int {

	return utils.call_vfunc<P_ent_index>(e.networkable(), 10)(e.networkable(), 0)
}

pub fn (e &Entity_t) abs_angle() &utils.Angle{

	return utils.call_vfunc<P_abs_angle>(e, 11)(e, 0)
}

pub fn (e &Entity_t) abs_origin() &utils.Vec3 {

	return utils.call_vfunc<P_abs_origin>(e, 10)(e, 0)
}

pub fn (e &Entity_t) observer_target() u32 {

	return *(utils.get_val_offset<u32>(e, offsets.db.netvars.m_observer_target))
}

pub fn (e &Entity_t) dormant() bool {

	return *(utils.get_val_offset<bool>(e, offsets.db.signatures.m_dormant))
}

pub fn (e &Entity_t) origin() utils.Vec3 {

	return *(utils.get_val_offset<utils.Vec3>(e, offsets.db.netvars.m_vec_origin))
}

pub fn (e &Entity_t) view_offset() utils.Vec3 {

	return *(utils.get_val_offset<utils.Vec3>(e, offsets.db.netvars.m_vec_view_offset))
}

pub fn (w &Entity_t) owner_entity() u32 {

	return *(utils.get_val_offset<u32>(w, offsets.db.netvars.owner_entity))
}


pub fn (e &Entity_t) to_player() &Player {

return unsafe { &Player(voidptr(e)) }
}


// Player

pub struct Player {
	Entity_t
}

pub fn (p &Player) health() int {

	return *(utils.get_val_offset<int>(p, offsets.db.netvars.m_health))
}

pub fn (p &Player) life_state() LifeState {

	return *(utils.get_val_offset<LifeState>(p, offsets.db.netvars.m_life_tate))
}

pub fn (p &Player) team() Teams {

	return *(utils.get_val_offset<Teams>(p, offsets.db.netvars.m_team_num))
}

pub fn (p &Player) flags() int {

	return *(utils.get_val_offset<int>(p, offsets.db.netvars.m_flags))
}

pub fn (p &Player) move_type() int {

	return *(utils.get_val_offset<int>(p, offsets.db.netvars.m_move_type))
}


pub fn (p &Player) bone(with_bone_idx usize) !utils.Vec3 {

	$if vm ? { C.VMProtectBeginMutation(c"player.bone") }

	mut res := utils.new_vec3(0, 0, 0)

	mut bones_mat := *(&usize(usize(p) + offsets.db.netvars.m_bone_matrix))

	if isnil(bones_mat) {
		return error("bone_mat not available")
	}

	res.x = *(&f32(bones_mat + 0x30 * with_bone_idx + 0x0c))
	res.y = *(&f32(bones_mat + 0x30 * with_bone_idx + 0x1c))
	res.z = *(&f32(bones_mat + 0x30 * with_bone_idx + 0x2c))

	$if vm ? { C.VMProtectEnd() }

	return res
}

pub fn (p &Player) velocity() utils.Vec3 {

	return *(utils.get_val_offset<utils.Vec3>(p, offsets.db.netvars.velocity))
}

pub fn (p &Player) is_moving() bool{

	$if vm ? { C.VMProtectBeginMutation(c"player.is_moving") }

	v_vel := p.velocity()

	if (v_vel.x + v_vel.y + v_vel.z) == 0.0 {
		return false
	}

	$if vm ? { C.VMProtectEnd() }

	return true
}

pub fn (p &Player) eye_pos() utils.Vec3 {

	return p.origin() + p.view_offset()
}

pub fn (p &Player) is_alive() bool {

	return int(p.life_state()) == 0 && p.health() > 0
}

pub fn (p &Player) observer_mode() ObserverModes {

	return *(utils.get_val_offset<ObserverModes>(p, offsets.db.netvars.m_observer_mode))
}
