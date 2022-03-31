module golphook

import utils

import json

struct Offset_sigs {
	dw_entity_list  u32 [json: dwEntityList]
	dw_force_attack u32 [json: dwForceAttack]
}

struct Offset_nets {
	m_zoom_level      u32 [json: m_zoomLevel]
	m_vec_view_offset u32 [json: m_vecViewOffset]
}

struct Offsets {
	timestamp  int
	signatures Offset_sigs
	netvars    Offset_nets
}

fn load_offsets() Offsets {
	file := $embed_file('../ressources/offsets.json')
	file_content := file.to_string()
	utils.pront("ahllo ?? -")
	offsets_ := json.decode(Offsets, file_content) or {
		utils.error_critical("Failed to load offsets", "$err")
		return Offsets{timestamp: -1}
	}
	return offsets_
}
