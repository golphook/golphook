module golphook

import golphook.valve
import golphook.utils

type P_create_interface = fn (&char, int) voidptr

struct Interfaces {
pub mut:
	cdll_int      &valve.IVEngineClient = 0
	i_cvar        &valve.ICvar = 0
	i_base_client &valve.IBaseClientDLL = 0
}

fn (mut i Interfaces) get_interface<T>(withName string, inModule string) &T {
	h_mod := C.GetModuleHandleA(&char(inModule.str))
	if int(h_mod) == 0 {
		utils.error_critical('Failed to get inferface', withName)
	}
	crt_itfc_add := C.GetProcAddress(h_mod, c'CreateInterface')
	if int(crt_itfc_add) == 0 {
		utils.error_critical('Failed to get inferface', withName)
	}
	o_create_interface := &P_create_interface(crt_itfc_add)
	itfc_add := o_create_interface(&char(withName.str), 0)
	if int(o_create_interface) == 0 {
		utils.error_critical('Failed to get inferface', withName)
	}

	return &T(itfc_add)
}

fn (mut i Interfaces) bootstrap() {
	i.cdll_int = i.get_interface<valve.IVEngineClient>('VEngineClient014', 'engine.dll')
	utils.pront('cdll_int -> ${voidptr(i.cdll_int).str()}')
	i.i_cvar = i.get_interface<valve.ICvar>('VEngineCvar007', 'vstdlib.dll')
	utils.pront('i_cvar -> ${voidptr(i.i_cvar).str()}')
	i.i_base_client = i.get_interface<valve.IBaseClientDLL>('VClient018', 'client.dll')
	utils.pront('i_base_client -> ${voidptr(i.i_base_client).str()}')
}