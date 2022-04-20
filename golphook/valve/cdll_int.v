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

struct IVEngineClient {}

type P_execute_client_cmd = fn (&char)
type P_is_in_game = fn () bool
type P_is_connected = fn () bool
type P_get_app_id = fn () int
type P_get_local_player = fn () int
type P_get_player_info = fn (int, &PlayerInfo) bool
type P_get_screen_size = fn (&int, &int)
type P_set_view_angle = fn(&utils.Angle)
type P_get_view_angle = fn(&utils.Angle)
type P_is_con_visible = fn () bool
type P_execute_client_cmd_unrectricted = fn (&char)


pub fn (mut i IVEngineClient) execute_client_cmd(text string) {
	o_fn_add := utils.get_virtual(i, 108)

	o_fn := &P_execute_client_cmd(o_fn_add)
	o_fn(&char(text.str))
}

pub fn (mut i IVEngineClient) is_in_game() bool {
	o_fn_add := utils.get_virtual(i, 26)

	o_fn := &P_is_in_game(o_fn_add)
	res := o_fn()
	return res
}

pub fn (mut i IVEngineClient) is_connected() bool {
	o_fn_add := utils.get_virtual(i, 27)

	o_fn := &P_is_connected(o_fn_add)
	res := o_fn()
	return res
}

pub fn (mut i IVEngineClient) get_local_player() int {
	o_fn_add := utils.get_virtual(i, 12)

	o_fn := &P_get_local_player(o_fn_add)
	res := o_fn()
	return res
}

pub fn (mut i IVEngineClient) get_app_id() int {
	o_fn_add := utils.get_virtual(i, 11)

	o_fn := &P_get_app_id(o_fn_add)
	res := o_fn()
	return res
}

pub fn (mut i IVEngineClient) get_player_info(withEntNum int, andPlayerInfo &PlayerInfo) bool {
	o_fn_add := utils.get_virtual(i, 8)

	o_fn := &P_get_player_info(o_fn_add)
	res := o_fn(withEntNum, andPlayerInfo)
	return res
}

pub fn (mut i IVEngineClient) get_screen_size(withOutWidth &int, withOutHeight &int) {
	o_fn_add := utils.get_virtual(i, 5)

	o_fn := &P_get_screen_size(o_fn_add)
	o_fn(withOutWidth, withOutHeight)
}

pub fn (mut i IVEngineClient) set_view_angle(withAngle &utils.Angle) {
	o_fn_add := utils.get_virtual(i, 19)

	o_fn := &P_set_view_angle(o_fn_add)
	o_fn(withAngle)
}

pub fn (mut i IVEngineClient) get_view_angle(withAngle &utils.Angle) {
	o_fn_add := utils.get_virtual(i, 18)

	o_fn := &P_get_view_angle(o_fn_add)
	o_fn(withAngle)
}

pub fn (mut i IVEngineClient) is_con_visible() bool {
	o_fn_add := utils.get_virtual(i, 11)

	o_fn := &P_is_con_visible(o_fn_add)
	r := o_fn()
	return r
}

pub fn (mut i IVEngineClient) execute_client_cmd_unrectricted(text string) {
	o_fn_add := utils.get_virtual(i, 114)

	o_fn := &P_execute_client_cmd_unrectricted(o_fn_add)
	o_fn(&char(text.str))
}

struct IBaseClientDLL {}
