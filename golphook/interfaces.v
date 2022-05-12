module golphook

import golphook.valve
import golphook.utils
import offsets

type P_create_interface = fn (&char, int) voidptr

struct Interfaces {
pub mut:
	cdll_int      &valve.IVEngineClient = 0
	i_cvar        &valve.ICvar = 0
	i_base_client &valve.IBaseClientDLL = 0
	i_entity_list &valve.IEntityList = 0
	i_debug_overlay &valve.IVDebugOverlay = 0
	i_model_info &valve.IVModelInfo = 0
	i_engine_trace &valve.IEngineTrace = 0
	c_global_vars &valve.CGlobalVarsBase = 0
	c_input &valve.IInputSystem = 0
	// i_panorama_engine &valve.IPanoramaUIEngine = 0
	i_surface &valve.ISurface = 0
	i_weapon_system &valve.IWeaponSystem = 0
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

	utils.pront(utils.str_align("[+] $withName", 40, "| ${voidptr(itfc_add).str()}"))

	return &T(itfc_add)
}

fn (mut i Interfaces) get_interface_pattern<T>(with_name string, in_module string, with_pattern string, ptr_manipulation 	fn(voidptr) voidptr) &T {
	ptn_res := utils.patter_scan(in_module, with_pattern) or {
		utils.error_critical('Failed to get inferface', with_name)
	}

	if_add := ptr_manipulation(ptn_res)
	utils.pront(utils.str_align("[+] $with_name", 40, "| ${voidptr(if_add).str()}"))
	return &T(if_add)
}

fn (mut i Interfaces) bootstrap() {
	utils.pront("[-] bootstraping interfaces...")

	i.cdll_int = i.get_interface<valve.IVEngineClient>('VEngineClient014', 'engine.dll')
	i.i_cvar = i.get_interface<valve.ICvar>('VEngineCvar007', 'vstdlib.dll')
	i.i_base_client = i.get_interface<valve.IBaseClientDLL>('VClient018', 'client.dll')
	i.i_entity_list = i.get_interface<valve.IEntityList>('VClientEntityList003', 'client.dll')
	i.i_debug_overlay = i.get_interface<valve.IVDebugOverlay>("VDebugOverlay004", "engine.dll")
	i.i_model_info = i.get_interface<valve.IVModelInfo>("VModelInfoClient004", "engine.dll")
	i.i_engine_trace = i.get_interface<valve.IEngineTrace>("EngineTraceClient004", "engine.dll")
	i.i_surface = i.get_interface<valve.ISurface>("VGUI_Surface031", "vguimatsurface.dll")
	i.c_input = i.get_interface<valve.IInputSystem>("InputSystemVersion001", "inputsystem.dll")
	// i.i_panorama_engine = i.get_interface<valve.IPanoramaUIEngine>("PanoramaUIEngine001", "panorama.dll")

	i.c_global_vars = i.get_interface_pattern<valve.CGlobalVarsBase>("CGlobalVarsBase", "client.dll", "A1 ? ? ? ? 5E 8B 40 10", fn(ptn_res voidptr) voidptr {
		return **(&&&usize(voidptr(usize(ptn_res) + 1)))
	})
	i.i_weapon_system = i.get_interface_pattern<valve.IWeaponSystem>("IWeaponSystem", "client.dll", "8B 35 ? ? ? ? FF 10 0F B7 C0", fn(ptn_res voidptr) voidptr {
		return *(&&usize(voidptr(usize(ptn_res) + 2)))
	})
}
