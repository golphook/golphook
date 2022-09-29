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

pub fn (e &Entity_t) glow_index() int {

	return *(utils.get_val_offset<int>(e, offsets.db.netvars.glow_index))
}

[unsafe]
pub fn (e &Entity_t) set_abs_origin(with_origin utils.Vec3) {

	$if prod { C.VMProtectBeginMutation(c"ent.set_abs_orig") }

	mut static o_fn := &P_set_abs_origin(0)
	if isnil(o_fn) {
		raw_addr := utils.pattern_scan("client.dll", "55 8B EC 83 E4 F8 51 53 56 57 8B F1 E8") or {
			utils.error_critical("Failed to scan for patern:", "set_abs_origin()")
		}
		o_fn = &P_set_abs_origin(raw_addr)
	}
	o_fn(e, 0, with_origin)

	$if prod { C.VMProtectEnd() }
}

[unsafe]
pub fn (e &Entity_t) set_abs_angle(with_angle utils.Angle) {

	$if prod { C.VMProtectBeginMutation(c"ent.set_abs_angle") }

	mut static o_fn := &P_set_abs_angle(0)
	if isnil(o_fn) {
		raw_addr := utils.pattern_scan("client.dll", "55 8B EC 83 E4 F8 83 EC 64 53 56 57 8B F1 E8") or {
			utils.error_critical("Failed to scan for patern:", "set_abs_origin()")
		}
		o_fn = &P_set_abs_angle(raw_addr)
	}
	o_fn(e, 0, with_angle)

	$if prod { C.VMProtectEnd() }
}

pub fn (e &Entity_t) to_weapon() &Weapon_t {

	return &Weapon_t(voidptr(e))
}

pub fn (e &Entity_t) to_player() &Player {

	return &Player(voidptr(e))
}

pub fn (e &Entity_t) to_item() &Item {

	return &Item(voidptr(e))
}

pub fn (e &Entity_t) to_viewmodel() &Viewmodel {

	return &Viewmodel(voidptr(e))
}

pub struct Weapon_t {
	Entity_t
}

pub fn (w &Weapon_t) in_reload() bool {

	return *(utils.get_val_offset<bool>(w, offsets.db.netvars.m_in_reload))
}

pub fn (w &Weapon_t) zoom_level() int {

	return *(utils.get_val_offset<int>(w, offsets.db.netvars.m_zoom_level))
}

pub fn (w &Weapon_t) postpone_fire_ready_time() f32 {

	return *(utils.get_val_offset<f32>(w, offsets.db.netvars.postpone_fire_ready_time))
}

pub fn (w &Weapon_t) last_shot_time() f32 {

	return *(utils.get_val_offset<f32>(w, offsets.db.netvars.last_shot_time))
}

pub fn (w &Weapon_t) next_primary_attack() f32 {

	return *(utils.get_val_offset<f32>(w, offsets.db.netvars.next_primary_attack))
}

pub fn (w &Weapon_t) clip1() int {

	return *(utils.get_val_offset<int>(w, offsets.db.netvars.clip1))
}

pub fn (w &Weapon_t) definition_index_() ItemDefinitionIndex {

	return *(utils.get_val_offset<ItemDefinitionIndex>(w, offsets.db.netvars.m_item_definition_index))
}

pub fn (w &Weapon_t) definition_index() utils.Value<i16> {

	return utils.Value<i16>{ptr: utils.get_val_offset<i16>(w, offsets.db.netvars.m_item_definition_index)}
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

pub fn (p &Player) is_scoped() bool {

	return *(utils.get_val_offset<bool>(p, offsets.db.netvars.m_is_scoped))
}

pub fn (p &Player) weapons() &usize {

	return &usize( usize(p) + offsets.db.netvars.m_my_weapons )
}

pub fn (p &Player) active_weapon() u32 {

	return *(utils.get_val_offset<u32>(p, offsets.db.netvars.m_active_weapon))
}

pub fn (p &Player) viewmodel() u32 {

	return *(utils.get_val_offset<u32>(p, offsets.db.netvars.m_view_model))
}

pub fn (p &Player) spotted_by_mask() int {

	return *(utils.get_val_offset<int>(p, offsets.db.netvars.spotted_by_mask))
}

pub fn (p &Player) next_attack() f32 {

	return *(utils.get_val_offset<f32>(p, offsets.db.netvars.next_attack))
}

pub fn (p &Player) tick_base() int {

	return *(utils.get_val_offset<int>(p, offsets.db.netvars.tick_base))
}

pub fn (p &Player) velocity() utils.Vec3 {

	return *(utils.get_val_offset<utils.Vec3>(p, offsets.db.netvars.velocity))
}

pub fn (p &Player) has_helmet() bool {

	return *(utils.get_val_offset<bool>(p, offsets.db.netvars.m_has_helmet))
}

pub fn (p &Player) armor() int {

	return *(utils.get_val_offset<int>(p, offsets.db.netvars.m_armor_value))
}

pub fn (p &Player) spotted() utils.Value<bool> {

	return utils.Value<bool>{ptr: utils.get_val_offset<bool>(p, offsets.db.netvars.spotted)}
}

pub fn (p &Player) flash_duration() utils.Value<f32> {

	return utils.Value<f32>{ptr: utils.get_val_offset<f32>(p, offsets.db.netvars.flash_duration)}
}

pub fn (p &Player) is_moving() bool{

	$if prod { C.VMProtectBeginMutation(c"player.is_moving") }

	v_vel := p.velocity()

	if (v_vel.x + v_vel.y + v_vel.z) == 0.0 {
		return false
	}

	$if prod { C.VMProtectEnd() }

	return true
}

pub fn (p &Player) bone(with_bone_idx usize) ?utils.Vec3 {

	$if prod { C.VMProtectBeginMutation(c"player.bone") }

	mut res := utils.new_vec3(0, 0, 0)

	mut bones_mat := *(&usize(usize(p) + offsets.db.netvars.m_bone_matrix))

	if isnil(bones_mat) {
		return error("bone_mat not available")
	}

	res.x = *(&f32(bones_mat + 0x30 * with_bone_idx + 0x0c))
	res.y = *(&f32(bones_mat + 0x30 * with_bone_idx + 0x1c))
	res.z = *(&f32(bones_mat + 0x30 * with_bone_idx + 0x2c))

	$if prod { C.VMProtectEnd() }

	return res
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

// item

struct Item {
	Entity_t
}

pub fn (i &Item) fallback_seed() utils.Value<int> {

	return utils.Value<int>{ptr: utils.get_val_offset<int>(i, offsets.db.netvars.m_fallback_seed)}
}

pub fn (i &Item) fallback_wear() utils.Value<f32> {

	return utils.Value<f32>{ptr: utils.get_val_offset<f32>(i, offsets.db.netvars.m_fallback_wear)}
}

pub fn (i &Item) fallback_paint_kit() utils.Value<int> {

	return utils.Value<int>{ptr: utils.get_val_offset<int>(i, offsets.db.netvars.m_fallback_paint_kit)}
}

pub fn (i &Item) item_id_high() utils.Value<int> {

	return utils.Value<int>{ptr: utils.get_val_offset<int>(i, offsets.db.netvars.m_item_id_high)}
}

pub fn (i &Item) entity_quality() utils.Value<int> {

	return utils.Value<int>{ptr: utils.get_val_offset<int>(i, offsets.db.netvars.m_entity_quality)}
}

// Viewmodel

pub struct Viewmodel {
	Entity_t
}

pub fn (v &Viewmodel) model_index() utils.Value<int> {

	return utils.Value<int>{ptr: utils.get_val_offset<int>(v, offsets.db.netvars.m_model_index)}
}

pub fn (v &Viewmodel) viewmodel_index() utils.Value<int> {

	return utils.Value<int>{ptr: utils.get_val_offset<int>(v, offsets.db.netvars.m_view_model_index)}
}
