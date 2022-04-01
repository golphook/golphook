module valve

import golphook.utils

struct IVEngineClient {}

type P_execute_client_cmd = fn (&char)
type P_is_in_game = fn () bool
type P_is_connected = fn () bool
type P_get_app_id = fn () int
type P_get_local_player = fn () int

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

struct IBaseClientDLL {}
