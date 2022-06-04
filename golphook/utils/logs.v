module utils

type P_con_color_msg = fn (&Color, &char)
type P_con_msg = fn (&char)

fn C.puts(&char)

pub fn load_unload_console(with_switch bool, and_file &C.FILE) {

	if with_switch {
		if !C.AllocConsole() {
			error_critical('Failed to initialize console', 'AllocConsole()')
		}

		if C.freopen_s(&and_file, c'CONOUT$', c'w', C.stdout) != 0 {
			error_critical('Failed to initialize console', 'freopen_s()')
		}
	} else {
		// crash the game see later
		// C.fclose(andFile)
		// C.FreeConsole()
	}
}

[unsafe]
pub fn msg_c(with_text string, and_color Color) {

	color_ref := and_color

	mut static o_fn := &P_con_color_msg(0)
	if isnil(o_fn) {
		o_fn = &P_con_color_msg(C.GetProcAddress(C.GetModuleHandleA(c'tier0.dll'), c'?ConColorMsg@@YAXABVColor@@PBDZZ'))
	}

	mut final := '[golphook] $with_text \n'

	o_fn(&color_ref, &char(final.str))
}

pub fn pront(with_text string) {

	$if debug {
		C.puts(&char(with_text.str))
	}
	// unsafe {msg_c(utils.Color{142, 68, 173, 255}, withContent)}
}
