module valve

import utils
import offsets

pub enum Teams {
	no_team = 0
	specs
	terrorists
	counter_terrorists
}

pub enum LifeState {
	alive = 0
	dying
	dead
	respawnable
	discard_body
}


struct Entity {

}

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
