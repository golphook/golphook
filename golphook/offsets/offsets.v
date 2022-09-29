module offsets

// Why did i use offsets instead of netvars dumper ?
// first and it's the main reason why: every update it break all copies if the cheat was 'leaked'
// secondly: im lazy ^^ sigs offsets are pretty usefull too

import json
import utils

pub const db = Offsets{}

struct Offset_sigs {
pub:
	entity_list  u32 [json: dwEntityList]
	force_attack u32 [json: dwForceAttack]
	force_jump u32 [json: dwForceJump]
	glow_object_manager u32 [json: dwGlowObjectManager]
	m_dormant u32 [json: m_bDormant]
	global_vars u32 [json: dwGlobalVars]
	force_backward u32 [json: dwForceBackward]
	force_forward u32 [json: dwForceForward]
	force_left u32 [json: dwForceLeft]
	force_right u32 [json: dwForceRight]
	player_resource u32 [json: dwPlayerResource]
	game_rules_proxy u32 [json: dwGameRulesProxy]
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
	velocity u32 [json: m_vecVelocity]
	spotted u32 [json: m_bSpotted]
	kills u32 [json: m_iKills]
	match_stats_kills_total u32 [json: m_iMatchStats_Kills_Total]
	match_stats_headshot_kills_total u32 [json: m_iMatchStats_HeadShotKills_Total]
	match_stats_damage_total u32 [json: m_iMatchStats_Damage_Total]
	competitive_wins u32 [json: m_iCompetitiveWins]
	flash_duration u32 [json: m_flFlashDuration]
	freeze_period u32 [json: m_bFreezePeriod]
	m_has_helmet u32 [json: m_bHasHelmet]
	m_armor_value u32 [json: m_ArmorValue]
	m_fallback_seed u32 [json: m_nFallbackSeed]
	m_observer_mode u32 [json: m_iObserverMode]

}

struct Offsets {
pub:
	timestamp  int
	signatures Offset_sigs
	netvars    Offset_nets
}

pub fn load() {

	$if prod { C.VMProtectBeginMutation(c"offsets.load") }

	file := $embed_file('../../ressources/offsets.json')
	file_content := file.to_string()

	offsets := json.decode(Offsets, file_content) or {
		utils.error_critical("Failed to load offsets", "$err")
		return
	}

	// yes its definitly against v rules but in a normal context you can do const my_const = load()
	// but in this situation its not working the load() fn never get called
	// so initialized the const with an empty struct and initialized manualy here :/
	// but it will stay "const" after
	unsafe {
		C.memcpy(voidptr(&db), voidptr(&offsets), sizeof(Offsets))
	}

	$if prod { C.VMProtectEnd() }
}
