module valve

import utils

struct WeaponData {
pub:
	pad [4]u8
	clean_name voidptr
	pud [12]u8
	max_clip int
	pad1 [112]u8
	name voidptr
	pad1_ [60]u8
	w_type WeaponType
	pad2 [32]u8
	full_auto bool
	pad3 [3]u8
	damage int
	armor_ratio f32
	bullets int
	penetration f32
	pad4 [8]u8
	range f32
	range_modifier f32
	pad5 [16]u8
	has_silencer bool
}

pub fn (w &WeaponData) name() string {
	mut raw_name := unsafe { cstring_to_vstring(w.clean_name) }

	mut cleaned_name := raw_name.replace("weapon_", "")
	if raw_name.contains("_silencer") {
		cleaned_name = cleaned_name.replace("_silencer", "")
	}
	if w.w_type == .knife {
		cleaned_name = cleaned_name.replace("knife_", "")
	}
	cleaned_name = cleaned_name.replace("_", " ")
	cleaned_name = cleaned_name.to_lower()
	return cleaned_name
}


struct IWeaponSystem {}

[callconv: "fastcall"]
type P_wp_get_data = fn (voidptr, usize, i32) &WeaponData

pub fn (i &IWeaponSystem) weapon_data(with_itm_def_idx i32) &WeaponData {
	return utils.call_vfunc<P_wp_get_data>(i, 2)(i, 0, with_itm_def_idx)
}
