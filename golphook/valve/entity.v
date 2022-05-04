module valve

import utils
import offsets

struct Weapon {}

pub fn (w &Weapon) in_reload() bool {
	return *(utils.get_val_offset<bool>(w, offsets.db.netvars.m_in_reload))
}

pub fn (w &Weapon) owner_entity() u32 {
	return *(utils.get_val_offset<u32>(w, offsets.db.netvars.owner_entity))
}


pub fn (w &Weapon) zoom_level() int {
	return *(utils.get_val_offset<int>(w, offsets.db.netvars.m_zoom_level))
}

pub fn (w &Weapon) postpone_fire_ready_time() f32 {
	return *(utils.get_val_offset<f32>(w, offsets.db.netvars.postpone_fire_ready_time))
}

pub fn (w &Weapon) last_shot_time() f32 {
	return *(utils.get_val_offset<f32>(w, offsets.db.netvars.last_shot_time))
}

pub fn (w &Weapon) next_primary_attack() f32 {
	return *(utils.get_val_offset<f32>(w, offsets.db.netvars.next_primary_attack))
}

pub fn (w &Weapon) clip1() int {
	return *(utils.get_val_offset<int>(w, offsets.db.netvars.clip1))
}

pub fn (w &Weapon) definition_index() i16 {
	return *(utils.get_val_offset<i16>(w, offsets.db.netvars.m_item_definition_index))
}

// not working
// [callconv: "fastcall"]
// type P_wp_get_data = fn (voidptr, voidptr) &WeaponData
//
// pub fn (w &Weapon) weapon_data() {
// 	o_fn_add := utils.get_virtual(w, 460)
// 	o_fn := &P_wp_get_data(o_fn_add)
// 	rs := o_fn(w, voidptr(0))
// 	C.printf(c"%p \n", rs)
// }

struct Entity {}

pub fn (e &Entity) dormant() bool {
	return *(utils.get_val_offset<bool>(e, offsets.db.signatures.m_dormant))
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

pub fn (e &Entity) spotted_by_mask() int {
	return *(utils.get_val_offset<int>(e, offsets.db.netvars.spotted_by_mask))
}

pub fn (e &Entity) next_attack() f32 {
	return *(utils.get_val_offset<f32>(e, offsets.db.netvars.next_attack))
}

pub fn (e &Entity) tick_base() int {
	return *(utils.get_val_offset<int>(e, offsets.db.netvars.tick_base))
}

pub fn (e &Entity) velocity() utils.Vec3 {
	return *(utils.get_val_offset<utils.Vec3>(e, offsets.db.netvars.velocity))
}

pub fn (e &Entity) has_helmet() bool {
	return *(utils.get_val_offset<bool>(e, offsets.db.netvars.m_has_helmet))
}

pub fn (e &Entity) armor() i32 {
	return *(utils.get_val_offset<i32>(e, offsets.db.netvars.m_armor_value))
}

pub fn (e &Entity) is_moving() bool{
	v_vel := e.velocity()
	if (v_vel.x + v_vel.y + v_vel.z) == 0.0 {
		return false
	}
	return true
}


pub fn (e &Entity) spotted() &bool {
	return utils.get_val_offset<bool>(e, offsets.db.netvars.spotted)
}

// mb ca retourne un pointer de vec3
type P_abs_angle = fn () &utils.Angle
pub fn (e &Entity) abs_angle() &utils.Angle{
	o_fn_add := utils.get_virtual(e, 11)
	o_fn := &P_abs_angle(o_fn_add)
	C.load_this(e)
	rs := o_fn()
	return rs
}

[callconv: "stdcall"]
type P_abs_origin = fn () &utils.Vec3
pub fn (e &Entity) abs_origin() &utils.Vec3 {
	o_fn_add := utils.get_virtual(e, 10)
	o_fn := &P_abs_origin(o_fn_add)
	C.load_this(e)
	rs := o_fn()
	return rs
}

[callconv: "stdcall"]
type P_set_abs_origin = fn (&utils.Vec3)
[unsafe]
pub fn (e &Entity) set_abs_origin (withOrigin utils.Vec3) {
	mut static ofn := &P_set_abs_origin(0)
	if int(ofn) == 0 {
		raw_addr := utils.patter_scan("client.dll", "55 8B EC 83 E4 F8 51 53 56 57 8B F1 E8") or { panic("$err") }
		ofn = &P_set_abs_origin(raw_addr)
	}
	C.load_this(e)
	ofn(withOrigin)
}

[callconv: "stdcall"]
type P_set_abs_angle = fn (&utils.Angle)
[unsafe]
pub fn (e &Entity) set_abs_angle(withAngle utils.Angle) {
	mut static ofn := &P_set_abs_angle(0)
	if int(ofn) == 0 {
		raw_addr := utils.patter_scan("client.dll", "55 8B EC 83 E4 F8 83 EC 64 53 56 57 8B F1 E8") or { panic("$err") }
		ofn = &P_set_abs_angle(raw_addr)
	}
	C.load_this(e)
	ofn(withAngle)
}
