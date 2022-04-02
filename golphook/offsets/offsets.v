module offsets

import utils

import json

pub const db = Offsets{}

struct Offset_sigs {
pub:
	entity_list  u32 [json: dwEntityList]
	force_attack u32 [json: dwForceAttack]
}

struct Offset_nets {
pub:
	m_zoom_level      u32 [json: m_zoomLevel]
	m_vec_view_offset u32 [json: m_vecViewOffset]
	m_health u32 [json: m_iHealth]
	m_dormant u32 [json: m_bDormant]
	m_life_tate u32 [json: m_lifeState]
	m_vec_origin u32 [json: m_vecOrigin]
	m_view_punch_angle u32 [json: m_viewPunchAngle]
	client_state u32 [json: dwClientState]
	client_state_view_angles u32 [json: dwClientState_ViewAngles]
	m_team_num u32 [json: m_iTeamNum]
	m_bone_matrix u32 [json: m_dwBoneMatrix]
	m_flags u32 [json: m_fFlags]
	m_in_reload u32 [json: m_bInReload]
}

struct Offsets {
pub:
	timestamp  int
	signatures Offset_sigs
	netvars    Offset_nets
}

pub fn load() Offsets {
	file := $embed_file('../../ressources/offsets.json')
	file_content := file.to_string()

	offsets_ := json.decode(Offsets, file_content) or {
		utils.error_critical("Failed to load offsets", "$err")
		return Offsets{timestamp: -1}
	}

	// yes its definitly againt v rules but in plain v yout can do const my_const = load()
	// but il this situation its not working the load() fn dont get call
	// so initialized the const with an empty struct and initialized manualy here :/
	// but it will stay "const" after
	unsafe {
		C.memcpy(voidptr(&db), voidptr(&offsets_), sizeof(Offsets))
	}

	return offsets_
}