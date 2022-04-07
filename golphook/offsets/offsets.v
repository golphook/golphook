module offsets

import utils

import json

pub const db = Offsets{}

struct Offset_sigs {
pub:
	entity_list  u32 [json: dwEntityList]
	force_attack u32 [json: dwForceAttack]
	force_jump u32 [json: dwForceJump]
	glow_object_manager u32 [json: dwGlowObjectManager]
	m_dormant u32 [json: m_bDormant]
	global_vars u32 [json: dwGlobalVars]
}

struct Offset_nets {
pub:
	m_zoom_level      u32 [json: m_zoomLevel]
	m_vec_view_offset u32 [json: m_vecViewOffset]
	m_health u32 [json: m_iHealth]
	m_life_tate u32 [json: m_lifeState]
	m_vec_origin u32 [json: m_vecOrigin]
	m_view_punch_angle u32 [json: m_viewPunchAngle]
	client_state u32 [json: dwClientState]
	client_state_view_angles u32 [json: dwClientState_ViewAngles]
	m_team_num u32 [json: m_iTeamNum]
	m_bone_matrix u32 [json: m_dwBoneMatrix]
	m_flags u32 [json: m_fFlags]
	m_in_reload u32 [json: m_bInReload]
	m_my_weapons u32 [json: m_hMyWeapons]
	m_item_definition_index u32 [json: m_iItemDefinitionIndex]
	m_model_index u32 [json: m_nModelIndex]
	m_view_model_index u32 [json: m_iViewModelIndex]
	m_entity_quality u32 [json: m_iEntityQuality]
	m_item_id_high u32 [json: m_iItemIDHigh]
	m_fallback_paint_kit u32 [json: m_nFallbackPaintKit]
	m_fallback_wear u32 [json: m_flFallbackWear]
	m_active_weapon u32 [json: m_hActiveWeapon]
	m_view_model u32 [json: m_hViewModel]
	m_is_scoped u32 [json: m_bIsScoped]
	//m_iShotsFired u32 [json: m_iShotsFired]
	m_move_type u32 [json: m_MoveType]
	m_observer_target u32 [json: m_hObserverTarget]
	glow_index u32 [json: m_iGlowIndex]
	spotted_by_mask u32 [json: m_bSpottedByMask]
	postpone_fire_ready_time u32 [json: m_flPostponeFireReadyTime]
	last_shot_time u32 [json: m_fLastShotTime]
	next_attack u32 [json: m_flNextAttack]
	owner_entity u32 [json: m_hOwnerEntity]
	next_primary_attack u32 [json: m_flNextPrimaryAttack]
	tick_base u32 [json: m_nTickBase]
	clip1 u32 [json: m_iClip1]
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
