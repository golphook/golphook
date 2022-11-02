module golphook

import golphook.valve
import golphook.utils

type P_create_interface = fn (&char, int) voidptr

struct Interfaces {
pub mut:
	cdll_int      &valve.IVEngineClient = unsafe { nil }
	i_base_client &valve.IBaseClientDLL = unsafe { nil }
	i_entity_list &valve.IEntityList = unsafe { nil }
	i_debug_overlay &valve.IVDebugOverlay = unsafe { nil }
	i_engine_trace &valve.IEngineTrace = unsafe { nil }
}

fn (mut i Interfaces) get_interface<T>(withName string, inModule string) &T {

	$if prod { C.VMProtectBeginMutation(c"interfaces.get_interface") }

	h_mod := C.GetModuleHandleA(&char(inModule.str))
	if isnil(h_mod) {
		utils.error_critical('Failed to get inferface', withName)
	}
	crt_itfc_add := C.GetProcAddress(h_mod, c'CreateInterface')
	if isnil(crt_itfc_add) {
		utils.error_critical('Failed to get inferface', withName)
	}
	o_create_interface := &P_create_interface(crt_itfc_add)
	itfc_add := o_create_interface(&char(withName.str), 0)
	if isnil(itfc_add) {
		utils.error_critical('Failed to get inferface', withName)
	}

	utils.pront(utils.str_align("[+] $withName", 40, "| ${voidptr(itfc_add).str()}"))

	$if prod { C.VMProtectEnd() }

	return &T(itfc_add)
}

fn (mut i Interfaces) get_interface_pattern<T>(with_name string, in_module string, with_pattern string, ptr_manipulation 	fn(voidptr) voidptr) &T {

	$if prod { C.VMProtectBeginMutation(c"interfaces.get_interface_pattern") }

	ptn_res := utils.pattern_scan(in_module, with_pattern) or {
		utils.error_critical('Failed to get inferface', with_name)
	}

	if_add := ptr_manipulation(ptn_res)
	utils.pront(utils.str_align("[+] $with_name", 40, "| ${voidptr(if_add).str()}"))
	
	$if prod { C.VMProtectEnd() }

	return &T(if_add)
}

fn (mut i Interfaces) get_interface_offset<T>(with_name string, in_module voidptr, at_index int, plus_offset usize) &T {

	$if prod { C.VMProtectBeginMutation(c"interfaces.get_interface_offset") }

	r := **&&&T( (usize( utils.get_virtual(in_module, at_index) ) + plus_offset) )

	utils.pront(utils.str_align("[+] $with_name", 40, "| ${voidptr(r).str()}"))
	
	$if prod { C.VMProtectEnd() }

	return r
}


fn (mut i Interfaces) bootstrap() {

	$if prod { C.VMProtectBeginMutation(c"interfaces.bootstrap") }

	utils.pront("[-] bootstraping interfaces...")

	i.cdll_int = i.get_interface<valve.IVEngineClient>('VEngineClient014', 'engine.dll')
	i.i_base_client = i.get_interface<valve.IBaseClientDLL>('VClient018', 'client.dll')
	i.i_entity_list = i.get_interface<valve.IEntityList>('VClientEntityList003', 'client.dll')
	i.i_debug_overlay = i.get_interface<valve.IVDebugOverlay>("VDebugOverlay004", "engine.dll")
	i.i_engine_trace = i.get_interface<valve.IEngineTrace>("EngineTraceClient004", "engine.dll")

	$if prod { C.VMProtectEnd() }
}
