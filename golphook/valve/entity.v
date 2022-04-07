module valve

import utils
import offsets

struct Entity {}

pub fn (e &Entity) dormant() bool {
	return *(utils.get_val_offset<bool>(e, offsets.db.netvars.m_dormant))
}

pub fn (e &Entity) health() int {
	return *(utils.get_val_offset<int>(e, offsets.db.netvars.m_health))
}

pub fn (e &Entity) life_state() LifeState {
	return *(utils.get_val_offset<LifeState>(e, offsets.db.netvars.m_life_tate))
}

pub fn (e &Entity) is_alive() bool {
	return int(e.life_state()) == 0 && e.health() > 0
}

type P_ent_get_handle = fn () voidptr
pub fn (e &Entity) handle() voidptr {
	o_fn_add := utils.get_virtual(e, 2)
	o_fn := &P_ent_get_handle(o_fn_add)
	C.load_this(e)
	rs := o_fn()
	return rs
}

pub fn (e &Entity) origin() utils.Vec3 {
	return *(utils.get_val_offset<utils.Vec3>(e, offsets.db.netvars.m_vec_origin))
}

pub fn (e &Entity) team() Teams {
	return *(utils.get_val_offset<Teams>(e, offsets.db.netvars.m_team_num))
}

pub fn (e &Entity) view_offset() utils.Vec3 {
	return *(utils.get_val_offset<utils.Vec3>(e, offsets.db.netvars.m_vec_view_offset))
}

pub fn (e &Entity) bone(withBoneIndex usize) ?utils.Vec3 {

	mut res := utils.new_vec3(0, 0, 0)

	mut bones_mat := *(&usize(usize(e) + offsets.db.netvars.m_bone_matrix))
	if bones_mat == 0 {
		return error("bone_mat not available")
	}
	res.x = *(&f32(bones_mat + 0x30 * withBoneIndex + 0x0c))
	res.y = *(&f32(bones_mat + 0x30 * withBoneIndex + 0x1c))
	res.z = *(&f32(bones_mat + 0x30 * withBoneIndex + 0x2c))

	return res
}

pub fn (e &Entity) eye_pos() utils.Vec3 {
	return e.origin() + e.view_offset()
}

pub fn (e &Entity) flags() int {
	return *(utils.get_val_offset<int>(e, offsets.db.netvars.m_flags))
}

pub fn (e &Entity) in_reload() bool {
	return *(utils.get_val_offset<bool>(e, offsets.db.netvars.m_in_reload))
}

pub fn (e &Entity) move_type() int {
	return *(utils.get_val_offset<int>(e, offsets.db.netvars.m_move_type))
}

pub fn (e &Entity) is_scoped() bool {
	return *(utils.get_val_offset<bool>(e, offsets.db.netvars.m_is_scoped))
}

pub fn (e &Entity) weapons(withWeaponIndex u32 , andOffset u32) u32 {
	return *(utils.get_val_offset<u32>(e, offsets.db.netvars.m_my_weapons + withWeaponIndex * andOffset))
}

pub fn (e &Entity) active_weapon() u32 {
	return *(utils.get_val_offset<u32>(e, offsets.db.netvars.m_active_weapon))
}

pub fn (e &Entity) viewmodel() u32 {
	es := *(utils.get_val_offset<u32>(e, offsets.db.netvars.m_view_model))
	return es
}

pub fn (e &Entity) observer_target() u32 {
	return *(utils.get_val_offset<u32>(e, offsets.db.netvars.m_observer_target))
}

pub fn (e &Entity) glow_index() int {
	return *(utils.get_val_offset<int>(e, offsets.db.netvars.glow_index))
}
