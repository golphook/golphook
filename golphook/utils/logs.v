module utils

fn C.puts(&char)

pub fn load_unload_console(switch bool, andFile &C.FILE) {
	if switch {
		if !C.AllocConsole() {
			error_critical('Failed to initialize console', 'AllocConsole()')
		}
		if C.freopen_s(&andFile, c'CONOUT$', c'w', C.stdout) != 0 {
			error_critical('Failed to initialize console', 'freopen_s()')
		}
	} else {
		// C.fclose(andFile)
		// C.FreeConsole()
	}
}

type P_con_color_msg = fn (&Color, &char)
type P_con_msg = fn (&char)

[unsafe]
pub fn msg_c(withColor Color, text string) {
	color := withColor

	mut static fn_add := voidptr(0)
	if int(fn_add) == 0 {
		fn_add = C.GetProcAddress(C.GetModuleHandleA(c'tier0.dll'), c'?ConColorMsg@@YAXABVColor@@PBDZZ')
	}
	o_fn := &P_con_color_msg(fn_add)

	mut final := '[golphook] $text \n'

	o_fn(&color, &char(final.str))
}

pub fn pront(withContent string) {
	C.puts(&char(withContent.str))
	// unsafe {msg_c(utils.Color{142, 68, 173, 255}, withContent)}
}
