module valve

import golphook.utils

pub struct PlayerInfo {
	pad i64
	pod i64
	sz_name [128]char
	user_id int
	sz_steam_id [20]char
	pud [0x10]char
	steam_id u32
	friends_sz_name [128]char
	fake_player bool
	hltv bool
	custom_files [4]int
	files_downloaded u8
}

pub fn (p &PlayerInfo) player_name() string {

	return unsafe { cstring_to_vstring(voidptr(&p.sz_name[0])) }
}

pub struct IVEngineClient {}

[callconv: "fastcall"]
type P_get_screen_size = fn (voidptr, usize, &int, &int)

[callconv: "fastcall"]
type P_client_cmd = fn (voidptr, usize, &char)

[callconv: "fastcall"]
type P_get_player_info = fn (voidptr, usize, int, &PlayerInfo) bool

[callconv: "fastcall"]
type P_is_con_visible = fn (voidptr, usize) bool

[callconv: "fastcall"]
type P_get_local_player = fn (voidptr, usize) int

[callconv: "fastcall"]
type P_get_view_angle = fn(voidptr, usize, &utils.Angle)

[callconv: "fastcall"]
type P_set_view_angle = fn(voidptr, usize, &utils.Angle)

[callconv: "fastcall"]
type P_is_in_game = fn (voidptr, usize) bool

[callconv: "fastcall"]
type P_is_connected = fn (voidptr, usize) bool

[callconv: "fastcall"]
type P_execute_client_cmd = fn (voidptr, usize, &char)

[callconv: "fastcall"]
type P_get_app_id = fn (voidptr, usize) int

[callconv: "fastcall"]
type P_execute_client_cmd_unrectricted = fn (voidptr, usize, &char)

pub fn (i &IVEngineClient) get_screen_size(to_width &int, and_height &int) {

	utils.call_vfunc<P_get_screen_size>(i, 5)(i, 0, to_width, and_height)
}

pub fn (i &IVEngineClient) client_cmd(with_cmd string) {

	utils.call_vfunc<P_client_cmd>(i, 7)(i, 0, &char(with_cmd.str))
}

pub fn (i &IVEngineClient) get_player_info(for_ent_id int, to_p_info_struct &PlayerInfo) bool {

	return utils.call_vfunc<P_get_player_info>(i, 8)(i, 0, for_ent_id, to_p_info_struct)
}

pub fn (i &IVEngineClient) is_con_visible() bool {

	return utils.call_vfunc<P_is_con_visible>(i, 11)(i, 0)
}

pub fn (i &IVEngineClient) get_local_player() int {

	return utils.call_vfunc<P_get_local_player>(i, 12)(i, 0)
}

pub fn (i &IVEngineClient) get_view_angle(with_angle &utils.Angle) {

	utils.call_vfunc<P_set_view_angle>(i, 18)(i, 0, with_angle)
}

pub fn (i &IVEngineClient) set_view_angle(with_angle &utils.Angle) {

	utils.call_vfunc<P_set_view_angle>(i, 19)(i, 0, with_angle)
}

pub fn (i &IVEngineClient) is_in_game() bool {

	return utils.call_vfunc<P_is_in_game>(i, 26)(i, 0)
}

pub fn (i &IVEngineClient) is_connected() bool {

	return utils.call_vfunc<P_is_connected>(i, 27)(i, 0)
}

pub fn (i &IVEngineClient) execute_client_cmd(with_text string) {

	utils.call_vfunc<P_execute_client_cmd>(i, 108)(i, 0, &char(with_text.str))
}

pub fn (i &IVEngineClient) get_app_id() int {

	return utils.call_vfunc<P_get_app_id>(i, 111)(i, 0)
}

pub fn (i &IVEngineClient) execute_client_cmd_unrectricted(with_text string) {

	utils.call_vfunc<P_execute_client_cmd_unrectricted>(i, 114)(i, 0, &char(with_text.str))
}

pub  struct IBaseClientDLL {}
