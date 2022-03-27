module valve

import utils

struct IVEngineClient {

}

type P_execute_client_cmd = fn (&char)

pub fn (mut i IVEngineClient) execute_client_cmd(text string) {
	ex_cl_cmd_add := utils.get_virtual(i, 108)

	a := &P_execute_client_cmd(ex_cl_cmd_add)
	a(&char(text.str))
}
