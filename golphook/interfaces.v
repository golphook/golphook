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
	// i_surface &valve.ISurface = 0
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

	return &T(itfc_add)
}

fn (mut i Interfaces) bootstrap() {
	i.cdll_int = i.get_interface<valve.IVEngineClient>('VEngineClient014', 'engine.dll')
	utils.pront('cdll_int -> ${voidptr(i.cdll_int).str()}')
	i.i_cvar = i.get_interface<valve.ICvar>('VEngineCvar007', 'vstdlib.dll')
	utils.pront('i_cvar -> ${voidptr(i.i_cvar).str()}')
	i.i_base_client = i.get_interface<valve.IBaseClientDLL>('VClient018', 'client.dll')
	utils.pront('i_base_client -> ${voidptr(i.i_base_client).str()}')
	i.i_entity_list = i.get_interface<valve.IEntityList>('VClientEntityList003', 'client.dll')
	utils.pront('i_entity_list -> ${voidptr(i.i_entity_list).str()}')
	i.i_debug_overlay = i.get_interface<valve.IVDebugOverlay>("VDebugOverlay004", "engine.dll")
	utils.pront('i_debug_overlay -> ${voidptr(i.i_debug_overlay).str()}')
	i.i_model_info = i.get_interface<valve.IVModelInfo>("VModelInfoClient004", "engine.dll")
	utils.pront('i_model_info -> ${voidptr(i.i_model_info).str()}')
	i.i_engine_trace = i.get_interface<valve.IEngineTrace>("EngineTraceClient004", "engine.dll")
	utils.pront('i_engine_trace -> ${voidptr(i.i_engine_trace).str()}')
	// i.i_surface = i.get_interface<valve.ISurface>("VGUI_Surface031", "vguimatsurface.dll")
	// utils.pront('i_surface -> ${voidptr(i.i_surface).str()}')

	i.c_input = i.get_interface<valve.IInputSystem>("InputSystemVersion001", "inputsystem.dll")
	utils.pront('c_input -> ${voidptr(i.c_input).str()}')

	// i.i_panorama_engine = i.get_interface<valve.IPanoramaUIEngine>("PanoramaUIEngine001", "panorama.dll")
	// utils.pront('i_panorama_engine -> ${voidptr(i.i_panorama_engine).str()}')


	mut device_scan := utils.patter_scan("client.dll", "A1 ? ? ? ? 5E 8B 40 10") or { panic("$err") }
	i.c_global_vars = **(&&&valve.CGlobalVarsBase(voidptr(usize(device_scan) + 1)))
	utils.pront('c_global_vars -> ${voidptr(i.c_global_vars).str()}')

	mut weapon_system_scan := utils.patter_scan("client.dll", "8B 35 ? ? ? ? FF 10 0F B7 C0") or { panic("$err") }
	i.i_weapon_system = *(&&valve.IWeaponSystem(voidptr(usize(weapon_system_scan) + 2)))
	utils.pront('i_weapon_system -> ${voidptr(i.i_weapon_system).str()}')

}
